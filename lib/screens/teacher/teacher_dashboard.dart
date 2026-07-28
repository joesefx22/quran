import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';

class TeacherDashboard extends ConsumerWidget {
  const TeacherDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ✅ حساب weekStart في الدالة نفسها (لمرة واحدة) عبر cached variable
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 6));

    return Scaffold(
      appBar: AppBar(title: const Text('لوحة المشرف')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('أهلاً بك في لوحة تحكم المشرف'),
          // يمكن إضافة بطاقات أو أزرار للانتقال إلى إدارة الحلقات
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/day-session'); // مثال
            },
            child: const Text('حلقة اليوم'),
          ),
        ],
      ),
    );
  }
}