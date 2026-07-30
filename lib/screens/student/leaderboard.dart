import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/student_provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/theme.dart';
import '../../widgets/islamic_header.dart';

final leaderboardProvider = FutureProvider.family<List<Map<String, dynamic>>, ({String groupId, DateTime weekStart})>(
  (ref, params) => ref.read(studentProvider).getWeeklyLeaderboard(params.groupId, params.weekStart),
);

class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localUser = ref.watch(currentUserProvider).valueOrNull;
    if (localUser == null) return const Center(child: CircularProgressIndicator());

    final groupId = localUser.groupSupabaseId ?? '';
    final weekStart = DateTime.now().subtract(Duration(days: DateTime.now().weekday - DateTime.saturday));
    final leaderboardAsync = ref.watch(leaderboardProvider((groupId: groupId, weekStart: weekStart)));

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: IslamicHeader(title: 'المتصدرون', subtitle: 'هذا الأسبوع').animate().fadeIn()),
          leaderboardAsync.when(
            data: (list) => SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final item = list[index];
                  final rank = index + 1;
                  Color medalColor;
                  IconData medalIcon;
                  switch (rank) {
                    case 1:
                      medalColor = AppTheme.warmGold;
                      medalIcon = Icons.emoji_events;
                      break;
                    case 2:
                      medalColor = const Color(0xFFC0C0C0);
                      medalIcon = Icons.emoji_events;
                      break;
                    case 3:
                      medalColor = const Color(0xFFCD7F32);
                      medalIcon = Icons.emoji_events;
                      break;
                    default:
                      medalColor = Colors.grey;
                      medalIcon = Icons.circle;
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      child: ListTile(
                        leading: Stack(
                          alignment: Alignment.center,
                          children: [
                            if (rank <= 3)
                              Icon(medalIcon, color: medalColor, size: 36),
                            CircleAvatar(
                              backgroundColor: medalColor,
                              radius: 18,
                              child: Text(
                                '$rank',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        title: Text(
                          item['name'],
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          'الجلسات: ${item['sessions']} | الحضور: ${item['earlyAttendance']}',
                          style: TextStyle(color: AppTheme.warmGold),
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${(item['points'] as double).toStringAsFixed(1)}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: AppTheme.emeraldGreen),
                            ),
                            Text(
                              'نقطة',
                              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      ),
                    ).animate().fadeIn(delay: (60 * index).ms).slideX(begin: 0.05, end: 0),
                  );
                },
                childCount: list.length,
              ),
            ),
            loading: () => const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator())),
            error: (err, _) => SliverToBoxAdapter(child: Center(child: Text('خطأ: $err'))),
          ),
        ],
      ),
    );
  }
}