import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../providers/manager_provider.dart';
import '../../services/supabase_config.dart';
import '../../core/theme.dart';
import '../../widgets/islamic_header.dart';
import 'student_list_screen.dart';
import 'teacher_list_screen.dart';

final teacherRegistrationStatusProvider = FutureProvider<bool>((ref) {
  return ref.read(managerProvider).getTeacherRegistrationStatus();
});

class ManagerDashboard extends ConsumerStatefulWidget {
  const ManagerDashboard({super.key});

  @override
  ConsumerState<ManagerDashboard> createState() => _ManagerDashboardState();
}

class _ManagerDashboardState extends ConsumerState<ManagerDashboard> {
  @override
  Widget build(BuildContext context) {
    final controller = ref.read(managerProvider);
    final registrationStatusAsync = ref.watch(teacherRegistrationStatusProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: IslamicHeader(title: 'لوحة المدير', subtitle: 'نظرة شاملة').animate().fadeIn(),
          ),
          SliverToBoxAdapter(child: const SizedBox(height: 16)),
          SliverToBoxAdapter(
            child: _buildStatsCards().animate().fadeIn(delay: 200.ms),
          ),
          SliverToBoxAdapter(child: const SizedBox(height: 16)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                child: Column(
                  children: [
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.emeraldGreen.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.people, color: AppTheme.emeraldGreen),
                      ),
                      title: const Text('إدارة الطلاب', style: TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: const Text('عرض وتعديل جميع الطلاب'),
                      trailing: const Icon(Icons.arrow_forward_ios_rounded, color: AppTheme.warmGold),
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StudentListScreen())),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.warmGold.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.school, color: AppTheme.warmGold),
                      ),
                      title: const Text('إدارة المعلمين', style: TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: const Text('المعلمين المسجلين'),
                      trailing: const Icon(Icons.arrow_forward_ios_rounded, color: AppTheme.warmGold),
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TeacherListScreen())),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 400.ms),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.emeraldGreen.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.settings, color: AppTheme.emeraldGreen),
                          ),
                          const SizedBox(width: 12),
                          const Text('الإعدادات', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: () async {
                          final csv = await controller.exportStudentsData();
                          if (!mounted) return;
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              content: SingleChildScrollView(child: Text(csv)),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(context), child: const Text('إغلاق')),
                              ],
                            ),
                          );
                        },
                        icon: const Icon(Icons.download),
                        label: const Text('تصدير CSV'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.emeraldGreen,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      registrationStatusAsync.when(
                        data: (isOpen) => SwitchListTile(
                          title: const Text('فتح تسجيل المعلمين'),
                          value: isOpen,
                          activeColor: AppTheme.emeraldGreen,
                          onChanged: (v) async {
                            try {
                              await controller.toggleTeacherRegistration(v);
                              ref.invalidate(teacherRegistrationStatusProvider);
                            } catch (e) {
                              if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('فشل تغيير الإعدادات')));
                            }
                          },
                        ),
                        loading: () => const LinearProgressIndicator(),
                        error: (_, __) => const Text('خطأ في جلب الإعدادات'),
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(delay: 600.ms),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
    return FutureBuilder<Map<String, int>>(
      future: _fetchStats(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final stats = snapshot.data!;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: _statCard('الطلاب', stats['students'] ?? 0, Icons.people, AppTheme.emeraldGreen),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _statCard('المعلمين', stats['teachers'] ?? 0, Icons.school, AppTheme.warmGold),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _statCard(String title, int count, IconData icon, Color color) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(icon, size: 36, color: color),
            const SizedBox(height: 8),
            Text(count.toString(), style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color)),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Future<Map<String, int>> _fetchStats() async {
    try {
      final studentRes = await SupabaseConfig.client
          .from('users')
          .select('*', const FetchOptions(count: CountOption.exact))
          .eq('role', 'student');
      final teacherRes = await SupabaseConfig.client
          .from('users')
          .select('*', const FetchOptions(count: CountOption.exact))
          .eq('role', 'teacher');
      return {
        'students': studentRes.count ?? 0,
        'teachers': teacherRes.count ?? 0,
      };
    } catch (_) {
      return {'students': 0, 'teachers': 0};
    }
  }
}