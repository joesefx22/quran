import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../models/local_user.dart';
import '../../models/session_part.dart';
import '../../models/session_submission.dart';
import '../../providers/teacher_provider.dart';
import '../../services/quran_database_service.dart';
import '../../widgets/searchable_dropdown.dart';
import '../../widgets/session_points_dialog.dart';
import '../../widgets/islamic_header.dart';
import '../../core/theme.dart';

final surahsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final db = QuranDatabaseService();
  return db.getSurahs();
});

class SessionForm extends ConsumerStatefulWidget {
  final LocalUser student;
  final String teacherId;
  final String groupId;
  const SessionForm({super.key, required this.student, required this.teacherId, required this.groupId});

  @override
  ConsumerState<SessionForm> createState() => _SessionFormState();
}

class _SessionFormState extends ConsumerState<SessionForm> {
  bool _attended = true;
  bool _earlyAttendance = false;
  bool _earlyRecitation = false;
  bool _onTimeDeparture = false;
  bool _skippedNew = false;
  bool _skippedReview = false;
  bool _cumulativeDone = false;

  final List<_PartEntry> _newParts = [];
  final List<_PartEntry> _reviewParts = [];

  @override
  void initState() {
    super.initState();
    _newParts.add(_PartEntry());
  }

  Widget _buildPartCard(_PartEntry part, List<Map<String, dynamic>> surahs, {required bool isNew}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
      elevation: 1.5,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.emeraldGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isNew ? Icons.auto_stories_rounded : Icons.history_rounded,
                    color: AppTheme.emeraldGreen,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  isNew ? 'حفظ جديد' : 'مراجعة',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 17, fontWeight: FontWeight.w700),
                ),
                const Spacer(),
                if ((isNew ? _newParts.length : _reviewParts.length) > 1)
                  IconButton(
                    onPressed: () => setState(() => (isNew ? _newParts : _reviewParts).remove(part)),
                    icon: Icon(Icons.delete_outline_rounded, color: Colors.red.shade400, size: 22),
                    splashRadius: 20,
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: SearchableDropdown<Map<String, dynamic>>(
                    items: surahs,
                    labelBuilder: (s) => '${s['sora_name_ar']} (${s['sora']})',
                    hint: 'من سورة',
                    onChanged: (val) => part.suraStart = val?['sora'] as int? ?? 0,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(hintText: 'آية', prefixIcon: Icon(Icons.format_list_numbered_rtl, size: 20)),
                    keyboardType: TextInputType.number,
                    onChanged: (v) => part.ayaStart = int.tryParse(v) ?? 0,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: SearchableDropdown<Map<String, dynamic>>(
                    items: surahs,
                    labelBuilder: (s) => '${s['sora_name_ar']} (${s['sora']})',
                    hint: 'إلى سورة',
                    onChanged: (val) => part.suraEnd = val?['sora'] as int? ?? 0,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(hintText: 'آية', prefixIcon: Icon(Icons.format_list_numbered_rtl, size: 20)),
                    keyboardType: TextInputType.number,
                    onChanged: (v) => part.ayaEnd = int.tryParse(v) ?? 0,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'ممتاز', label: Text('ممتاز', style: TextStyle(fontSize: 12))),
                ButtonSegment(value: 'جيد جداً', label: Text('جيد جداً', style: TextStyle(fontSize: 12))),
                ButtonSegment(value: 'جيد', label: Text('جيد', style: TextStyle(fontSize: 12))),
                ButtonSegment(value: 'مقبول', label: Text('مقبول', style: TextStyle(fontSize: 12))),
                ButtonSegment(value: 'ضعيف', label: Text('ضعيف', style: TextStyle(fontSize: 12))),
              ],
              selected: {part.evaluation ?? 'ممتاز'},
              onSelectionChanged: (newSelection) {
                setState(() => part.evaluation = newSelection.first);
              },
              showSelectedIcon: false,
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith((states) {
                  if (states.contains(MaterialState.selected)) return AppTheme.emeraldGreen;
                  return isDark ? Colors.grey[800] : Colors.grey[100];
                }),
                foregroundColor: MaterialStateProperty.resolveWith((states) {
                  if (states.contains(MaterialState.selected)) return Colors.white;
                  return isDark ? Colors.white70 : AppTheme.darkSlate;
                }),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'ملاحظات',
                hintText: 'أي ملاحظات حول هذا التسميع...',
                prefixIcon: Icon(Icons.notes_rounded),
              ),
              minLines: 1,
              maxLines: 3,
              onChanged: (v) {}, // ملاحظات غير مطلوبة حالياً، لكن موجودة
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 350.ms).slideY(begin: 0.1, end: 0);
  }

  @override
  Widget build(BuildContext context) {
    final surahsAsync = ref.watch(surahsProvider);
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 140,
            flexibleSpace: FlexibleSpaceBar(
              title: Text('تقرير ${widget.student.fullName}', style: const TextStyle(fontWeight: FontWeight.bold)),
              background: IslamicHeader(title: 'تقرير الحفظ', subtitle: widget.student.fullName).animate().fadeIn(),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildCheckboxTile('حضر الحلقة', _attended, (v) => setState(() => _attended = v!)),
                _buildCheckboxTile('حضور مبكر', _earlyAttendance, (v) => setState(() => _earlyAttendance = v!)),
                _buildCheckboxTile('تسميع مبكر', _earlyRecitation, (v) => setState(() => _earlyRecitation = v!)),
                _buildCheckboxTile('انصراف في الوقت', _onTimeDeparture, (v) => setState(() => _onTimeDeparture = v!)),
                const Divider(color: AppTheme.warmGold),
                _buildCheckboxTile('لم يسمع الجديد', _skippedNew, (v) => setState(() => _skippedNew = v!)),
                _buildCheckboxTile('لم يسمع المراجعة', _skippedReview, (v) => setState(() => _skippedReview = v!)),
                _buildCheckboxTile('سمع التراكمي', _cumulativeDone, (v) => setState(() => _cumulativeDone = v!)),
                const Divider(color: AppTheme.warmGold),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('الجديد', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 20)),
                    TextButton.icon(
                      icon: const Icon(Icons.add, color: AppTheme.emeraldGreen),
                      label: const Text('إضافة جزء جديد'),
                      onPressed: () => setState(() => _newParts.add(_PartEntry())),
                    ),
                  ],
                ),
                surahsAsync.when(
                  data: (surahs) => Column(children: _newParts.map((p) => _buildPartCard(p, surahs, isNew: true)).toList()),
                  loading: () => const LinearProgressIndicator(),
                  error: (e, _) => Text('خطأ: $e'),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('المراجعة', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 20)),
                    TextButton.icon(
                      icon: const Icon(Icons.add, color: AppTheme.emeraldGreen),
                      label: const Text('إضافة جزء مراجعة'),
                      onPressed: () => setState(() => _reviewParts.add(_PartEntry())),
                    ),
                  ],
                ),
                surahsAsync.when(
                  data: (surahs) => Column(children: _reviewParts.map((p) => _buildPartCard(p, surahs, isNew: false)).toList()),
                  loading: () => const SizedBox(),
                  error: (e, _) => const SizedBox(),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: _submit,
                    icon: const Icon(Icons.save_rounded, color: Colors.white),
                    label: const Text('حفظ التقرير', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.emeraldGreen,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      elevation: 4,
                    ),
                  ),
                ).animate().fadeIn(delay: 200.ms).shimmer(duration: 1000.ms, color: AppTheme.warmGold.withOpacity(0.3)),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckboxTile(String title, bool value, ValueChanged<bool?> onChanged) {
    return CheckboxListTile(
      title: Text(title, style: Theme.of(context).textTheme.bodyLarge),
      value: value,
      onChanged: onChanged,
      activeColor: AppTheme.emeraldGreen,
      checkColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
    );
  }

  Future<void> _submit() async {
    final parts = <SessionPartSubmission>[];
    parts.addAll(_newParts.where((p) => p.isValid).map((p) => SessionPartSubmission(
      type: SessionType.memorization,
      suraStart: p.suraStart,
      ayaStart: p.ayaStart,
      suraEnd: p.suraEnd,
      ayaEnd: p.ayaEnd,
      evaluation: p.evaluation,
    )));
    parts.addAll(_reviewParts.where((p) => p.isValid).map((p) => SessionPartSubmission(
      type: SessionType.review,
      suraStart: p.suraStart,
      ayaStart: p.ayaStart,
      suraEnd: p.suraEnd,
      ayaEnd: p.ayaEnd,
      evaluation: p.evaluation,
    )));

    final submission = SessionSubmission(
      studentSupabaseId: widget.student.supabaseId,
      groupSupabaseId: widget.groupId,
      teacherSupabaseId: widget.teacherId,
      sessionDate: DateTime.now(),
      attended: _attended,
      earlyAttendance: _earlyAttendance,
      earlyRecitation: _earlyRecitation,
      onTimeDeparture: _onTimeDeparture,
      cumulativeDone: _cumulativeDone,
      skippedNew: _skippedNew,
      skippedReview: _skippedReview,
      parts: parts,
    );

    try {
      final result = await ref.read(teacherProvider).submitFullSession(submission);
      HapticFeedback.mediumImpact();
      if (!mounted) return;
      await showDialog(context: context, builder: (_) => SessionPointsDialog(result: result));
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطأ: $e')));
    }
  }
}

class _PartEntry {
  int suraStart = 0;
  int ayaStart = 0;
  int suraEnd = 0;
  int ayaEnd = 0;
  String? evaluation = 'ممتاز';

  bool get isValid => suraStart > 0 && ayaStart > 0 && suraEnd > 0 && ayaEnd > 0;
}