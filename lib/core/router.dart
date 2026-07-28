import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../screens/splash_screen.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';
import '../screens/teacher/teacher_dashboard.dart';
import '../screens/student/student_dashboard.dart';
import '../screens/guardian/guardian_dashboard.dart';
import '../screens/manager/manager_dashboard.dart';

class AppRouter {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String teacherDashboard = '/teacher-dashboard';
  static const String studentDashboard = '/student-dashboard';
  static const String guardianDashboard = '/guardian-dashboard';
  static const String managerDashboard = '/manager-dashboard';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case teacherDashboard:
        return MaterialPageRoute(builder: (_) => const TeacherDashboard());
      case studentDashboard:
        return MaterialPageRoute(builder: (_) => const StudentDashboard());
      case guardianDashboard:
        return MaterialPageRoute(builder: (_) => const GuardianDashboard());
      case managerDashboard:
        return MaterialPageRoute(builder: (_) => const ManagerDashboard());
      default:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
    }
  }
}