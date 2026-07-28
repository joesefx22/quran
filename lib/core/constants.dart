class AppConstants {
  static const String supabaseUrl = 'https://amxlmcxbncdnwexnwgdd.supabase.co';
  static const String supabaseAnonKey = 'sb_publishable_aPPgdRGk4a1g_j_JFE6Zow_fGHeT-m4';

  static const String tableMosques = 'mosques';
  static const String tableGroups = 'groups';
  static const String tableUsers = 'users';
  static const String tableStudentProfiles = 'student_profiles';
  static const String tableQuranMeta = 'quran_metadata';
  static const String tableSessions = 'sessions';
  static const String tableSessionParts = 'session_parts';

  static const List<int> halaqaDays = [
    DateTime.saturday,
    DateTime.sunday,
    DateTime.monday,
    DateTime.tuesday,
    DateTime.wednesday
  ];

  static const double baseAttendancePoints = 2.0;
  static const double earlyAttendanceBonus = 2.0;
  static const double onTimeDepartureBonus = 2.0;
  static const double earlyRecitationBonus = 2.0;
  static const double completionNewPoints = 4.0;
  static const double extraNewPointsPer5 = 6.0;
  static const double completionCumulativeReviewPoints = 6.0;
  static const double extraReviewPointsPer50 = 8.0;
} 