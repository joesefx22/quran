import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/services.dart';                  // تمت الإضافة
import '../../models/local_user.dart';
import '../../models/student_profile.dart';
import '../../models/student_week_stats.dart';
import '../../models/student_session_details.dart';
import '../../providers/auth_provider.dart';
import '../../providers/student_provider.dart';
import '../../core/theme.dart';
import '../../widgets/islamic_header.dart';
import 'leaderboard.dart';

final profileProvider = FutureProvider.family<StudentProfile?, String>(
  (ref, id) => ref.read(studentProvider).getMyProfile(id),
);

final weekStatsProvider = FutureProvider.family<StudentWeekStats, ({String id, String group})>(
  (ref, data) async {
    final start = ref.read(studentProvider).getWeekStart(DateTime.now());
    return ref.read(studentProvider).getStudentWeekStats(data.id, data.group, start);
  },
);

final sessionsProvider = FutureProvider.family<List<StudentSessionDetails>, String>(
  (ref, id) async {
    final start = ref.read(studentProvider).getWeekStart(DateTime.now());
    return ref.read(studentProvider).getStudentSessionsDetails(id, start);
  },
);

class StudentDashboard extends ConsumerWidget {
  const StudentDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).valueOrNull;
    if (user == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final profile = ref.watch(profileProvider(user.supabaseId));
    final stats = ref.watch(weekStatsProvider((id: user.supabaseId, group: user.groupSupabaseId ?? '')));
    final sessions = ref.watch(sessionsProvider(user.supabaseId));

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: IslamicHeader(
              title: 'مرحباً ${user.fullName.split(' ').first}',
              subtitle: 'تابع رحلتك مع القرآن',
            ).animate().fadeIn(),
          ),
          SliverToBoxAdapter(child: const SizedBox(height: 16)),
          SliverToBoxAdapter(
            child: stats.when(
              data: (st) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 42,
                          backgroundColor: AppTheme.emeraldGreen,
                          child: Text(
                            user.fullName.isNotEmpty ? user.fullName[0] : '?',
                            style: const TextStyle(fontSize: 32, color: Colors.white),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          user.fullName,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppTheme.warmGold.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'الترتيب الأسبوعي: #${st.rank}',
                            style: TextStyle(color: AppTheme.warmGold, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _statChip('النقاط', '${st.totalPoints.toStringAsFixed(1)}', Icons.stars_rounded),
                            _statChip('الجلسات', '${st.sessionsCount}', Icons.calendar_today_rounded),
                            _statChip('المتوسط', '${st.averagePoints.toStringAsFixed(1)}', Icons.show_chart_rounded),
                          ],
                        ),
                      ],
                    ),
                  ),
                ).animate().fadeIn(delay: 150.ms).slideY(begin: 0.1, end: 0),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('خطأ: $e'),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Text('ورد الحفظ', style: Theme.of(context).textTheme.headlineMedium),
            ),
          ),
          SliverToBoxAdapter(
            child: profile.when(
              data: (p) => p == null
                  ? const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('لا توجد بيانات'),
                    )
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  children: [
                                    const Icon(Icons.book, color: AppTheme.emeraldGreen, size: 32),
                                    const SizedBox(height: 8),
                                    Text('${p.newPagesTarget} صفحات', style: Theme.of(context).textTheme.headlineMedium),
                                    const Text('جديد'),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  children: [
                                    const Icon(Icons.refresh, color: AppTheme.warmGold, size: 32),
                                    const SizedBox(height: 8),
                                    Text('${p.reviewPagesTarget} صفحات', style: Theme.of(context).textTheme.headlineMedium),
                                    const Text('مراجعة'),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ).animate().fadeIn(delay: 300.ms),
                    ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('خطأ: $e'),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Text('الجلسات الأخيرة', style: Theme.of(context).textTheme.headlineMedium),
            ),
          ),
          sessions.when(
            data: (list) => list.isEmpty
                ? const SliverToBoxAdapter(child: Center(child: Text('لا توجد جلسات بعد')))
                : SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final s = list[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          child: Card(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            child: ExpansionTile(
                              leading: CircleAvatar(
                                backgroundColor: AppTheme.emeraldGreen.withOpacity(0.1),
                                child: Text('${s.totalPoints.toStringAsFixed(0)}', style: const TextStyle(color: AppTheme.emeraldGreen, fontWeight: FontWeight.bold)),
                              ),
                              title: Text('${s.memorizationPages} صفحة حفظ', style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
                              subtitle: Text(s.sessionDate.toString().substring(0, 10), style: TextStyle(color: AppTheme.warmGold)),
                              children: [
                                _pointRow('الحضور', s.attendancePoints),
                                _pointRow('الحضور المبكر', s.earlyAttendancePoints),
                                _pointRow('التسميع المبكر', s.earlyRecitationPoints),
                                _pointRow('الانصراف', s.departurePoints),
                                _pointRow('الجديد', s.memorizationPoints),
                                _pointRow('الجديد الإضافي', s.memorizationExtraPoints),
                                _pointRow('المراجعة', s.reviewPoints),
                                _pointRow('المراجعة الإضافية', s.reviewExtraPoints),
                                _pointRow('التراكمي', s.cumulativePoints),
                              ],
                            ),
                          ).animate().fadeIn(delay: (40 * index).ms),
                        );
                      },
                      childCount: list.length,
                    ),
                  ),
            loading: () => const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator())),
            error: (e, _) => SliverToBoxAdapter(child: Text('خطأ: $e')),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: () {
                    HapticFeedback.mediumImpact();       // الآن معرفة
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const LeaderboardScreen()));
                  },
                  icon: const Icon(Icons.leaderboard, color: Colors.white),
                  label: const Text('المتصدرون', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.emeraldGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    elevation: 4,
                  ),
                ),
              ).animate().fadeIn(delay: 500.ms),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statChip(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.emeraldGreen, size: 28),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _pointRow(String title, double value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(title)),
          Text(value.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}