import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/supabase_config.dart';

final managerProvider = Provider<ManagerController>((ref) => ManagerController(ref));

class ManagerController {
  final Ref _ref;
  ManagerController(this._ref);

  Future<bool> getTeacherRegistrationStatus() async {
    try {
      final res = await SupabaseConfig.client
          .from('app_settings')
          .select('value')
          .eq('key', 'teacher_registration_open')
          .maybeSingle();
      return res != null && res['value'] == 'true';
    } catch (_) {
      return false;
    }
  }

  Future<void> toggleTeacherRegistration(bool open) async {
    await SupabaseConfig.client.from('app_settings').upsert({
      'key': 'teacher_registration_open',
      'value': open.toString(),
    });
  }

  Future<void> deleteUser(String userId) async {
    await SupabaseConfig.client.from('users').delete().eq('id', userId);
  }

  Future<String> exportStudentsData() async {
    try {
      final students = await SupabaseConfig.client.from('users').select('full_name, email').eq('role', 'student');
      String csv = 'الاسم,البريد الإلكتروني\n';
      for (final s in students) {
        csv += '${s['full_name']},${s['email']}\n';
      }
      return csv;
    } catch (e) {
      return 'خطأ في التصدير';
    }
  }
}