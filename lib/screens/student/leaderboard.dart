import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/student_provider.dart';
import '../../providers/auth_provider.dart';

final leaderboardProvider = FutureProvider.family<List<Map<String, dynamic>>, ({String groupId, DateTime weekStart})>(
  (ref, params) {
    return ref.read(studentProvider).getWeeklyLeaderboard(params.groupId, params.weekStart);
  },
);

class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // استخدام currentUserProvider بدلاً من authStateProvider
    final localUser = ref.watch(currentUserProvider).valueOrNull;
    if (localUser == null) return const Center(child: CircularProgressIndicator());

    final groupId = localUser.groupSupabaseId ?? '';
    final weekStart = DateTime.now().subtract(Duration(days: DateTime.now().weekday - 6));

    final leaderboardAsync = ref.watch(leaderboardProvider((groupId: groupId, weekStart: weekStart)));

    return Scaffold(
      appBar: AppBar(title: const Text('المتصدرون هذا الأسبوع')),
      body: leaderboardAsync.when(
        data: (list) => ListView.builder(
          itemCount: list.length,
          itemBuilder: (context, index) {
            final item = list[index];
            Color medalColor;
            switch (index) {
              case 0: medalColor = const Color(0xFFD4AF37); break;
              case 1: medalColor = const Color(0xFFC0C0C0); break;
              case 2: medalColor = const Color(0xFFCD7F32); break;
              default: medalColor = Colors.grey;
            }
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: medalColor,
                child: Text('${index + 1}', style: const TextStyle(color: Colors.white)),
              ),
              title: Text(item['name']),
              trailing: Text('${item['points']} نقطة'),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('خطأ: $err')),
      ),
    );
  }
}