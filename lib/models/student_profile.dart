// import 'package:isar/isar.dart';
// part 'student_profile.g.dart';

// @collection
class StudentProfile {
  // Id id = Isar.autoIncrement;
  int id = 0;

  // @Index(unique: true, replace: true)
  late String userSupabaseId;

  // @Index()
  String? guardianSupabaseId;

  late int newPagesTarget;
  late int reviewPagesTarget;
  DateTime? updatedAt;
}