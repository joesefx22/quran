import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/session_result.dart';
import '../models/session_submission.dart';
import '../models/student_profile.dart';
import '../models/session_part.dart';             // <-- تمت الإضافة
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
    double totalNewPages = 0, totalReviewPages = 0;

    for (final part in submission.parts) {
      final pages = await _quranDb.calculatePages(
        suraStart: part.suraStart,
        ayaStart: part.ayaStart,
        suraEnd: part.suraEnd,
        ayaEnd: part.ayaEnd,
      );
      if (part.type == SessionType.memorization) {
        newPartInputs.add(PartInput(pages: pages, evaluation: part.evaluation));
        totalNewPages += pages;
      } else {
        reviewPartInputs.add(PartInput(pages: pages, evaluation: part.evaluation));
        totalReviewPages += pages;
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

  Future<double> _getCumulativePages(String studentId, DateTime today) async {
    final rows = await _client
        .from('sessions')
        .select('session_date')
        .eq('student_id', studentId)
        .lt('session_date', today.toIso8601String())
        .order('session_date', ascending: false);

    final uniqueDays = <String>{};
    for (final row in rows) {
      final date = DateTime.parse(row['session_date']);
      final dayKey =
          '${date.year.toString().padLeft(4, '0')}-'
          '${date.month.toString().padLeft(2, '0')}-'
          '${date.day.toString().padLeft(2, '0')}';
      uniqueDays.add(dayKey);
      if (uniqueDays.length == 2) break;
    }

    double total = 0;
    for (final day in uniqueDays) {
      final startOfDay = '${day}T00:00:00';
      final endOfDay = '${day}T23:59:59';
      final sessions = await _client
          .from('sessions')
          .select('id')
          .eq('student_id', studentId)
          .gte('session_date', startOfDay)
          .lte('session_date', endOfDay);

      for (final session in sessions) {
        final parts = await _client
            .from('session_parts')
            .select('pages_count')
            .eq('session_id', session['id'])
            .eq('type', 'memorization');
        for (final part in parts) {
          total += (part['pages_count'] as num).toDouble();
        }
      }
    }
    return total;
  }

  Future<StudentProfile> _getStudentProfile(String studentId) async {
    final data = await _client
        .from('student_profiles')
        .select()
        .eq('user_id', studentId)
        .single();
    return StudentProfile()
      ..userSupabaseId = studentId
      ..newPagesTarget = data['new_pages_target']
      ..reviewPagesTarget = data['review_pages_target'];
  }

  Future<String> _saveSession(SessionSubmission submission, SessionResult result) async {
    final row = await _client.from('sessions').insert({
      'student_id': submission.studentSupabaseId,
      'group_id': submission.groupSupabaseId,
      'teacher_id': submission.teacherSupabaseId,
      'session_date': submission.sessionDate.toIso8601String(),
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
    }).select('id').single();

    return row['id'];
  }

  Future<void> _saveParts(String sessionId, SessionSubmission submission) async {
    for (final part in submission.parts) {
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