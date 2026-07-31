import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/student_profile.dart';
import '../models/student_week_stats.dart';
import '../models/student_session_details.dart';
import '../services/supabase_config.dart';

final studentProvider = Provider<StudentController>((ref) {
  return StudentController();
});

class StudentController {
  final _client = SupabaseConfig.client;

  Future<StudentProfile?> getMyProfile(String userSupabaseId) async {
    final data = await _client
        .from('student_profiles')
        .select()
        .eq('user_id', userSupabaseId)
        .maybeSingle();
    if (data == null) return null;
    return StudentProfile()
      ..userSupabaseId = userSupabaseId
      ..newPagesTarget = data['new_pages_target']
      ..reviewPagesTarget = data['review_pages_target'];
  }

  DateTime getWeekStart(DateTime now) {
    return DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - DateTime.saturday));
  }

  DateTime getWeekEnd(DateTime start) {
    return start.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));
  }

  Future<List<Map<String, dynamic>>> getWeeklyLeaderboard(
      String groupSupabaseId, DateTime weekStart) async {
    final weekEnd = getWeekEnd(weekStart);
    final students = await _client
        .from('users')
        .select('id, full_name')
        .eq('group_id', groupSupabaseId)
        .eq('role', 'student');

    final leaderboard = <Map<String, dynamic>>[];
    for (final student in students) {
      final sessions = await _client
          .from('sessions')
          .select('total_points, session_date, attendance_points, early_attendance_points, early_recitation_points, departure_points, new_pages, review_pages, cumulative_pages')
          .eq('student_id', student['id'])
          .gte('session_date', weekStart.toIso8601String())
          .lte('session_date', weekEnd.toIso8601String());

      double total = 0, best = 0;
      int count = sessions.length;
      int earlyAtt = 0, earlyRec = 0, onTimeDep = 0;
      double memoPages = 0, revPages = 0, cumPages = 0;
      for (final s in sessions) {
        final pts = (s['total_points'] as num?)?.toDouble() ?? 0;
        total += pts;
        if (pts > best) best = pts;
        // تم إصلاح المقارنات بإضافة أقواس
        if (((s['early_attendance_points'] as num?)?.toDouble() ?? 0) > 0) earlyAtt++;
        if (((s['early_recitation_points'] as num?)?.toDouble() ?? 0) > 0) earlyRec++;
        if (((s['departure_points'] as num?)?.toDouble() ?? 0) > 0) onTimeDep++;
        memoPages += (s['new_pages'] as num?)?.toDouble() ?? 0;
        revPages += (s['review_pages'] as num?)?.toDouble() ?? 0;
        cumPages += (s['cumulative_pages'] as num?)?.toDouble() ?? 0;
      }
      leaderboard.add({
        'studentId': student['id'],
        'name': student['full_name'],
        'points': total,
        'sessions': count,
        'average': count > 0 ? total / count : 0,
        'best': best,
        'memorizationPages': memoPages,
        'reviewPages': revPages,
        'cumulativePages': cumPages,
        'earlyAttendance': earlyAtt,
        'earlyRecitation': earlyRec,
        'onTimeDeparture': onTimeDep,
      });
    }

    leaderboard.sort((a, b) => (b['points'] as double).compareTo(a['points'] as double));
    for (int i = 0; i < leaderboard.length; i++) {
      leaderboard[i]['rank'] = i + 1;
    }
    return leaderboard;
  }

  Future<StudentWeekStats> getStudentWeekStats(
      String studentId, String groupId, DateTime weekStart) async {
    final board = await getWeeklyLeaderboard(groupId, weekStart);
    final me = board.firstWhere((e) => e['studentId'] == studentId, orElse: () => {});
    if (me.isEmpty) {
      return const StudentWeekStats(
        rank: 0,
        totalPoints: 0,
        sessionsCount: 0,
        memorizationPages: 0,
        reviewPages: 0,
        cumulativePages: 0,
        averagePoints: 0,
        bestSession: 0,
        earlyAttendanceCount: 0,
        earlyRecitationCount: 0,
        onTimeDepartureCount: 0,
      );
    }
    return StudentWeekStats(
      rank: me['rank'],
      totalPoints: me['points'],
      sessionsCount: me['sessions'],
      memorizationPages: me['memorizationPages'],
      reviewPages: me['reviewPages'],
      cumulativePages: me['cumulativePages'],
      averagePoints: me['average'],
      bestSession: me['best'],
      earlyAttendanceCount: me['earlyAttendance'],
      earlyRecitationCount: me['earlyRecitation'],
      onTimeDepartureCount: me['onTimeDeparture'],
    );
  }

  Future<List<StudentSessionDetails>> getStudentSessionsDetails(
      String studentId, DateTime weekStart) async {
    final weekEnd = getWeekEnd(weekStart);
    final rows = await _client
        .from('sessions')
        .select()
        .eq('student_id', studentId)
        .gte('session_date', weekStart.toIso8601String())
        .lte('session_date', weekEnd.toIso8601String())
        .order('session_date', ascending: false);

    return rows.map((r) {
      return StudentSessionDetails(
        sessionId: r['id'],
        sessionDate: DateTime.parse(r['session_date']),
        totalPoints: (r['total_points'] as num?)?.toDouble() ?? 0,
        attendancePoints: (r['attendance_points'] as num?)?.toDouble() ?? 0,
        earlyAttendancePoints: (r['early_attendance_points'] as num?)?.toDouble() ?? 0,
        earlyRecitationPoints: (r['early_recitation_points'] as num?)?.toDouble() ?? 0,
        departurePoints: (r['departure_points'] as num?)?.toDouble() ?? 0,
        memorizationPoints: (r['new_points'] as num?)?.toDouble() ?? 0,
        memorizationExtraPoints: (r['extra_new_points'] as num?)?.toDouble() ?? 0,
        reviewPoints: (r['review_points'] as num?)?.toDouble() ?? 0,
        reviewExtraPoints: (r['extra_review_points'] as num?)?.toDouble() ?? 0,
        cumulativePoints: (r['cumulative_points'] as num?)?.toDouble() ?? 0,
        memorizationPages: (r['new_pages'] as num?)?.toDouble() ?? 0,
        reviewPages: (r['review_pages'] as num?)?.toDouble() ?? 0,
        cumulativePages: (r['cumulative_pages'] as num?)?.toDouble() ?? 0,
      );
    }).toList();
  }
}