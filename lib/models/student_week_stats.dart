class StudentWeekStats {
  final int rank;
  final double totalPoints;
  final int sessionsCount;
  final double memorizationPages;
  final double reviewPages;
  final double cumulativePages;
  final double averagePoints;
  final double bestSession;
  final int earlyAttendanceCount;
  final int earlyRecitationCount;
  final int onTimeDepartureCount;

  const StudentWeekStats({
    required this.rank,
    required this.totalPoints,
    required this.sessionsCount,
    required this.memorizationPages,
    required this.reviewPages,
    required this.cumulativePages,
    required this.averagePoints,
    required this.bestSession,
    required this.earlyAttendanceCount,
    required this.earlyRecitationCount,
    required this.onTimeDepartureCount,
  });
}