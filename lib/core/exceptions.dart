import 'package:flutter/material.dart';

class AppException implements Exception {
  final String message;
  final String? details;
  AppException({required this.message, this.details});
  @override
  String toString() => 'AppException: $message${details != null ? ' ($details)' : ''}';
}

class NetworkException extends AppException {
  NetworkException() : super(message: 'لا يوجد اتصال بالإنترنت');
}

class AuthException extends AppException {
  AuthException(String msg) : super(message: msg);
}

class DatabaseException extends AppException {
  DatabaseException(String msg) : super(message: msg);
}

class SyncException extends AppException {
  SyncException(String details) : super(message: 'خطأ في المزامنة', details: details);
}

class ErrorHandler {
  static final Map<String, DateTime> _lastShown = {};
  static void showError(BuildContext context, AppException error) {
    final key = error.message;
    final now = DateTime.now();
    if (_lastShown.containsKey(key) &&
        now.difference(_lastShown[key]!) < const Duration(seconds: 3)) {
      return;
    }
    _lastShown[key] = now;
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
          action: SnackBarAction(label: 'حسنًا', onPressed: () {}),
        ),
      );
    }
  }

  static void showSuccess(BuildContext context, String msg) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}