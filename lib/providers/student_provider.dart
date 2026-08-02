import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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

    // 1. جلب جميع طلاب المجموعة
    final students = await _client
        .from('users')
        .select('id, full_name')
        .eq('group_id', groupSupabaseId)
        .eq('role', 'student');

    final studentIds = students.map((s) => s['id'] as String).toList();
    if (studentIds.isEmpty) return [];

    // 2. جلب جميع جلسات هؤلاء الطلاب دفعة واحدة
    final allSessions = await _client
        .from('sessions')
        .select('student_id, total_points, attendance_points, early_attendance_points, early_recitation_points, departure_points, new_pages, review_pages, cumulative_pages')
        .inFilter('student_id', studentIds)
        .gte('session_date', weekStart.toIso8601String())
        .lte('session_date', weekEnd.toIso8601String());

    // 3. تجميع النتائج لكل طالب
    final Map<String, Map<String, dynamic>> statsMap = {};
    for (final s in students) {
      statsMap[s['id']] = {
        'name': s['full_name'],
        'points': 0.0,
        'sessions': 0,
        'memorizationPages': 0.0,
        'reviewPages': 0.0,
        'cumulativePages': 0.0,
        'earlyAttendance': 0,
        'earlyRecitation': 0,
        'onTimeDeparture': 0,
        'best': 0.0,
      };
    }

    for (final session in allSessions) {
      final id = session['student_id'] as String;
      final st = statsMap[id];
      if (st == null) continue;

      final pts = (session['total_points'] as num?)?.toDouble() ?? 0;
      st['points'] = (st['points'] as double) + pts;
      st['sessions'] = (st['sessions'] as int) + 1;
      if (pts > (st['best'] as double)) st['best'] = pts;

      if (((session['early_attendance_points'] as num?)?.toDouble() ?? 0) > 0) {
        st['earlyAttendance'] = (st['earlyAttendance'] as int) + 1;
      }
      if (((session['early_recitation_points'] as num?)?.toDouble() ?? 0) > 0) {
        st['earlyRecitation'] = (st['earlyRecitation'] as int) + 1;
      }
      if (((session['departure_points'] as num?)?.toDouble() ?? 0) > 0) {
        st['onTimeDeparture'] = (st['onTimeDeparture'] as int) + 1;
      }

      st['memorizationPages'] = (st['memorizationPages'] as double) + ((session['new_pages'] as num?)?.toDouble() ?? 0);
      st['reviewPages'] = (st['reviewPages'] as double) + ((session['review_pages'] as num?)?.toDouble() ?? 0);
      st['cumulativePages'] = (st['cumulativePages'] as double) + ((session['cumulative_pages'] as num?)?.toDouble() ?? 0);
    }

    final leaderboard = statsMap.entries.map((entry) {
      final st = entry.value;
      return {
        'studentId': entry.key,
        'name': st['name'],
        'points': st['points'],
        'sessions': st['sessions'],
        'average': (st['sessions'] as int) > 0 ? (st['points'] as double) / (st['sessions'] as int) : 0,
        'best': st['best'],
        'memorizationPages': st['memorizationPages'],
        'reviewPages': st['reviewPages'],
        'cumulativePages': st['cumulativePages'],
        'earlyAttendance': st['earlyAttendance'],
        'earlyRecitation': st['earlyRecitation'],
        'onTimeDeparture': st['onTimeDeparture'],
      };
    }).toList();

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
        rank: 0, totalPoints: 0, sessionsCount: 0, memorizationPages: 0, reviewPages: 0,
        cumulativePages: 0, averagePoints: 0, bestSession: 0, earlyAttendanceCount: 0,
        earlyRecitationCount: 0, onTimeDepartureCount: 0,
      );
    }
    return StudentWeekStats(
      rank: me['rank'], totalPoints: me['points'], sessionsCount: me['sessions'],
      memorizationPages: me['memorizationPages'], reviewPages: me['reviewPages'],
      cumulativePages: me['cumulativePages'], averagePoints: me['average'],
      bestSession: me['best'], earlyAttendanceCount: me['earlyAttendance'],
      earlyRecitationCount: me['earlyRecitation'], onTimeDepartureCount: me['onTimeDeparture'],
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