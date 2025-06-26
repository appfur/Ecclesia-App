import 'package:firebase_auth/firebase_auth.dart';

String getErrorMessage(FirebaseAuthException e) {
  switch (e.code) {
    case 'invalid-email':
      return 'The email address is badly formatted.';
    case 'user-disabled':
      return 'This account has been disabled.';
    case 'user-not-found':
      return 'No user found for this email.';
    case 'wrong-password':
      return 'Incorrect password. Please try again.';
    case 'network-request-failed':
      return 'Network error. Check your connection.';
    default:
      return 'Authentification failed: ${e.message ?? 'Unknown error'}';
  }
}
