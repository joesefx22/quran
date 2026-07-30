import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/supabase_config.dart';
import '../core/router.dart';
import '../core/theme.dart';
import '../widgets/islamic_header.dart';

final mosquesProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final data = await SupabaseConfig.client.from('mosques').select('id, name');
  return data;
});

final groupsProvider = FutureProvider.family<List<Map<String, dynamic>>, String>((ref, mosqueId) async {
  final data = await SupabaseConfig.client.from('groups').select('id, name').eq('mosque_id', mosqueId);
  return data;
});

class CompleteProfileScreen extends ConsumerStatefulWidget {
  final String userId;
  final String email;
  final String fullName;
  final String role;

  const CompleteProfileScreen({
    super.key,
    required this.userId,
    required this.email,
    required this.fullName,
    required this.role,
  });

  @override
  ConsumerState<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends ConsumerState<CompleteProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  String? _selectedMosqueId;
  String? _selectedGroupId;
  final _newTargetCtrl = TextEditingController(text: '3');
  final _reviewTargetCtrl = TextEditingController(text: '5');
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl.text = widget.fullName;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _ageCtrl.dispose();
    _newTargetCtrl.dispose();
    _reviewTargetCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedMosqueId == null || _selectedGroupId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('اختر المسجد والمجموعة')));
      return;
    }
    setState(() => _loading = true);
    final ageText = _ageCtrl.text.trim();
    final age = int.tryParse(ageText);
    try {
      await SupabaseConfig.client.from('users').update({
        'full_name': _nameCtrl.text.trim(),
        'age': age,
        'mosque_id': _selectedMosqueId,
        'group_id': _selectedGroupId,
        'profile_completed': true,
      }).eq('id', widget.userId);
      if (widget.role == 'student') {
        await SupabaseConfig.client.from('student_profiles').upsert(
          {
            'user_id': widget.userId,
            'new_pages_target': int.tryParse(_newTargetCtrl.text) ?? 3,
            'review_pages_target': int.tryParse(_reviewTargetCtrl.text) ?? 5,
            'updated_at': DateTime.now().toIso8601String(),
          },
          onConflict: 'user_id',
        );
      }
      if (!mounted) return;
      HapticFeedback.mediumImpact();
      Navigator.pushReplacementNamed(context, AppRouter.splash);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطأ: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final mosquesAsync = ref.watch(mosquesProvider);
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              IslamicHeader(title: 'أكمل بياناتك', subtitle: 'لنبدأ الرحلة معًا').animate().fadeIn(),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'الاسم الكامل', prefixIcon: Icon(Icons.person)),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'الاسم مطلوب' : null,
              ).animate().fadeIn(delay: 100.ms),
              const SizedBox(height: 16),
              TextFormField(
                controller: _ageCtrl,
                decoration: const InputDecoration(labelText: 'العمر', prefixIcon: Icon(Icons.cake)),
                keyboardType: TextInputType.number,
                validator: (v) { if (v != null && v.isNotEmpty && int.tryParse(v) == null) return 'رقم صحيح'; return null; },
              ).animate().fadeIn(delay: 200.ms),
              const SizedBox(height: 16),
              mosquesAsync.when(
                data: (mosques) => DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'المسجد', prefixIcon: Icon(Icons.mosque)),
                  items: mosques.map((m) => DropdownMenuItem(value: m['id'], child: Text(m['name']))).toList(),
                  onChanged: (v) { setState(() { _selectedMosqueId = v; _selectedGroupId = null; }); },
                  validator: (v) => v == null ? 'اختر المسجد' : null,
                ),
                loading: () => const LinearProgressIndicator(),
                error: (e, _) => Text('خطأ: $e'),
              ).animate().fadeIn(delay: 300.ms),
              if (_selectedMosqueId != null) ...[
                const SizedBox(height: 16),
                ref.watch(groupsProvider(_selectedMosqueId!)).when(
                  data: (groups) => DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'المجموعة', prefixIcon: Icon(Icons.group_work)),
                    items: groups.map((g) => DropdownMenuItem(value: g['id'], child: Text(g['name']))).toList(),
                    onChanged: (v) { setState(() { _selectedGroupId = v; }); },
                    validator: (v) => v == null ? 'اختر المجموعة' : null,
                  ),
                  loading: () => const LinearProgressIndicator(),
                  error: (e, _) => Text('خطأ: $e'),
                ).animate().fadeIn(delay: 400.ms),
              ],
              if (widget.role == 'student') ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: _newTargetCtrl,
                  decoration: const InputDecoration(labelText: 'ورد الحفظ (صفحات)', prefixIcon: Icon(Icons.book)),
                  keyboardType: TextInputType.number,
                ).animate().fadeIn(delay: 500.ms),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _reviewTargetCtrl,
                  decoration: const InputDecoration(labelText: 'ورد المراجعة (صفحات)', prefixIcon: Icon(Icons.refresh)),
                  keyboardType: TextInputType.number,
                ).animate().fadeIn(delay: 600.ms),
              ],
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.emeraldGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _loading
                      ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('متابعة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                ),
              ).animate().fadeIn(delay: 700.ms),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}