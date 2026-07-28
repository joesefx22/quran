import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/constants.dart';

class SupabaseConfig {
  static SupabaseClient? _client;

  static SupabaseClient get client {
    if (_client == null) {
      throw StateError('Supabase لم يتم تهيئته بعد. استدعِ SupabaseConfig.init() في main()');
    }
    return _client!;
  }

  static Future<void> init() async {
    await Supabase.initialize(
      url: AppConstants.supabaseUrl,
      anonKey: AppConstants.supabaseAnonKey,
    );
    _client = Supabase.instance.client;
  }
}