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
    // TODO: Isar frozen – إرجاع CSV وهمي
    return 'الاسم,البريد,المجموعة,إجمالي نقاط التسميع\nطالب تجريبي,test@test.com,mock_group,10.0\n';
  }
}