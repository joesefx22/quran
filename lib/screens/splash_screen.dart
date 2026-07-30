import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show Session;
import '../../providers/auth_provider.dart';
import '../../core/router.dart';
import '../../services/quran_database_service.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    try {
      await QuranDatabaseService().database;
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    // توجيه إذا انتهت الجلسة
    ref.listen<AsyncValue<Session?>>(authStateProvider, (prev, next) {
      if (!mounted) return;
      if (next.value == null) {
        Navigator.pushReplacementNamed(context, AppRouter.login);
      }
    });

    // توجيه عند معرفة الدور
    ref.listen<AsyncValue<String?>>(userRoleProvider, (prev, next) {
      final role = next.value;
      if (!mounted || role == null) return;

      switch (role) {
        case 'teacher':
          Navigator.pushReplacementNamed(context, AppRouter.teacherDashboard);
          break;
        case 'student':
          Navigator.pushReplacementNamed(context, AppRouter.studentDashboard);
          break;
        case 'guardian':
          Navigator.pushReplacementNamed(context, AppRouter.guardianDashboard);
          break;
        case 'manager':
          Navigator.pushReplacementNamed(context, AppRouter.managerDashboard);
          break;
        default:
          Navigator.pushReplacementNamed(context, AppRouter.login);
      }
    });

    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}