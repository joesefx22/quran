// import 'package:isar/isar.dart';
// part 'local_user.g.dart';

// @collection
class LocalUser {
  // Id id = Isar.autoIncrement;
  int id = 0;

  // @Index(unique: true, replace: true)
  late String supabaseId;

  late String email;
  late String fullName;

  // @Index()
  late String role;

  // @Index()
  String? groupSupabaseId;

  String? mosqueSupabaseId;
  DateTime? createdAt;
}