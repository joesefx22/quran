import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/router.dart';
import '../../core/theme.dart';
import '../../models/local_user.dart';
import '../../providers/app_state_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/quran_database_service.dart';
import '../complete_profile_screen.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await QuranDatabaseService().database;
    });
  }

  void _navigate(AppState state) {
    if (_navigated || !mounted) return;
    _navigated = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      switch (state) {
        case AppState.unauthenticated:
          Navigator.pushReplacementNamed(context, AppRouter.login);
          break;
        case AppState.incompleteProfile:
          final user = ref.read(currentUserProvider).valueOrNull;
          if (user == null) { _navigated = false; return; }
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => CompleteProfileScreen(
                userId: user.supabaseId,
                email: user.email,
                fullName: user.fullName,
                role: user.role,
              ),
            ),
          );
          break;
        case AppState.teacher:
          Navigator.pushReplacementNamed(context, AppRouter.teacherDashboard);
          break;
        case AppState.student:
          Navigator.pushReplacementNamed(context, AppRouter.studentDashboard);
          break;
        case AppState.guardian:
          Navigator.pushReplacementNamed(context, AppRouter.guardianDashboard);
          break;
        case AppState.manager:
          Navigator.pushReplacementNamed(context, AppRouter.managerDashboard);
          break;
        case AppState.loading:
          _navigated = false;
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<AppState>>(appStateProvider, (prev, next) {
      next.whenData((state) {
        if (state != AppState.loading) _navigate(state);
      });
    });

    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF000000) : AppTheme.ivory,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.emeraldGreen.withOpacity(0.1),
                border: Border.all(
                  color: AppTheme.warmGold.withOpacity(0.4),
                  width: 2,
                ),
              ),
              child: SvgPicture.asset(
                'assets/icons/quran_icon.svg',
                width: 80,
                height: 80,
                colorFilter: const ColorFilter.mode(AppTheme.warmGold, BlendMode.srcIn),
              ),
            ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
            const SizedBox(height: 30),
            Text(
              'حلقة القرآن',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppTheme.darkSlate,
                  ),
            ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),
            const SizedBox(height: 40),
            SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.warmGold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}