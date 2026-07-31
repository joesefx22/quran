import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/services.dart';
import '../../providers/teacher_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/local_user.dart';
import '../../models/student_profile.dart';
import '../../widgets/student_card.dart';
import '../../widgets/student_edit_dialog.dart';
import '../../services/supabase_config.dart';
import 'session_form.dart';
import '../../core/theme.dart';
import '../../widgets/empty_state.dart'; // أو مسار الـ EmptyState widget عندك

final groupStudentsProvider = FutureProvider.family<List<LocalUser>, String>((ref, groupId) {
  return ref.read(teacherProvider).getGroupStudents(groupId);
});

class DaySessionList extends ConsumerWidget {
  const DaySessionList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final teacher = ref.watch(currentUserProvider).valueOrNull;
    final groupId = teacher?.groupSupabaseId ?? '';
    final studentsAsync = ref.watch(groupStudentsProvider(groupId));

    return Scaffold(
      body: studentsAsync.when(
        data: (students) {
          if (students.isEmpty) {
            return Center(   // تم إزالة const من هنا
              child: EmptyState(
                  message: 'لا يوجد طلاب في مجموعتك حالياً.',
                  icon: Icons.sentiment_neutral),
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(groupStudentsProvider(groupId)),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: students.length,
              itemBuilder: (context, index) => _buildStudentItem(context, ref, students[index], teacher!, index),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('خطأ: $err')),
      ),
    );
  }

  Widget _buildStudentItem(BuildContext context, WidgetRef ref, LocalUser student, LocalUser teacher, int index) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SessionForm(
              student: student,
              teacherId: teacher.supabaseId,
              groupId: teacher.groupSupabaseId ?? '',
            ),
          ),
        );
      },
      onLongPress: () {
        HapticFeedback.mediumImpact();
        _showEditWordDialog(context, student);
      },
      child: StudentCard(
        student: student,
        attendancePercent: 100,
        onTap: null,
        index: index,
      ).animate().fadeIn(delay: (50 * index).ms).slideX(begin: 0.05, end: 0),
    );
  }

  void _showEditWordDialog(BuildContext context, LocalUser student) async {
    final data = await SupabaseConfig.client.from('student_profiles').select().eq('user_id', student.supabaseId).maybeSingle();
    if (data == null) return;
    final profile = StudentProfile()
      ..userSupabaseId = student.supabaseId
      ..newPagesTarget = data['new_pages_target']
      ..reviewPagesTarget = data['review_pages_target'];

    if (!context.mounted) return;
    showDialog(
      context: context,
      builder: (_) => StudentEditDialog(
        profile: profile,
        onSave: (newTarget, reviewTarget) async {
          await SupabaseConfig.client.from('student_profiles').update({
            'new_pages_target': newTarget,
            'review_pages_target': reviewTarget,
            'updated_at': DateTime.now().toIso8601String(),
          }).eq('user_id', student.supabaseId);
        },
      ),
    );
  }
}