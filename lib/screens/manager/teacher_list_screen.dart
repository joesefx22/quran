import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../services/supabase_config.dart';
import '../../models/local_user.dart';
import '../../core/theme.dart';

final allTeachersProvider = FutureProvider<List<LocalUser>>((ref) async {
  final data = await SupabaseConfig.client.from('users').select('*').eq('role', 'teacher');
  return data.map<LocalUser>((json) => LocalUser()
    ..supabaseId = json['id']
    ..fullName = json['full_name'] ?? ''
    ..email = json['email'] ?? ''
    ..role = 'teacher'
    ..groupSupabaseId = json['group_id']
    ..mosqueSupabaseId = json['mosque_id']
  ).toList();
});

class TeacherListScreen extends ConsumerWidget {
  const TeacherListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final teachersAsync = ref.watch(allTeachersProvider);

    return Scaffold(
      body: teachersAsync.when(
        data: (teachers) => ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: teachers.length,
          itemBuilder: (context, index) {
            final teacher = teachers[index];
            return Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppTheme.warmGold,
                  child: Text(teacher.fullName.isNotEmpty ? teacher.fullName[0] : '?', style: const TextStyle(color: Colors.white)),
                ),
                title: Text(teacher.fullName, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(teacher.email),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteTeacher(context, ref, teacher.supabaseId),
                ),
              ),
            ).animate().fadeIn(delay: (50 * index).ms).slideX(begin: 0.05, end: 0);
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('خطأ: $e')),
      ),
    );
  }

  Future<void> _deleteTeacher(BuildContext context, WidgetRef ref, String userId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('حذف المعلم'),
        content: const Text('سيتم حذف المعلم نهائياً. متابعة؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('إلغاء')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('حذف', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm == true) {
      await SupabaseConfig.client.from('users').delete().eq('id', userId);
      ref.invalidate(allTeachersProvider);
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم حذف المعلم')));
    }
  }
}