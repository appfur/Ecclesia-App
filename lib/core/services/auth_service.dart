import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthStateNotifier extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  AuthStateNotifier() {
    _auth.authStateChanges().listen((_) => notifyListeners());
  }

  bool get isLoggedIn => _auth.currentUser != null;
}

class AuthNotifier extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? _user;
  bool _isLoading = true;

  AuthNotifier() {
    _auth.idTokenChanges().listen((user) async {
      _user = user;

      // ✅ User is signed out or deleted or token revoked
      //if (_user == null) {
      //  try {
      // await _auth.signOut(); // Safe, even if already signed out
      //  } catch (e) {
      //  print('⚠️ Error signing out: $e');
      //  }
      // }

      _isLoading = false;
      notifyListeners();
    });
  }

  bool get isLoggedIn => _user != null;
  bool get isLoading => _isLoading;
}
