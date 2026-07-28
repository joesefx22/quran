import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/local_user.dart';
import '../models/session.dart';
import '../models/student_profile.dart';
import '../services/session_service.dart';
import '../services/supabase_config.dart';

final teacherProvider = Provider<TeacherController>((ref) => TeacherController(ref));

final studentAttendanceProvider = FutureProvider.family<double, ({String studentId, DateTime weekStart})>(
  (ref, params) async => 100.0, // Mock
);

class TeacherController {
  final Ref _ref;
  TeacherController(this._ref);

  // تم استبدال sessionServiceProvider بـ Service مباشر للتوافق مع التجميد
  final SessionService _sessionService = SessionService();

  Future<List<LocalUser>> getGroupStudents(String groupSupabaseId) async {
    // TODO: Isar frozen – قائمة وهمية
    return [
      LocalUser()
        ..supabaseId = 'student1'
        ..fullName = 'طالب تجريبي'
        ..role = 'student'
        ..groupSupabaseId = groupSupabaseId
    ];
  }

  Future<List<Session>> getStudentWeeklySessions(String studentSupabaseId, DateTime weekStart) async {
    return [];
  }

  // دالة تقديم الجلسة (وهمية حالياً)
  Future<Session> submitFullSession({
    String? studentSupabaseId,
    String? groupSupabaseId,
    String? teacherSupabaseId,
    DateTime? sessionDate,
    List<Map<String, dynamic>>? partsData,
    bool earlyAttendance = false,
    bool onTimeDeparture = false,
    bool earlyRecitation = false,
    bool cumulativeDone = false,
  }) async {
    return _sessionService.submitFullSession();
  }

  Future<StudentProfile?> getStudentProfile(String userSupabaseId) async {
    return StudentProfile()
      ..userSupabaseId = userSupabaseId
      ..newPagesTarget = 5
      ..reviewPagesTarget = 50;
  }

  Future<String> getCumulativeSuggestion(String studentSupabaseId) async =>
      _sessionService.getSuggestedCumulative(studentSupabaseId);

  Future<void> updateStudentTargets(String userSupabaseId, int newTarget, int reviewTarget) async {
    try {
      await SupabaseConfig.client.from('student_profiles').upsert({
        'user_id': userSupabaseId,
        'new_pages_target': newTarget,
        'review_pages_target': reviewTarget,
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (_) {}
  }
}