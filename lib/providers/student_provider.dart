import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/student_profile.dart';

final studentProvider = Provider<StudentController>((ref) => StudentController(ref));

class StudentController {
  final Ref _ref;
  StudentController(this._ref);

  Future<StudentProfile?> getMyProfile(String userSupabaseId) async {
    return StudentProfile()
      ..userSupabaseId = userSupabaseId
      ..newPagesTarget = 5
      ..reviewPagesTarget = 50;
  }

  Future<List<Map<String, dynamic>>> getWeeklyLeaderboard(String groupSupabaseId, DateTime weekStart) async {
    return [
      {'name': 'طالب متصدر (Mock)', 'points': 50.0},
      {'name': 'طالب ثاني (Mock)', 'points': 45.0}
    ];
  }
}