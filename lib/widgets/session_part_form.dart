import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/session_part.dart';
import '../core/theme.dart';
import 'searchable_dropdown.dart';

class SessionPartWidgetController {
  final TextEditingController surahStartCtrl = TextEditingController();
  final TextEditingController ayaStartCtrl = TextEditingController();
  final TextEditingController surahEndCtrl = TextEditingController();
  final TextEditingController ayaEndCtrl = TextEditingController();
  String? evaluation = 'ممتاز';
  final TextEditingController notesCtrl = TextEditingController();
  bool isExtra = false;

  SessionPartData? getData() {
    final sStart = int.tryParse(surahStartCtrl.text);
    final aStart = int.tryParse(ayaStartCtrl.text);
    final sEnd = int.tryParse(surahEndCtrl.text);
    final aEnd = int.tryParse(ayaEndCtrl.text);
    if (sStart == null || aStart == null || sEnd == null || aEnd == null)
      return null;
    if (sStart <= 0 || aStart <= 0 || sEnd <= 0 || aEnd <= 0) return null;
    if (sStart == sEnd && aStart > aEnd) return null;
    return SessionPartData(
      suraStart: sStart,
      ayaStart: aStart,
      suraEnd: sEnd,
      ayaEnd: aEnd,
      evaluation: evaluation,
      notes: notesCtrl.text,
      isExtra: isExtra,
    );
  }

  void dispose() {
    surahStartCtrl.dispose();
    ayaStartCtrl.dispose();
    surahEndCtrl.dispose();
    ayaEndCtrl.dispose();
    notesCtrl.dispose();
  }
}

class SessionPartData {
  final int suraStart;
  final int ayaStart;
  final int suraEnd;
  final int ayaEnd;
  final String? evaluation;
  final String? notes;
  final bool isExtra;
  SessionPartData({
    required this.suraStart,
    required this.ayaStart,
    required this.suraEnd,
    required this.ayaEnd,
    this.evaluation,
    this.notes,
    required this.isExtra,
  });
}

class SessionPartForm extends StatefulWidget {
  final SessionPartWidgetController controller;
  final SessionType partType;
  final List<Map<String, dynamic>> surahs;
  final VoidCallback? onDelete;
  final int index; // لترتيب الأنيميشن

  const SessionPartForm({
    super.key,
    required this.controller,
    required this.partType,
    required this.surahs,
    this.onDelete,
    this.index = 0,
  });

  @override
  State<SessionPartForm> createState() => _SessionPartFormState();
}

class _SessionPartFormState extends State<SessionPartForm> {
  String? _startAyahError;
  String? _endAyahError;
  String? _rangeError;

  bool _isAyahValid(int sura, int ayah) {
    final surah = widget.surahs.firstWhere(
      (s) => s['sora'] == sura,
      orElse: () => {},
    );
    if (surah.isEmpty) return false;
    final ayahCount = surah['ayah_count'] as int?;
    if (ayahCount == null) return true;
    return ayah >= 1 && ayah <= ayahCount;
  }

  String? _validateRange() {
    final sStart = int.tryParse(widget.controller.surahStartCtrl.text);
    final aStart = int.tryParse(widget.controller.ayaStartCtrl.text);
    final sEnd = int.tryParse(widget.controller.surahEndCtrl.text);
    final aEnd = int.tryParse(widget.controller.ayaEndCtrl.text);
    if (sStart == null || aStart == null || sEnd == null || aEnd == null)
      return null;

    if (sStart < sEnd) return null;
    if (sStart > sEnd) return 'سورة البداية بعد سورة النهاية';
    if (aStart > aEnd) return 'آية البداية بعد آية النهاية';
    return null;
  }

  void _validateStartAyah() {
    final sura = int.tryParse(widget.controller.surahStartCtrl.text);
    final ayah = int.tryParse(widget.controller.ayaStartCtrl.text);
    if (sura != null && ayah != null) {
      setState(() {
        _startAyahError =
            _isAyahValid(sura, ayah) ? null : 'الآية غير موجودة';
        _rangeError = _validateRange();
      });
    }
  }

