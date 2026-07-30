import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/local_user.dart';
import '../models/session_submission.dart';
import '../models/session_result.dart';
import '../models/student_profile.dart';
import '../services/session_service.dart';
import '../services/quran_database_service.dart';
import '../services/supabase_config.dart';

final teacherProvider = Provider<TeacherController>((ref) {
  return TeacherController();
});

class TeacherController {
  late final SessionService _sessionService;
  final _client = SupabaseConfig.client;
  final _quranDb = QuranDatabaseService();

  TeacherController() {
    _sessionService = SessionService(
      supabaseClient: _client,
      quranDb: _quranDb,
    );
  }

  Future<SessionResult> submitFullSession(SessionSubmission submission) {
    return _sessionService.submitFullSession(submission);
  }

  Future<List<LocalUser>> getGroupStudents(String groupSupabaseId) async {
    final data = await _client
        .from('users')
        .select('*')
        .eq('group_id', groupSupabaseId)
        .eq('role', 'student');
    return data.map<LocalUser>((json) => LocalUser()
      ..supabaseId = json['id']
      ..fullName = json['full_name'] ?? ''
      ..email = json['email'] ?? ''
      ..role = json['role'] ?? ''
      ..groupSupabaseId = json['group_id']
      ..mosqueSupabaseId = json['mosque_id']
    ).toList();
  }

  Future<StudentProfile?> getStudentProfile(String userSupabaseId) async {
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

  Future<String> getCumulativeSuggestion(String studentSupabaseId) async {
    // مقترح بسيط: يمكن استخدام service لاحقاً
    return "يُحسب تلقائياً من آخر يومين";
  }

  Future<void> updateStudentTargets(String userSupabaseId, int newTarget, int reviewTarget) async {
    await _client.from('student_profiles').upsert({
      'user_id': userSupabaseId,
      'new_pages_target': newTarget,
      'review_pages_target': reviewTarget,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }
}