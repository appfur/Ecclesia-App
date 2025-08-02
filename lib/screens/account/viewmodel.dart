import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../../core/router/app_router.dart';

class AccountViewModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final supabase.SupabaseClient _supabase = supabase.Supabase.instance.client;

  User? get user => _auth.currentUser;

  bool get isLoggedIn => user != null;
  bool get isGoogleUser =>
      user?.providerData.any((p) => p.providerId == 'google.com') ?? false;

  Future<void> updateProfilePicture(Uint8List imageBytes) async {
    final uid = user!.uid;
    final fileName = '$uid.jpg';

    await _supabase.storage
        .from('profiles')
        .uploadBinary(
          fileName,
          imageBytes,
          fileOptions: const supabase.FileOptions(upsert: true),
        );

    final publicUrl = _supabase.storage.from('profiles').getPublicUrl(fileName);
    await user!.updatePhotoURL(publicUrl);
    await user!.reload();
    notifyListeners();
  }

  void goTo(String route) {
    GoRouter.of(navigatorKey.currentContext!).go(route);
  }

  Future<void> logout() async {
    await _auth.signOut();
    notifyListeners();
  }
}
