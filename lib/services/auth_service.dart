import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_config.dart';
import '../core/exceptions.dart' as Core; // ✅ alias لتجنب التعارض

class AuthService {
  final SupabaseClient _client = SupabaseConfig.client;

  Future<User?> signIn(String email, String password) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response.user;
    } on AuthException catch (e) {
      throw Core.AuthException(e.message);
    } catch (e) {
      throw Core.AuthException('فشل تسجيل الدخول: $e');
    }
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  Future<void> resetPassword(String email) async {
    await _client.auth.resetPasswordForEmail(email);
  }

  Future<void> updatePassword(String newPassword) async {
    await _client.auth.updateUser(UserAttributes(password: newPassword));
  }

  Session? get currentSession => _client.auth.currentSession;

  Stream<AuthState> get onAuthStateChange => _client.auth.onAuthStateChange;
}