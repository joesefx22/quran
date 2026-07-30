import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_config.dart';
import '../core/exceptions.dart' as Core;

class AuthService {
  final SupabaseClient _client = SupabaseConfig.client;

  /// تسجيل الدخول بالبريد وكلمة المرور، يعيد المستخدم إذا نجح
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

  /// تسجيل الخروج
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  /// إعادة تعيين كلمة المرور (غير مستخدمة في MVP)
  Future<void> resetPassword(String email) async {
    await _client.auth.resetPasswordForEmail(email);
  }

  /// الجلسة الحالية
  Session? get currentSession => _client.auth.currentSession;

  /// تيار تغيرات المصادقة
  Stream<AuthState> get onAuthStateChange => _client.auth.onAuthStateChange;
}