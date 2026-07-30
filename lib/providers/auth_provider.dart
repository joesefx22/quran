import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';
import '../services/supabase_config.dart';

// ---------- خدمة المصادقة ----------
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

// ---------- مراقب الجلسة (تيار مباشر) ----------
final authStateProvider = StreamProvider<Session?>((ref) {
  return SupabaseConfig.client.auth.onAuthStateChange.map((event) => event.session);
});

// ---------- جلب دور المستخدم من قاعدة البيانات ----------
final userRoleProvider = FutureProvider<String?>((ref) async {
  final session = ref.watch(authStateProvider).value;
  if (session == null) return null;

  try {
    final res = await SupabaseConfig.client
        .from('users')
        .select('role')
        .eq('id', session.user.id)
        .maybeSingle();
    return res?['role'] as String?;
  } catch (_) {
    return null;
  }
});

// ---------- متحكم تسجيل الدخول البسيط ----------
final authProvider = Provider<AuthController>((ref) => AuthController(ref));

class AuthController {
  final Ref _ref;
  AuthController(this._ref);

  AuthService get _authService => _ref.read(authServiceProvider);

  Future<User?> signIn(String email, String password) async =>
      _authService.signIn(email, password);

  Future<void> signOut() async => _authService.signOut();
}