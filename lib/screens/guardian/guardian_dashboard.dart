import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/auth_provider.dart';
import '../../core/theme.dart';
import '../../widgets/islamic_header.dart';

final guardianStudentIdProvider = FutureProvider.family<String?, String>((ref, guardianId) async {
  // TODO: جلب الطالب المرتبط من Supabase
  return "mock_student_id";
});

class GuardianDashboard extends ConsumerWidget {
  const GuardianDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider).valueOrNull;
    if (currentUser == null) return const Center(child: CircularProgressIndicator());

    final studentIdAsync = ref.watch(guardianStudentIdProvider(currentUser.supabaseId));

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: IslamicHeader(title: 'متابعة الطالب', subtitle: 'مرحباً بك').animate().fadeIn(),
          ),
          studentIdAsync.when(
            data: (studentId) => studentId == null
                ? const SliverToBoxAdapter(child: Center(child: Text('لا يوجد طالب مرتبط')))
                : SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('آخر جلسة', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                              const SizedBox(height: 12),
                              ListTile(
                                leading: CircleAvatar(backgroundColor: AppTheme.emeraldGreen, child: const Icon(Icons.check, color: Colors.white)),
                                title: const Text('جلسة 2026-07-27'),
                                subtitle: const Text('النقاط: 10.0', style: TextStyle(color: AppTheme.warmGold)),
                              ),
                            ],
                          ),
                        ),
                      ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),
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