import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/manager_provider.dart';

final exportLoadingProvider = StateProvider<bool>((ref) => false);
final teacherRegistrationStatusProvider = FutureProvider<bool>((ref) {
  return ref.read(managerProvider).getTeacherRegistrationStatus();
});

class ManagerDashboard extends ConsumerStatefulWidget {
  const ManagerDashboard({super.key});

  @override
  ConsumerState<ManagerDashboard> createState() => _ManagerDashboardState();
}

class _ManagerDashboardState extends ConsumerState<ManagerDashboard> {
  bool? _localRegistrationStatus;

  @override
  Widget build(BuildContext context) {
    final controller = ref.read(managerProvider);
    final isLoading = ref.watch(exportLoadingProvider);
    final registrationStatusAsync = ref.watch(teacherRegistrationStatusProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('لوحة المدير')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ElevatedButton(
            onPressed: isLoading
                ? null
                : () async {
                    ref.read(exportLoadingProvider.notifier).state = true;
                    try {
                      final csv = await controller.exportStudentsData();
                      if (!context.mounted) return;
                      showDialog(context: context, builder: (_) => AlertDialog(
                        content: SingleChildScrollView(child: Text(csv)),
                        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('إغلاق'))],
                      ));
                    } finally {
                      ref.read(exportLoadingProvider.notifier).state = false;
                    }
                  },
            child: isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('تصدير بيانات الطلاب (CSV)'),
          ),
          const Divider(),
          registrationStatusAsync.when(
            data: (isOpen) {
              final currentValue = _localRegistrationStatus ?? isOpen;
              return SwitchListTile(
                title: const Text('فتح تسجيل المعلمين'),
                value: currentValue,
                onChanged: (v) async {
                  setState(() => _localRegistrationStatus = v);
                  try {
                    await controller.toggleTeacherRegistration(v);
                  } catch (e) {
                    if (mounted) {
                      setState(() => _localRegistrationStatus = currentValue);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('فشل تغيير الإعدادات')));
                    }
                  }
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => const Text('حدث خطأ في جلب إعدادات التسجيل'),
          ),
        ],
      ),
    );
  }
}