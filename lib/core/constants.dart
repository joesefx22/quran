class AppConstants {
  static const String supabaseUrl = 'https://qqnwfcofjksvqewqukzu.supabase.co';
  static const String supabaseAnonKey = 'sb_publishable_T1SwqxxCGQLIT9p2sPW60w_yzbSSZa3';

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
}