// import 'package:isar/isar.dart';
// part 'group.g.dart';

// @collection
class Group {
  // Id id = Isar.autoIncrement;
  int id = 0;

  // @Index(unique: true, replace: true)
  late String supabaseId;

  // @Index()
  late String mosqueSupabaseId;

  late String name;
  DateTime? createdAt;
}