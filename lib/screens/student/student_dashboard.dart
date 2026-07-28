import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../providers/student_provider.dart';
import '../../models/student_profile.dart';
import 'leaderboard.dart';

final studentProfileProvider = FutureProvider.family<StudentProfile?, String>((ref, userId) {
  return ref.read(studentProvider).getMyProfile(userId);
});

class StudentDashboard extends ConsumerWidget {
  const StudentDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // استخدام currentUserProvider بدلاً من authStateProvider المباشر
    final localUser = ref.watch(currentUserProvider).valueOrNull;
    if (localUser == null) return const Center(child: CircularProgressIndicator());

    final profileAsync = ref.watch(studentProfileProvider(localUser.supabaseId));

    return Scaffold(
      appBar: AppBar(title: const Text('حلقة القرآن')),
      body: profileAsync.when(
        data: (profile) => Column(
          children: [
            if (profile != null) Card(
              child: ListTile(
                title: Text('ورد الحفظ: ${profile.newPagesTarget} صفحات'),
                subtitle: Text('ورد المراجعة: ${profile.reviewPagesTarget} صفحات'),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LeaderboardScreen())),
              child: const Text('المتصدرون'),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('خطأ: $err')),
      ),
    );
  }
}