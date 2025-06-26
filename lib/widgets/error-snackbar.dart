import 'package:flutter/material.dart';
import 'package:myapp/core/router/app_router.dart';

void showError(String message) {
  final ctx = navigatorKey.currentContext;
  if (ctx == null) return;

  ScaffoldMessenger.of(ctx).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: Colors.red.shade600,
      behavior: SnackBarBehavior.floating,
    ),
  );
}
