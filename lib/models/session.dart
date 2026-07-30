class Session {
  int id = 0;
  String? supabaseId;
  late String studentSupabaseId;
  late String teacherSupabaseId;
  late String groupSupabaseId;
  late DateTime sessionDate;

  bool attended = true;
  bool earlyAttendance = false;
  bool earlyRecitation = false;
  bool onTimeDeparture = false;
  bool cumulativeDone = false;
  bool skippedNew = false;
  bool skippedReview = false;

  double newPages = 0;
  double reviewPages = 0;
  double cumulativePages = 0;

  double newPoints = 0;
  double reviewPoints = 0;
  double cumulativePoints = 0;
  double extraNewPoints = 0;
  double extraReviewPoints = 0;
  double attendancePoints = 0;
  double totalPoints = 0;

  bool isSynced = false;
  DateTime? createdAt;
}