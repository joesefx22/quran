import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';
import '../services/supabase_config.dart';
import '../models/local_user.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final authStateProvider = StreamProvider<Session?>((ref) {
  return SupabaseConfig.client.auth.onAuthStateChange.map((event) => event.session);
});

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

final currentUserProvider = FutureProvider<LocalUser?>((ref) async {
  final session = ref.watch(authStateProvider).value;
  if (session == null) return null;
  try {
    final data = await SupabaseConfig.client
        .from('users')
        .select('*')
        .eq('id', session.user.id)
        .single();
    return LocalUser()
      ..supabaseId = data['id']
      ..email = data['email'] ?? ''
      ..fullName = data['full_name'] ?? ''
      ..role = data['role'] ?? ''
      ..groupSupabaseId = data['group_id']
      ..mosqueSupabaseId = data['mosque_id']
      ..profileCompleted = data['profile_completed'] ?? false; //  أضفنا الحقل
  } catch (_) {
    return null;
  }
});

final authProvider = Provider<AuthController>((ref) => AuthController(ref));

class AuthController {
  final Ref _ref;
  AuthController(this._ref);
  AuthService get _authService => _ref.read(authServiceProvider);
  Future<User?> signIn(String email, String password) async =>
      _authService.signIn(email, password);
  Future<void> signOut() async => _authService.signOut();
}