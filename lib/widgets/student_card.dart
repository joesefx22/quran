import 'package:flutter/material.dart';
import '../models/local_user.dart';

class StudentCard extends StatelessWidget {
  final User student;
  final double attendancePercent;
  final VoidCallback? onTap;

  const StudentCard({
    super.key,
    required this.student,
    this.attendancePercent = 0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      child: ListTile(
        leading: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 48,
              height: 48,
              child: CircularProgressIndicator(
                value: attendancePercent / 100,
                strokeWidth: 4,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(
                  attendancePercent > 80 ? Colors.green : Colors.orange,
                ),
              ),
            ),
            CircleAvatar(
              backgroundColor: Colors.teal,
              radius: 18,
              child: Text(
                student.fullName.isNotEmpty ? student.fullName[0] : '?',
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ],
        ),
        title: Text(student.fullName),
        subtitle: Text('الحضور: ${attendancePercent.toStringAsFixed(0)}%'),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}