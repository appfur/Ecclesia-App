import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/maps/errro_maps.dart';
import '../../core/router/app_router.dart';
import '../../widgets/error-snackbar.dart';

class LoginViewModel extends ChangeNotifier {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool showPassword = false;
  bool isLoading = false;

  void togglePasswordVisibility() {
    showPassword = !showPassword;
    notifyListeners();
  }

  void onSignup() {
    navigatorKey.currentContext?.push('/signup');
  }

  Future<void> onForgotPassword() async {
    // Optional: Navigate to forgot password page
    // debugPrint('Forgot password tapped');
    // context.push('/forgot-password');
    await FirebaseAuth.instance.signOut();
    navigatorKey.currentContext?.go('/forgot-password');
  }

  Future<void> login() async {
    isLoading = true;
    notifyListeners();
    try {
      final email = emailController.text.trim();
      final password = passwordController.text.trim();

      if (email.isEmpty || password.isEmpty) {
        showError("Email and password cannot be empty");
        return;
      }

      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      //navigatorKey.currentContext?.go('/home');
      final user = FirebaseAuth.instance.currentUser;

      if (user != null && user.emailVerified) {
        navigatorKey.currentContext?.go('/home');
      } else {
        // Optionally send email again
        // await user?.sendEmailVerification();

        navigatorKey.currentContext?.go('/verify-email');
      }
    } on FirebaseAuthException catch (e) {
      final msg = getErrorMessage(e);
      showError(msg);
    } catch (e) {
      showError("Something went wrong. Please try again.");
      debugPrint("🔴 Login error: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
