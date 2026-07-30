import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/student_profile.dart';
import '../core/theme.dart';

class StudentEditDialog extends StatefulWidget {
  final StudentProfile profile;
  final Future<void> Function(int newTarget, int reviewTarget) onSave;

  const StudentEditDialog({
    super.key,
    required this.profile,
    required this.onSave,
  });

  @override
  State<StudentEditDialog> createState() => _StudentEditDialogState();
}

class _StudentEditDialogState extends State<StudentEditDialog> {
  late final TextEditingController _newCtrl;
  late final TextEditingController _reviewCtrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _newCtrl = TextEditingController(text: widget.profile.newPagesTarget.toString());
    _reviewCtrl = TextEditingController(text: widget.profile.reviewPagesTarget.toString());
  }

  @override
  void dispose() {
    _newCtrl.dispose();
    _reviewCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AlertDialog(
      backgroundColor: isDark ? const Color(0xFF1E1E2E) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.warmGold.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.edit_note, color: AppTheme.warmGold),
          ),
          const SizedBox(width: 12),
          const Text('تعديل الورد',
              style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _newCtrl,
            decoration: InputDecoration(
              labelText: 'ورد الحفظ الجديد',
              prefixIcon: const Icon(Icons.book),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _reviewCtrl,
            decoration: InputDecoration(
              labelText: 'ورد المراجعة',
              prefixIcon: const Icon(Icons.refresh),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            keyboardType: TextInputType.number,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: _saving
              ? null
              : () async {
                  final newTarget = int.tryParse(_newCtrl.text);
                  final reviewTarget = int.tryParse(_reviewCtrl.text);
                  if (newTarget == null || reviewTarget == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('أدخل أرقاماً صحيحة')),
                    );
                    return;
                  }
                  setState(() => _saving = true);
                  try {
                    HapticFeedback.mediumImpact();
                    await widget.onSave(newTarget, reviewTarget);
                    if (mounted) Navigator.pop(context, true);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('خطأ: $e')));
                  } finally {
                    if (mounted) setState(() => _saving = false);
                  }
                },
          child: _saving
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('حفظ'),
        ),
      ],
    );
  }
}