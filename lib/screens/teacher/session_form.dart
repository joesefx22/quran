import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/user.dart';
import '../../providers/teacher_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/session_part_form.dart';
import '../../core/strings.dart';
import '../../services/quran_database_service.dart';

final surahsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final db = QuranDatabaseService();
  return db.getSurahs();
});

final cumulativeSuggestionProvider = FutureProvider.family<String, String>((ref, studentId) {
  return ref.read(teacherProvider).getCumulativeSuggestion(studentId);
});

class SessionForm extends ConsumerStatefulWidget {
  final User student;
  const SessionForm({super.key, required this.student});

  @override
  ConsumerState<SessionForm> createState() => _SessionFormState();
}

class _SessionFormState extends ConsumerState<SessionForm> {
  late final _newParts = <SessionPartWidgetController>[];
  final _reviewParts = <SessionPartWidgetController>[];
  bool _cumulativeDone = false;
  bool _earlyAttendance = false;
  bool _onTimeDeparture = false;
  bool _earlyRecitation = false;

  @override
  void initState() {
    super.initState();
    _newParts.add(SessionPartWidgetController());
  }

  @override
  void dispose() {
    for (var c in _newParts) c.dispose();
    for (var c in _reviewParts) c.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final teacher = ref.read(authProvider).currentSession?.user;
    if (teacher == null) return;

    final partsData = <Map<String, dynamic>>[];
    for (var c in _newParts) {
      final data = c.getData();
      if (data != null) {
        partsData.add({
          'type': data.isExtra ? 'extra_new' : 'new',
          'suraStart': data.suraStart,
          'ayaStart': data.ayaStart,
          'suraEnd': data.suraEnd,
          'ayaEnd': data.ayaEnd,
          'isExtra': data.isExtra,
          'evaluation': data.evaluation,
          'notes': data.notes,
        });
      }
    }
    for (var c in _reviewParts) {
      final data = c.getData();
      if (data != null) {
        partsData.add({
          'type': data.isExtra ? 'extra_review' : 'review',
          'suraStart': data.suraStart,
          'ayaStart': data.ayaStart,
          'suraEnd': data.suraEnd,
          'ayaEnd': data.ayaEnd,
          'isExtra': data.isExtra,
          'evaluation': data.evaluation,
          'notes': data.notes,
        });
      }
    }

    if (partsData.isEmpty && !_earlyAttendance && !_earlyRecitation && !_onTimeDeparture && !_cumulativeDone) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('الرجاء إدخال بيانات التسميع أو الحضور.')));
      return;
    }

    await ref.read(teacherProvider).submitFullSession(
      studentSupabaseId: widget.student.supabaseId,
      groupSupabaseId: widget.student.groupSupabaseId ?? '',
      teacherSupabaseId: teacher.id,
      sessionDate: DateTime.now(),
      partsData: partsData,
      earlyAttendance: _earlyAttendance,
      onTimeDeparture: _onTimeDeparture,
      earlyRecitation: _earlyRecitation,
      cumulativeDone: _cumulativeDone,
    );

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final surahsAsync = ref.watch(surahsProvider);
    final suggestionAsync = ref.watch(cumulativeSuggestionProvider(widget.student.supabaseId));

    return Scaffold(
      appBar: AppBar(title: Text('جلسة ${widget.student.fullName}')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // مربع التراكمي المقترح
                suggestionAsync.when(
                  data: (sug) => Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12.0),
                    margin: const EdgeInsets.only(bottom: 8.0),
                    decoration: BoxDecoration(
                      color: Colors.teal.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.teal.shade200),
                    ),
                    child: Text('📌 التراكمي المقترح:\n$sug', style: TextStyle(color: Colors.teal.shade900)),
                  ),
                  loading: () => const SizedBox(),
                  error: (_, __) => const SizedBox(),
                ),
                CheckboxListTile(
                  title: const Text(AppStrings.doneCumulative),
                  value: _cumulativeDone,
                  onChanged: (v) => setState(() => _cumulativeDone = v ?? false),
                ),
                const SizedBox(height: 16),
                const Text(AppStrings.newMemorization,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                surahsAsync.when(
                  data: (surahs) => Column(
                    children: _newParts.asMap().entries.map((entry) {
                      final index = entry.key;
                      final c = entry.value;
                      return SessionPartWidget(
                        controller: c,
                        isExtra: false,
                        surahs: surahs,
                        onDelete: _newParts.length > 1
                            ? () => setState(() {
                                  c.dispose();
                                  _newParts.removeAt(index);
                                })
                            : null,
                      );
                    }).toList(),
                  ),
                  loading: () => const LinearProgressIndicator(),
                  error: (e, _) => Text('خطأ في تحميل السور: $e'),
                ),
                TextButton.icon(
                  onPressed: () => setState(() => _newParts.add(SessionPartWidgetController())),
                  icon: const Icon(Icons.add),
                  label: const Text('إضافة تسميع منفصل'),
                ),
                const Divider(),
                const Text(AppStrings.review,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                surahsAsync.when(
                  data: (surahs) => Column(
                    children: _reviewParts.asMap().entries.map((entry) {
                      final index = entry.key;
                      final c = entry.value;
                      return SessionPartWidget(
                        controller: c,
                        isExtra: false,
                        surahs: surahs,
                        onDelete: () => setState(() {
                          c.dispose();
                          _reviewParts.removeAt(index);
                        }),
                      );
                    }).toList(),
                  ),
                  loading: () => const SizedBox(),
                  error: (e, _) => const SizedBox(),
                ),
                TextButton.icon(
                  onPressed: () => setState(() => _reviewParts.add(SessionPartWidgetController())),
                  icon: const Icon(Icons.add),
                  label: const Text('إضافة مراجعة منفصلة'),
                ),
                const Divider(),
                CheckboxListTile(
                    title: const Text(AppStrings.earlyAttendance),
                    value: _earlyAttendance,
                    onChanged: (v) => setState(() => _earlyAttendance = v ?? false)),
                CheckboxListTile(
                    title: const Text(AppStrings.onTimeDeparture),
                    value: _onTimeDeparture,
                    onChanged: (v) => setState(() => _onTimeDeparture = v ?? false)),
                CheckboxListTile(
                    title: const Text(AppStrings.earlyRecitation),
                    value: _earlyRecitation,
                    onChanged: (v) => setState(() => _earlyRecitation = v ?? false)),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: _submit,
                    child: const Text('حفظ الجلسة'),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}