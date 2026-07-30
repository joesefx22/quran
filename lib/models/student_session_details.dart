class StudentSessionDetails {
  final String sessionId;
  final DateTime sessionDate;
  final double totalPoints;
  final double attendancePoints;
  final double earlyAttendancePoints;
  final double earlyRecitationPoints;
  final double departurePoints;
  final double memorizationPoints;
  final double memorizationExtraPoints;
  final double reviewPoints;
  final double reviewExtraPoints;
  final double cumulativePoints;
  final double memorizationPages;
  final double reviewPages;
  final double cumulativePages;

  StudentSessionDetails({
    required this.sessionId,
    required this.sessionDate,
    required this.totalPoints,
    required this.attendancePoints,
    required this.earlyAttendancePoints,
    required this.earlyRecitationPoints,
    required this.departurePoints,
    required this.memorizationPoints,
    required this.memorizationExtraPoints,
    required this.reviewPoints,
    required this.reviewExtraPoints,
    required this.cumulativePoints,
    required this.memorizationPages,
    required this.reviewPages,
    required this.cumulativePages,
  });
}