import '../models/session_result.dart';
import 'evaluation_utils.dart';
import 'session_constants.dart';

class SessionPointsCalculator {
  static SessionResult calculate({
    required List<PartInput> newParts,
    required List<PartInput> reviewParts,
    required double newTarget,
    required double reviewTarget,
    required double cumulativeTarget,
    required bool attended,
    required bool earlyAttendance,
    required bool earlyRecitation,
    required bool onTimeDeparture,
    required bool skippedNew,
    required bool skippedReview,
    required bool cumulativeDone,
  }) {
    if (!attended) {
      return const SessionResult(
        totalPoints: 0,
        attendancePoints: 0,
        earlyAttendancePoints: 0,
        earlyRecitationPoints: 0,
        departurePoints: 0,
        newPoints: 0,
        newExtraPoints: 0,
        reviewPoints: 0,
        cumulativePoints: 0,
        reviewExtraPoints: 0,
        newPages: 0,
        reviewPages: 0,
        cumulativePages: 0,
      );
    }

    final double attendancePts = SessionConstants.attendance.toDouble();  // تأكيد النوع double
    final double earlyAttPts = earlyAttendance ? SessionConstants.earlyAttendance.toDouble() : 0;
    final double earlyRecPts = earlyRecitation ? SessionConstants.earlyRecitation.toDouble() : 0;
    final double departurePts = onTimeDeparture ? SessionConstants.onTimeDeparture.toDouble() : 0;

    double newBasePoints = 0, newExtraPoints = 0, newPages = 0;
    if (!skippedNew && newTarget > 0) {
      final sortedNew = List<PartInput>.from(newParts)
        ..sort((a, b) => evaluationFactor(b.evaluation).compareTo(evaluationFactor(a.evaluation)));

      double remaining = newTarget;
      for (final part in sortedNew) {
        final factor = evaluationFactor(part.evaluation);
        final basic = part.pages.clamp(0, remaining);
        final extra = part.pages - basic;
        newBasePoints += (basic / newTarget) * SessionConstants.newBaseReward * factor;
        newExtraPoints += (extra / newTarget) * SessionConstants.newExtraReward * factor;
        remaining -= basic;
        newPages += part.pages;
      }
    }

    double reviewBasePoints = 0, cumulativePoints = 0, reviewExtraPoints = 0;
    double reviewPages = 0;
    final double effectiveCumulative = cumulativeDone ? cumulativeTarget : 0;
    final double denominator = reviewTarget + cumulativeTarget;

    if (!skippedReview && denominator > 0) {
      final sortedReview = List<PartInput>.from(reviewParts)
        ..sort((a, b) => evaluationFactor(b.evaluation).compareTo(evaluationFactor(a.evaluation)));

      double remaining = reviewTarget;
      for (final part in sortedReview) {
        final factor = evaluationFactor(part.evaluation);
        final basic = part.pages.clamp(0, remaining);
        final extra = part.pages - basic;
        reviewBasePoints += (basic / denominator) * SessionConstants.reviewAndCumulativeReward * factor;
        reviewExtraPoints += (extra / reviewTarget) * SessionConstants.reviewExtraReward * factor;
        remaining -= basic;
        reviewPages += part.pages;
      }
      cumulativePoints = (effectiveCumulative / denominator) * SessionConstants.reviewAndCumulativeReward;
    }

    final double totalPoints = attendancePts + earlyAttPts + earlyRecPts + departurePts +
        newBasePoints + newExtraPoints + reviewBasePoints + cumulativePoints + reviewExtraPoints;

    return SessionResult(
      totalPoints: totalPoints,
      attendancePoints: attendancePts,
      earlyAttendancePoints: earlyAttPts,
      earlyRecitationPoints: earlyRecPts,
      departurePoints: departurePts,
      newPoints: newBasePoints,
      newExtraPoints: newExtraPoints,
      reviewPoints: reviewBasePoints,
      cumulativePoints: cumulativePoints,
      reviewExtraPoints: reviewExtraPoints,
      newPages: newPages,
      reviewPages: reviewPages,
      cumulativePages: effectiveCumulative,
    );
  }
}

class PartInput {
  final double pages;
  final String? evaluation;
  PartInput({required this.pages, this.evaluation});
}