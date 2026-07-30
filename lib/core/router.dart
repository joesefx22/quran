import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../screens/splash_screen.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';
import '../screens/complete_profile_screen.dart';
import '../screens/teacher/teacher_dashboard.dart';
import '../screens/teacher/day_session_list.dart';
import '../screens/teacher/session_form.dart';
import '../screens/student/student_dashboard.dart';
import '../screens/student/leaderboard.dart';
import '../screens/guardian/guardian_dashboard.dart';
import '../screens/manager/manager_dashboard.dart';
import '../screens/manager/student_list_screen.dart';
import '../screens/manager/student_details_screen.dart';
import '../screens/manager/teacher_list_screen.dart';

class AppRouter {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String completeProfile = '/complete-profile';
  static const String teacherDashboard = '/teacher-dashboard';
  static const String daySessionList = '/day-session-list';
  static const String sessionForm = '/session-form';
  static const String studentDashboard = '/student-dashboard';
  static const String leaderboard = '/leaderboard';
  static const String guardianDashboard = '/guardian-dashboard';
  static const String managerDashboard = '/manager-dashboard';
  static const String studentList = '/student-list';
  static const String studentDetails = '/student-details';
  static const String teacherList = '/teacher-list';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case completeProfile:
        final args = settings.arguments;
        if (args is Map<String, dynamic>) {
          return MaterialPageRoute(
            builder: (_) => CompleteProfileScreen(
              userId: args['userId'] ?? '',
              email: args['email'] ?? '',
              fullName: args['fullName'] ?? '',
              role: args['role'] ?? '',
            ),
          );
        }
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case teacherDashboard:
        return MaterialPageRoute(builder: (_) => const TeacherDashboard());
      case daySessionList:
        return MaterialPageRoute(builder: (_) => const DaySessionList());
      case sessionForm:
        final args = settings.arguments;
        if (args is Map<String, dynamic>) {
          return MaterialPageRoute(
            builder: (_) => SessionForm(
              student: args['student'],
              teacherId: args['teacherId'] ?? '',
              groupId: args['groupId'] ?? '',
            ),
          );
        }
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case studentDashboard:
        return MaterialPageRoute(builder: (_) => const StudentDashboard());
      case leaderboard:
        return MaterialPageRoute(builder: (_) => const LeaderboardScreen());
      case guardianDashboard:
        return MaterialPageRoute(builder: (_) => const GuardianDashboard());
      case managerDashboard:
        return MaterialPageRoute(builder: (_) => const ManagerDashboard());
      case studentList:
        return MaterialPageRoute(builder: (_) => const StudentListScreen());
      case studentDetails:
        final studentId = settings.arguments as String?;
        if (studentId != null) {
          return MaterialPageRoute(
            builder: (_) => StudentDetailsScreen(studentId: studentId),
          );
        }
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case teacherList:
        return MaterialPageRoute(builder: (_) => const TeacherListScreen());
      default:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
    }
  }
}