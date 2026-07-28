import '../models/session.dart';
// باقي الاستيرادات معلقة

class SessionService {
  // final _uuid = const Uuid();

  Future<Session> submitFullSession(/* SessionSubmission submission */) async {
    // TODO: Isar frozen – تُرجع جلسة وهمية
    return Session()
      ..supabaseId = 'mock-session-id'
      ..sessionDate = DateTime.now()
      ..totalPoints = 10.0;
  }

  Future<List<Session>> getUnsyncedSessions() async => [];

  Future<String> getSuggestedCumulative(String studentSupabaseId) async =>
      "سورة البقرة من 1 إلى 5 (Mock)";
}
