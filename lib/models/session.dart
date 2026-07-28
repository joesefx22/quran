// import 'package:isar/isar.dart';
// part 'session.g.dart';

// @collection
class Session {
  // Id id = Isar.autoIncrement;
  int id = 0;

  // @Index(unique: true, replace: true)
  String? supabaseId;

  // @Index()
  late String studentSupabaseId;

  late String groupSupabaseId;
  late String teacherSupabaseId;
  late DateTime sessionDate;
  bool earlyAttendance = false;
  bool onTimeDeparture = false;
  bool earlyRecitation = false;
  bool cumulativeDone = false;
  double totalPoints = 0.0;

  // @Index()
  bool isSynced = false;

  DateTime? createdAt;
}