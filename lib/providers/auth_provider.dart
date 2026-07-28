import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';
import '../models/local_user.dart';
import '../services/supabase_config.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

// ✅ التعديل: إرجاع Session? مباشرة من SupabaseConfig
final authStateProvider = StreamProvider<Session?>((ref) {
  return SupabaseConfig.client.auth.onAuthStateChange.map((event) => event.session);
});

final currentUserProvider = FutureProvider<LocalUser?>((ref) async {
  final session = ref.watch(authStateProvider).value;
  if (session?.user == null) return null;

  final supabaseUser = session!.user;
  // TODO: Isar frozen – استبدال جلب Isar بمستخدم وهمي
  return LocalUser()
    ..supabaseId = supabaseUser.id
    ..email = supabaseUser.email ?? 'test@test.com'
    ..fullName = 'مستخدم مؤقت'
    ..role = 'teacher'
    ..groupSupabaseId = 'mock_group';
});

final authProvider = Provider<AuthController>((ref) => AuthController(ref));

class AuthController {
  final Ref _ref;
  AuthController(this._ref);

  AuthService get _authService => _ref.read(authServiceProvider);

  Future<void> signIn(String email, String password) async =>
      _authService.signIn(email, password);

  Future<void> signOut() async => _authService.signOut();

  Session? get currentSession => _authService.currentSession;
}
