import 'package:flutter/material.dart';
import '../core/theme.dart';

class LoadingIndicator extends StatelessWidget {
  final String? message;
  final double size;
  const LoadingIndicator({super.key, this.message, this.size = 36});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.emeraldGreen),
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: TextStyle(
                fontSize: 15,
                color: AppTheme.darkSlate.withOpacity(0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}