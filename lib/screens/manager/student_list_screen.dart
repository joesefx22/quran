import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../services/supabase_config.dart';
import '../../models/local_user.dart';
import '../../models/student_profile.dart';
import '../../widgets/student_edit_dialog.dart';
import '../../core/theme.dart';
import 'student_details_screen.dart';

final allStudentsProvider = FutureProvider<List<LocalUser>>((ref) async {
  final data = await SupabaseConfig.client.from('users').select('*').eq('role', 'student');
  return data.map<LocalUser>((json) => LocalUser()
    ..supabaseId = json['id']
    ..fullName = json['full_name'] ?? ''
    ..email = json['email'] ?? ''
    ..role = 'student'
    ..groupSupabaseId = json['group_id']
    ..mosqueSupabaseId = json['mosque_id']
  ).toList();
});

class StudentListScreen extends ConsumerWidget {
  const StudentListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studentsAsync = ref.watch(allStudentsProvider);

    return Scaffold(
      body: studentsAsync.when(
        data: (students) => ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: students.length,
          itemBuilder: (context, index) {
            final student = students[index];
            return Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppTheme.emeraldGreen,
                  child: Text(student.fullName.isNotEmpty ? student.fullName[0] : '?', style: const TextStyle(color: Colors.white)),
                ),
                title: Text(student.fullName, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(student.email),
                trailing: PopupMenuButton<String>(
                  onSelected: (action) async {
                    switch (action) {
                      case 'editWord':
                        await _editWord(context, ref, student.supabaseId);
                        break;
                      case 'convertToTeacher':
                        await _convertToTeacher(context, ref, student.supabaseId);
                        break;
                      case 'delete':
                        await _deleteStudent(context, ref, student.supabaseId);
                        break;
                      case 'details':
                        Navigator.push(context, MaterialPageRoute(builder: (_) => StudentDetailsScreen(studentId: student.supabaseId)));
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'details', child: Text('تفاصيل')),
                    const PopupMenuItem(value: 'editWord', child: Text('تعديل الورد')),
                    const PopupMenuItem(value: 'convertToTeacher', child: Text('تحويل إلى شيخ')),
                    const PopupMenuItem(value: 'delete', child: Text('حذف الطالب', style: TextStyle(color: Colors.red))),
                  ],
                ),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => StudentDetailsScreen(studentId: student.supabaseId))),
              ),
            ).animate().fadeIn(delay: (50 * index).ms).slideX(begin: 0.05, end: 0);
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('خطأ: $e')),
      ),
    );
  }

  Future<void> _editWord(BuildContext context, WidgetRef ref, String userId) async {
    final data = await SupabaseConfig.client.from('student_profiles').select().eq('user_id', userId).maybeSingle();
    if (data == null) return;
    final profile = StudentProfile()
      ..userSupabaseId = userId
      ..newPagesTarget = data['new_pages_target']
      ..reviewPagesTarget = data['review_pages_target'];
    if (!context.mounted) return;
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => StudentEditDialog(
        profile: profile,
        onSave: (newTarget, reviewTarget) async {
          await SupabaseConfig.client.from('student_profiles').update({
            'new_pages_target': newTarget,
            'review_pages_target': reviewTarget,
            'updated_at': DateTime.now().toIso8601String(),
          }).eq('user_id', userId);
        },
      ),
    );
    if (result == true) ref.invalidate(allStudentsProvider);
  }

  Future<void> _convertToTeacher(BuildContext context, WidgetRef ref, String userId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('تحويل إلى شيخ'),
        content: const Text('سيتم تغيير دور المستخدم إلى معلم. متابعة؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('إلغاء')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('تحويل')),
        ],
      ),
    );
    if (confirm == true) {
      await SupabaseConfig.client.from('users').update({'role': 'teacher'}).eq('id', userId);
      ref.invalidate(allStudentsProvider);
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم التحويل إلى شيخ')));
    }
  }

  Future<void> _deleteStudent(BuildContext context, WidgetRef ref, String userId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('حذف الطالب'),
        content: const Text('لا يمكن التراجع عن هذا الإجراء. متابعة؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('إلغاء')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('حذف', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm == true) {
      await SupabaseConfig.client.from('users').delete().eq('id', userId);
      ref.invalidate(allStudentsProvider);
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم حذف الطالب')));
    }
  }
}