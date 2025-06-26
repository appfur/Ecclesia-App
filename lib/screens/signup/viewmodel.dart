import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/maps/errro_maps.dart';
import '../../core/router/app_router.dart';
import '../../widgets/error-snackbar.dart';

class SignupViewModel extends ChangeNotifier {
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  // final dayController = TextEditingController();
  // final monthController = TextEditingController();
  // final yearController = TextEditingController();

  bool showPassword = false;
  bool isLoading = false;
  void togglePasswordVisibility() {
    showPassword = !showPassword;
    notifyListeners();
  }

  Future<void> register() async {
    isLoading = true;
    notifyListeners();
    try {
      final username = usernameController.text.trim();
      final email = emailController.text.trim();
      final password = passwordController.text.trim();
      // final dob =
      //    "${yearController.text}-${monthController.text}-${dayController.text}";

      if ([username, email, password].any((e) => e.isEmpty)) {
        showError("All fields must be filled");
        return;
      }

      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      final user = userCredential.user;
      if (user == null) {
        showError("User creation failed. Try again.");
        return;
      }

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'username': username,
        'email': email,
        // 'birthday': dob,
        'createdAt': FieldValue.serverTimestamp(),
      });

      navigatorKey.currentContext?.go('/acc-success');
    } on FirebaseAuthException catch (e) {
      final msg = getErrorMessage(e);
      showError(msg);
    } catch (e) {
      showError("Something went wrong. Please try again.");
      debugPrint("🔴 Signup error: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    //   dayController.dispose();
    //  monthController.dispose();
    // yearController.dispose();
    super.dispose();
  }
}
