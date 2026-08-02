import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/session_result.dart';
import '../models/session_submission.dart';
import '../models/student_profile.dart';
import '../models/session_part.dart';
import '../services/quran_database_service.dart';
import '../utils/session_points_calculator.dart';

class SessionService {
  final SupabaseClient _client;
  final QuranDatabaseService _quranDb;

  SessionService({required SupabaseClient supabaseClient, required QuranDatabaseService quranDb})
      : _client = supabaseClient,
        _quranDb = quranDb;

  Future<SessionResult> submitFullSession(SessionSubmission submission) async {
    final profile = await _getStudentProfile(submission.studentSupabaseId);
    final newTarget = profile.newPagesTarget.toDouble();
    final reviewTarget = profile.reviewPagesTarget.toDouble();

    final newPartInputs = <PartInput>[];
    final reviewPartInputs = <PartInput>[];

    // إذا فشل حساب الصفحات هنا سيتم رمي استثناء ويتوقف الحفظ
    for (final part in submission.parts) {
      final pages = await _quranDb.calculatePages(
        suraStart: part.suraStart,
        ayaStart: part.ayaStart,
        suraEnd: part.suraEnd,
        ayaEnd: part.ayaEnd,
      );
      if (part.type == SessionType.memorization) {
        newPartInputs.add(PartInput(pages: pages, evaluation: part.evaluation));
      } else {
        reviewPartInputs.add(PartInput(pages: pages, evaluation: part.evaluation));
      }
    }

    final cumulativePages = await _getCumulativePages(
      submission.studentSupabaseId,
      submission.sessionDate,
    );

    final result = SessionPointsCalculator.calculate(
      newParts: newPartInputs,
      reviewParts: reviewPartInputs,
      newTarget: newTarget,
      reviewTarget: reviewTarget,
      cumulativeTarget: cumulativePages,
      attended: submission.attended,
      earlyAttendance: submission.earlyAttendance,
      earlyRecitation: submission.earlyRecitation,
      onTimeDeparture: submission.onTimeDeparture,
      skippedNew: submission.skippedNew,
      skippedReview: submission.skippedReview,
      cumulativeDone: submission.cumulativeDone,
    );

    final sessionId = await _saveSession(submission, result);
    await _saveParts(sessionId, submission);
    return result;
  }

  Future<String> _saveSession(SessionSubmission submission, SessionResult result) async {
    final existing = await _client
        .from('sessions')
        .select('id')
        .eq('student_id', submission.studentSupabaseId)
        .eq('teacher_id', submission.teacherSupabaseId)
        .eq(
          'session_date',
          DateTime(
            submission.sessionDate.year,
            submission.sessionDate.month,
            submission.sessionDate.day,
          ).toIso8601String().split('T')[0],
        )
        .maybeSingle();

    final data = {
      'student_id': submission.studentSupabaseId,
      'group_id': submission.groupSupabaseId,
      'teacher_id': submission.teacherSupabaseId,
      'session_date': DateTime(
        submission.sessionDate.year,
        submission.sessionDate.month,
        submission.sessionDate.day,
      ).toIso8601String().split('T')[0],
      'attended': submission.attended,
      'early_attendance': submission.earlyAttendance,
      'early_recitation': submission.earlyRecitation,
      'on_time_departure': submission.onTimeDeparture,
      'cumulative_done': submission.cumulativeDone,
      'skipped_new': submission.skippedNew,
      'skipped_review': submission.skippedReview,
      'total_points': result.totalPoints,
      'attendance_points': result.attendancePoints,
      'early_attendance_points': result.earlyAttendancePoints,
      'early_recitation_points': result.earlyRecitationPoints,
      'departure_points': result.departurePoints,
      'new_points': result.newPoints,
      'extra_new_points': result.newExtraPoints,
      'review_points': result.reviewPoints,
      'cumulative_points': result.cumulativePoints,
      'extra_review_points': result.reviewExtraPoints,
      'new_pages': result.newPages,
      'review_pages': result.reviewPages,
      'cumulative_pages': result.cumulativePages,
    };

    if (existing != null) {
      final sessionId = existing['id'];
      await _client.from('sessions').update(data).eq('id', sessionId);
      await _client.from('session_parts').delete().eq('session_id', sessionId);
      return sessionId;
    } else {
      final inserted = await _client.from('sessions').insert(data).select('id').single();
      return inserted['id'];
    }
  }

  Future<double> _getCumulativePages(String studentId, DateTime today) async {
    final rows = await _client
        .from('sessions')
        .select('session_date, new_pages')
        .eq('student_id', studentId)
        .lt(
          'session_date',
          DateTime(today.year, today.month, today.day).toIso8601String().split('T')[0],
        )
        .order('session_date', ascending: false);

    double total = 0;
    final seenDays = <String>{};

    for (final row in rows) {
      final dateStr = row['session_date'].toString().split('T')[0];
      if (!seenDays.contains(dateStr)) {
        if (seenDays.length >= 2) break;
        seenDays.add(dateStr);
      }
      total += (row['new_pages'] as num).toDouble();
    }

    return total;
  }

  Future<bool> hasSessionToday(String studentId, String teacherId, DateTime date) async {
    final result = await _client
        .from('sessions')
        .select('id')
        .eq('student_id', studentId)
        .eq('teacher_id', teacherId)
        .eq(
          'session_date',
          DateTime(date.year, date.month, date.day).toIso8601String().split('T')[0],
        )
        .maybeSingle();
    return result != null;
  }

  Future<StudentProfile> _getStudentProfile(String studentId) async {
    final data = await _client
        .from('student_profiles')
        .select()
        .eq('user_id', studentId)
        .maybeSingle();

    if (data == null) {
      return StudentProfile()
        ..userSupabaseId = studentId
        ..newPagesTarget = 5
        ..reviewPagesTarget = 50;
    }
    return StudentProfile()
      ..userSupabaseId = studentId
      ..newPagesTarget = data['new_pages_target']
      ..reviewPagesTarget = data['review_pages_target'];
  }

  Future<void> _saveParts(String sessionId, SessionSubmission submission) async {
    for (final part in submission.parts) {
      // calculatePages قد ترمي استثناء، وسيتم التعامل معه في المستدعي (submitFullSession)
      final pages = await _quranDb.calculatePages(
        suraStart: part.suraStart,
        ayaStart: part.ayaStart,
        suraEnd: part.suraEnd,
        ayaEnd: part.ayaEnd,
      );

      await _client.from('session_parts').insert({
        'session_id': sessionId,
        'type': part.type.name,
        'sura_start': part.suraStart,
        'aya_start': part.ayaStart,
        'sura_end': part.suraEnd,
        'aya_end': part.ayaEnd,
        'pages_count': pages,
        'evaluation': part.evaluation,
        'notes': part.notes,
      });
    }
  }
}