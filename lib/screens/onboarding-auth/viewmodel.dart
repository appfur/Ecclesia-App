import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:myapp/core/router/app_router.dart';
import 'package:myapp/screens/onboarding-auth/google_signin.dart';

import '../../widgets/error-snackbar.dart';

class OnboardingViewModel extends ChangeNotifier {
  void onSignUpPressed() {
    GoRouter.of(navigatorKey.currentContext!).push('/signup');
  }

  void onLoginPressed() {
    GoRouter.of(navigatorKey.currentContext!).push('/login');
  }

  Future<void> onGoogleSignIn() async {
    try {
      final userCred = await signInWithGoogle();
      if (userCred == null) return;

      final user = userCred.user;
      if (user == null) return;

      // 🔍 Check if Firestore user document already exists
      final userDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

      // 👤 Navigate based on whether it's a first-time sign-in
      if (userDoc.exists) {
        navigatorKey.currentContext?.go('/home');
      } else {
        navigatorKey.currentContext?.go('/acc-success');
      }
    } catch (e) {
      showError("Google sign-in failed. Please try again.");
    }
  }

  void onAppleSignIn() {
    // TODO: Implement Apple sign-in logic
  }
}
