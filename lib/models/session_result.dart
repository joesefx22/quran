class SessionResult {
  final double totalPoints;
  final double attendancePoints;
  final double earlyAttendancePoints;
  final double earlyRecitationPoints;
  final double departurePoints;
  final double newPoints;
  final double newExtraPoints;
  final double reviewPoints;
  final double cumulativePoints;
  final double reviewExtraPoints;
  final double newPages;
  final double reviewPages;
  final double cumulativePages;

  const SessionResult({
    required this.totalPoints,
    required this.attendancePoints,
    required this.earlyAttendancePoints,
    required this.earlyRecitationPoints,
    required this.departurePoints,
    required this.newPoints,
    required this.newExtraPoints,
    required this.reviewPoints,
    required this.cumulativePoints,
    required this.reviewExtraPoints,
    required this.newPages,
    required this.reviewPages,
    required this.cumulativePages,
  });
}