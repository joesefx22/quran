import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/teacher_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/user.dart';
import '../../widgets/student_card.dart';
import '../../utils/helpers.dart';
import 'session_form.dart';

final groupStudentsProvider = FutureProvider.family<List<User>, String>((ref, groupId) {
  return ref.read(teacherProvider).getGroupStudents(groupId);
});

class DaySessionList extends ConsumerWidget {
  const DaySessionList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final teacher = ref.watch(authStateProvider).value;
    final groupId = teacher?.groupSupabaseId ?? '';

    final studentsAsync = ref.watch(groupStudentsProvider(groupId));

    return Scaffold(
      appBar: AppBar(title: const Text('حلقة اليوم - قائمة الطلاب')),
      body: studentsAsync.when(
        data: (students) {
          if (students.isEmpty) {
            return const Center(child: Text('لا يوجد طلاب في مجموعتك حالياً.'));
          }
          final isWide = MediaQuery.of(context).size.width > 600;
          if (isWide) {
            return GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 300,
                childAspectRatio: 3,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: students.length,
              itemBuilder: (context, index) => _StudentCardWrapper(student: students[index]),
            );
          }
          return ListView.builder(
            itemCount: students.length,
            itemBuilder: (context, index) => _StudentCardWrapper(student: students[index]),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('خطأ: $err')),
      ),
    );
  }
}

class _StudentCardWrapper extends ConsumerWidget {
  final User student;
  const _StudentCardWrapper({required this.student});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final weekStart = Helpers.getWeekStart(now);
    // جلب الحضور الحقيقي من قواعد البيانات
    final attendanceAsync = ref.watch(studentAttendanceProvider((studentId: student.supabaseId, weekStart: weekStart)));

    return attendanceAsync.when(
      data: (percent) => StudentCard(
        student: student,
        attendancePercent: percent,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SessionForm(student: student),
            ),
          );
        },
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => StudentCard(student: student, attendancePercent: 0),
    );
  }
}