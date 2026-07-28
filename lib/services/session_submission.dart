import 'session_part.dart';

class SessionPartSubmission {
  final SessionType type;
  final int suraStart;
  final int ayaStart;
  final int suraEnd;
  final int ayaEnd;
  final bool isExtra;
  final String? evaluation;
  final String? notes;

  SessionPartSubmission({
    required this.type,
    required this.suraStart,
    required this.ayaStart,
    required this.suraEnd,
    required this.ayaEnd,
    this.isExtra = false,
    this.evaluation,
    this.notes,
  });
}

class SessionSubmission {
  final String studentSupabaseId;
  final String groupSupabaseId;
  final String teacherSupabaseId;
  final DateTime sessionDate;
  final List<SessionPartSubmission> parts;
  final bool earlyAttendance;
  final bool onTimeDeparture;
  final bool earlyRecitation;
  final bool cumulativeDone;

  SessionSubmission({
    required this.studentSupabaseId,
    required this.groupSupabaseId,
    required this.teacherSupabaseId,
    required this.sessionDate,
    required this.parts,
    this.earlyAttendance = false,
    this.onTimeDeparture = false,
    this.earlyRecitation = false,
    this.cumulativeDone = false,
  });
}