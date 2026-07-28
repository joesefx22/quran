import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_config.dart';
import 'core/exceptions.dart';
import 'session_service.dart';
import 'connectivity_service.dart';

class SyncService {
  final SupabaseClient _client = SupabaseConfig.client;
  final SessionService _sessionService = SessionService();
  final ConnectivityService _connectivityService;

  SyncService(this._connectivityService) {
    _connectivityService.onConnectivityChanged.listen((hasConnection) {
      if (hasConnection) syncPendingSessions();
    });
  }

  Future<void> pullAllData() async {
    // TODO: Isar frozen – فقط نتحقق من Supabase
    try {
      await _client.from('users').select().limit(1);
    } catch (e) {
      throw SyncException('فشل سحب البيانات: $e');
    }
  }

  Future<void> syncPendingSessions() async {
    // TODO: Isar frozen
  }
}