  void _validateEndAyah() {
    final sura = int.tryParse(widget.controller.surahEndCtrl.text);
    final ayah = int.tryParse(widget.controller.ayaEndCtrl.text);
    if (sura != null && ayah != null) {
      setState(() {
        _endAyahError =
            _isAyahValid(sura, ayah) ? null : 'الآية غير موجودة';
        _rangeError = _validateRange();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final String title =
        widget.partType == SessionType.memorization ? 'حفظ جديد' : 'مراجعة';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
      elevation: 1.5,
      shadowColor: AppTheme.emeraldGreen.withOpacity(0.2),
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
                    widget.partType == SessionType.memorization
                        ? Icons.auto_stories_rounded
                        : Icons.history_rounded,
                    color: AppTheme.emeraldGreen,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(fontSize: 17, fontWeight: FontWeight.w700),
                ),
                const Spacer(),
                if (widget.onDelete != null)
                  IconButton(
                    onPressed: widget.onDelete,
                    icon: Icon(
                      Icons.delete_outline_rounded,
                      color: Colors.red.shade400,
                      size: 22,
                    ),
                    tooltip: 'حذف هذا الجزء',
                    splashRadius: 20,
                  ),
              ],
            ),
            if (_rangeError != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber_rounded,
                        size: 16, color: Colors.orange.shade700),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(_rangeError!,
                          style: TextStyle(
                              color: Colors.orange.shade700, fontSize: 13)),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            // Row start
            Row(
              children: [
                Expanded(
                  child: SearchableDropdown<Map<String, dynamic>>(
                    items: widget.surahs,
                    labelBuilder: (s) =>
                        '${s['sora_name_ar']} (${s['sora']})',
                    hint: 'من سورة',
                    onChanged: (val) {
                      widget.controller.surahStartCtrl.text =
                          val?['sora'].toString() ?? '';
                      _validateStartAyah();
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: widget.controller.ayaStartCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'آية',
                      errorText: _startAyahError,
                      prefixIcon: const Icon(Icons.format_list_numbered_rtl,
                          size: 20),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onChanged: (_) => _validateStartAyah(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Row end
            Row(
              children: [
                Expanded(
                  child: SearchableDropdown<Map<String, dynamic>>(
                    items: widget.surahs,
                    labelBuilder: (s) =>
                        '${s['sora_name_ar']} (${s['sora']})',
                    hint: 'إلى سورة',
                    onChanged: (val) {
                      widget.controller.surahEndCtrl.text =
                          val?['sora'].toString() ?? '';
                      _validateEndAyah();
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: widget.controller.ayaEndCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'آية',
                      errorText: _endAyahError,
                      prefixIcon: const Icon(Icons.format_list_numbered_rtl,
                          size: 20),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onChanged: (_) => _validateEndAyah(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            // Evaluation
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                    value: 'ممتاز',
                    label: Text('ممتاز', style: TextStyle(fontSize: 12))),
                ButtonSegment(
                    value: 'جيد جداً',
                    label: Text('جيد جداً', style: TextStyle(fontSize: 12))),
                ButtonSegment(
                    value: 'جيد',
                    label: Text('جيد', style: TextStyle(fontSize: 12))),
                ButtonSegment(
                    value: 'مقبول',
                    label: Text('مقبول', style: TextStyle(fontSize: 12))),
                ButtonSegment(
                    value: 'ضعيف',
                    label: Text('ضعيف', style: TextStyle(fontSize: 12))),
              ],
              selected: {widget.controller.evaluation ?? 'ممتاز'},
              onSelectionChanged: (newSelection) {
                setState(() {
                  widget.controller.evaluation = newSelection.first;
                });
              },
              showSelectedIcon: false,
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith((states) {
                  if (states.contains(MaterialState.selected)) {
                    return AppTheme.emeraldGreen;
                  }
                  return isDark ? Colors.grey[800] : Colors.grey[100];
                }),
                foregroundColor: MaterialStateProperty.resolveWith((states) {
                  if (states.contains(MaterialState.selected)) {
                    return Colors.white;
                  }
                  return isDark ? Colors.white70 : AppTheme.darkSlate;
                }),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: widget.controller.notesCtrl,
              decoration: InputDecoration(
                labelText: 'ملاحظات',
                hintText: 'أي ملاحظات حول هذا التسميع...',
                prefixIcon: const Icon(Icons.notes_rounded),
                alignLabelWithHint: true,
              ),
              minLines: 1,
              maxLines: 3,
            ),
          ],
        ),
      ),
    ).animate().fadeIn(
          duration: 350.ms,
          delay: (60 * widget.index).ms,
        ).slideY(begin: 0.1, end: 0, duration: 300.ms);
  }
}