import 'session_part.dart';

class SessionPartSubmission {
  final SessionType type;
  final int suraStart;
  final int ayaStart;
  final int suraEnd;
  final int ayaEnd;
  final String? evaluation;
  final String? notes;

  const SessionPartSubmission({
    required this.type,
    required this.suraStart,
    required this.ayaStart,
    required this.suraEnd,
    required this.ayaEnd,
    this.evaluation,
    this.notes,
  });
}

class SessionSubmission {
  final String studentSupabaseId;
  final String groupSupabaseId;
  final String teacherSupabaseId;
  final DateTime sessionDate;
  final bool attended;
  final bool earlyAttendance;
  final bool earlyRecitation;
  final bool onTimeDeparture;
  final bool cumulativeDone;
  final bool skippedNew;
  final bool skippedReview;
  final List<SessionPartSubmission> parts;

  const SessionSubmission({
    required this.studentSupabaseId,
    required this.groupSupabaseId,
    required this.teacherSupabaseId,
    required this.sessionDate,
    required this.attended,
    required this.earlyAttendance,
    required this.earlyRecitation,
    required this.onTimeDeparture,
    required this.cumulativeDone,
    required this.skippedNew,
    required this.skippedReview,
    required this.parts,
  });
}