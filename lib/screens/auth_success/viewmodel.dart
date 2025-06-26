// view_models/countdown_view_model.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/core/router/app_router.dart';

class CountdownViewModel extends ChangeNotifier {
  int _count = 3;
  int get count => _count;

  void startCountdown(BuildContext context) {
    Timer.periodic(Duration(seconds: 1), (timer) {
      _count--;
      notifyListeners();
      if (_count == 0) {
        timer.cancel();
        navigatorKey.currentContext?.go('/home');
        //GoRouter.of(context).go('/next');
      }
    });
  }
}
