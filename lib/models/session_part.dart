enum SessionType {
  memorization,
  review,
}

class SessionPart {
  int id = 0;
  late int sessionLocalId;
  String? supabaseId;
  late SessionType type;
  late int suraStart;
  late int ayaStart;
  late int suraEnd;
  late int ayaEnd;
  double pagesCount = 0;
  String? evaluation;
  String? notes;
  bool isSynced = false;
}