import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:myapp/core/router/app_router.dart';
import 'package:myapp/widgets/error-snackbar.dart';
import 'package:shared_preferences/shared_preferences.dart';

void showLogoutConfirmation(BuildContext context, VoidCallback onConfirm) {
  showCupertinoModalPopup(
    context: context,
    builder:
        (_) => CupertinoActionSheet(
          title: const Text('Are you sure?'),
          message: const Text(
            'Do you really want to logout from your account?',
          ),
          actions: [
            CupertinoActionSheetAction(
              isDestructiveAction: true,
              onPressed: () {
                logout();
                Navigator.pop(context);
                // onConfirm(); // this triggers `vm.logout()`
              },
              child: const Text('Logout'),
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ),
  );
}

Future<void> logout() async {
  try {
    // Firebase sign out
    await FirebaseAuth.instance.signOut();

    // Google sign out if connected
    final googleSignIn = GoogleSignIn();
    if (await googleSignIn.isSignedIn()) {
      await googleSignIn.disconnect();
    }
    //await _auth.signOut();
    //  notifyListeners();
    // Clear SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    // Navigate to login or onboarding
    navigatorKey.currentContext?.go('/onboarding'); // update as needed
  } catch (e) {
    //debugPrint('Logout failed: $e');
    showError('Logout failed');
    // Optionally show a snackbar
  }
}
