// import 'package:isar/isar.dart';
// part 'session_part.g.dart';

enum SessionType {
  memorization,
  cumulative,
  review,
  unknown,
}

extension SessionTypeMapper on SessionType {
  String toDatabase() { /* ... */ }
  static SessionType fromDatabase(String value) { /* ... */ }
}

// @collection
class SessionPart {
  // Id id = Isar.autoIncrement;
  int id = 0;

  // @Index()
  late int sessionLocalId;

  // @Index(unique: true, replace: true)
  String? supabaseId;

  // @Enumerated(EnumType.name)
  late SessionType type;

  late int suraStart;
  late int ayaStart;
  late int suraEnd;
  late int ayaEnd;
  double pagesCount = 0;
  bool isExtra = false;
  String? evaluation;
  String? notes;

  // @Index()
  bool isSynced = false;
}