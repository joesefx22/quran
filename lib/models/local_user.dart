class LocalUser {
  int id = 0;
  late String supabaseId;
  late String email;
  late String fullName;
  late String role;
  String? groupSupabaseId;
  String? mosqueSupabaseId;
  DateTime? createdAt;
  String? phoneNumber;
  String? guardianName;
  String? guardianPhone;
  bool isActive = true;
  DateTime? joinedAt;
  bool profileCompleted = false; //  أضفنا هذا الحقل
}