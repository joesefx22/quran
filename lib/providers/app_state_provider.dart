import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/local_user.dart';
import 'auth_provider.dart';

enum AppState {
  loading,
  unauthenticated,
  incompleteProfile,
  teacher,
  student,
  guardian,
  manager,
  error, // الحالة الجديدة لأخطاء الاتصال
}

final appStateProvider = Provider<AsyncValue<AppState>>((ref) {
  final session = ref.watch(authStateProvider).value;
  if (session == null) {
    return const AsyncValue.data(AppState.unauthenticated);
  }

  final userAsync = ref.watch(currentUserProvider);
  return userAsync.when(
    data: (LocalUser? user) {
      if (user == null) return const AsyncValue.data(AppState.unauthenticated);

      if ((user.role == 'student' || user.role == 'guardian') && !user.profileCompleted) {
        return const AsyncValue.data(AppState.incompleteProfile);
      }

      switch (user.role) {
        case 'teacher':
          return const AsyncValue.data(AppState.teacher);
        case 'student':
          return const AsyncValue.data(AppState.student);
        case 'guardian':
          return const AsyncValue.data(AppState.guardian);
        case 'manager':
          return const AsyncValue.data(AppState.manager);
        default:
          return const AsyncValue.data(AppState.unauthenticated);
      }
    },
    loading: () => const AsyncValue.loading(),
    error: (e, _) => const AsyncValue.data(AppState.error), // في حالة خطأ، نُبلغ واجهة المستخدم
  );
});