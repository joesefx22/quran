import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../services/supabase_config.dart';
import '../../models/student_profile.dart';
import '../../widgets/student_edit_dialog.dart';
import '../../core/theme.dart';

final studentDetailsProvider = FutureProvider.family<Map<String, dynamic>?, String>((ref, userId) async {
  final user = await SupabaseConfig.client.from('users').select('*').eq('id', userId).maybeSingle();
  return user;
});

final studentProfileDetailsProvider = FutureProvider.family<StudentProfile?, String>((ref, userId) async {
  final data = await SupabaseConfig.client.from('student_profiles').select().eq('user_id', userId).maybeSingle();
  if (data == null) return null;
  return StudentProfile()
    ..userSupabaseId = userId
    ..newPagesTarget = data['new_pages_target']
    ..reviewPagesTarget = data['review_pages_target'];
});

class StudentDetailsScreen extends ConsumerWidget {
  final String studentId;
  const StudentDetailsScreen({super.key, required this.studentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(studentDetailsProvider(studentId));
    final profileAsync = ref.watch(studentProfileDetailsProvider(studentId));

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 120,
            backgroundColor: AppTheme.emeraldGreen,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              title: userAsync.when(
                data: (user) => Text(user?['full_name'] ?? 'تفاصيل الطالب', style: const TextStyle(fontWeight: FontWeight.bold)),
                loading: () => const Text('تفاصيل الطالب'),
                error: (e, _) => const Text('خطأ'),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.emeraldGreen, Color(0xFF03885E)],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                ),
                child: const Center(child: Icon(Icons.person, size: 48, color: Colors.white)),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: userAsync.when(
              data: (user) => user == null
                  ? const Center(child: Text('الطالب غير موجود'))
                  : Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Card(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                children: [
                                  Text(user['email'] ?? '', style: Theme.of(context).textTheme.bodyLarge),
                                  const SizedBox(height: 8),
                                  Text('العمر: ${user['age'] ?? 'غير محدد'}'),
                                ],
                              ),
                            ),
                          ).animate().fadeIn(delay: 100.ms),
                          const SizedBox(height: 16),
                          profileAsync.when(
                            data: (profile) => profile == null
                                ? const Card(child: Padding(padding: EdgeInsets.all(16), child: Text('لا يوجد ملف')))
                                : Card(
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                                    child: Padding(
                                      padding: const EdgeInsets.all(20),
                                      child: Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              const Text('ورد الحفظ', style: TextStyle(fontWeight: FontWeight.bold)),
                                              Text('${profile.newPagesTarget} صفحات', style: TextStyle(color: AppTheme.emeraldGreen)),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              const Text('ورد المراجعة', style: TextStyle(fontWeight: FontWeight.bold)),
                                              Text('${profile.reviewPagesTarget} صفحات', style: TextStyle(color: AppTheme.warmGold)),
                                            ],
                                          ),
                                          const SizedBox(height: 12),
                                          Align(
                                            alignment: Alignment.centerLeft,
                                            child: TextButton.icon(
                                              onPressed: () => _editWord(context, ref, profile),
                                              icon: const Icon(Icons.edit, color: AppTheme.emeraldGreen),
                                              label: const Text('تعديل الورد'),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ).animate().fadeIn(delay: 200.ms),
                            loading: () => const CircularProgressIndicator(),
                            error: (e, _) => Text('خطأ: $e'),
                          ),
                        ],
                      ),
                    ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('خطأ: $e')),
            ),
          ),
        ],
      ),
    );
  }

  void _editWord(BuildContext context, WidgetRef ref, StudentProfile profile) {
    showDialog(
      context: context,
      builder: (_) => StudentEditDialog(
        profile: profile,
        onSave: (newTarget, reviewTarget) async {
          await SupabaseConfig.client.from('student_profiles').update({
            'new_pages_target': newTarget,
            'review_pages_target': reviewTarget,
            'updated_at': DateTime.now().toIso8601String(),
          }).eq('user_id', studentId);
          ref.invalidate(studentProfileDetailsProvider(studentId));
        },
      ),
    );
  }
}