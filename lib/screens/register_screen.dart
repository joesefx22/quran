import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_config.dart';
import '../core/strings.dart';

final teacherRegistrationEnabledProvider = FutureProvider<bool>((ref) async {
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
});

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  String _role = 'student';
  bool _loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    setState(() => _loading = true);
    try {
      final res = await SupabaseConfig.client.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        data: {'full_name': _nameController.text.trim()},
      );
      if (res.user != null) {
        try {
          await SupabaseConfig.client.from('users').insert({
            'id': res.user!.id,
            'email': _emailController.text.trim(),
            'full_name': _nameController.text.trim(),
            'role': _role,
          });
          if (!mounted) return;
          Navigator.pushReplacementNamed(context, '/login');
        } catch (_) {
          await SupabaseConfig.client.auth.signOut();
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('فشل إكمال التسجيل. حاول مرة أخرى.')),
          );
        }
      }
    } on AuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطأ: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final teacherEnabled = ref.watch(teacherRegistrationEnabledProvider);

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.register)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                TextFormField(
                  controller: _nameController, 
                  decoration: const InputDecoration(labelText: 'الاسم الكامل')
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController, 
                  decoration: const InputDecoration(labelText: 'البريد الإلكتروني'),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController, 
                  decoration: const InputDecoration(labelText: 'كلمة المرور'),
                  obscureText: true,
                ),
                const SizedBox(height: 16),
                teacherEnabled.when(
                  data: (enabled) => DropdownButtonFormField<String>(
                    value: _role,
                    decoration: const InputDecoration(labelText: 'الدور'),
                    items: [
                      const DropdownMenuItem(value: 'student', child: Text('طالب')),
                      const DropdownMenuItem(value: 'guardian', child: Text('ولي أمر')),
                      if (enabled) const DropdownMenuItem(value: 'teacher', child: Text('معلم')),
                    ],
                    onChanged: (v) => _role = v!,
                  ),
                  loading: () => const LinearProgressIndicator(),
                  error: (_, __) => const SizedBox(),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _loading ? null : _register,
                  child: _loading ? const CircularProgressIndicator() : const Text(AppStrings.register),
                ),
                TextButton(
                  onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
                  child: const Text('لدي حساب بالفعل؟ سجل دخولك'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}