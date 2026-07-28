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
    // ✅ التصحيح: ref.listen بياخد AsyncValue<Session?> من StreamProvider
    ref.listen<AsyncValue<Session?>>(authStateProvider, (prev, next) {
      final session = next.value;
      final supabaseUser = session?.user;
      if (!mounted) return;
      if (supabaseUser == null) {
        Navigator.pushReplacementNamed(context, AppRouter.login);
      } else {
        Navigator.pushReplacementNamed(context, AppRouter.teacherDashboard);
      }
    });

    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
