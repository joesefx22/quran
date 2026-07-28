import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../utils/helpers.dart';

final guardianStudentIdProvider = FutureProvider.family<String?, String>((ref, guardianSupabaseId) async {
  // TODO: Isar frozen – إرجاع student وهمي
  return "mock_student_id";
});

class GuardianDashboard extends ConsumerWidget {
  const GuardianDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // استخدام currentUserProvider للحصول على LocalUser
    final currentUser = ref.watch(currentUserProvider).valueOrNull;
    if (currentUser == null) return const Center(child: CircularProgressIndicator());

    final studentIdAsync = ref.watch(guardianStudentIdProvider(currentUser.supabaseId));

    return Scaffold(
      appBar: AppBar(title: const Text('متابعة الطالب')),
      body: studentIdAsync.when(
        data: (studentId) {
          if (studentId == null) return const Center(child: Text('لا يوجد طالب مرتبط'));
          return ListView(
            children: const [
              ListTile(title: Text('جلسة 2026-07-27'), subtitle: Text('النقاط: 10.0')),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('خطأ: $err')),
      ),
    );
  }
}