import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:myapp/widgets/error-snackbar.dart';

/*Future<UserCredential?> signInWithGoogle() async {
  try {
    // Trigger Google sign-in
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) return null; // user cancelled

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    // Create credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Sign in with Firebase
    final userCredential = await FirebaseAuth.instance.signInWithCredential(
      credential,
    );
    final user = userCredential.user;
    if (user == null) return null;

    // Reference to Firestore user doc
    final userDoc = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid);

    final userData = await userDoc.get();

    // If this is a new user, create a Firestore document
    if (!userData.exists) {
      await userDoc.set({
        'uid': user.uid,
        'email': user.email,
        'username':
            user.displayName ?? user.email?.split('@').first ?? 'Unknown',
        'createdAt': FieldValue.serverTimestamp(),
        // Add more default fields as needed
      });
    }

    return userCredential;
  } catch (e) {
   // print('🔴 Google Sign-In Error: $e');
    showError('Google Sign-In failed.Please try again');
    rethrow;
  }
}*/

Future<UserCredential?> signInWithGoogle() async {
  try {
    final googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) return null;

    final googleAuth = await googleUser.authentication;

    final googleCredential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // 🚧 Check if email is already in use with another provider
    final email = googleUser.email;
    final existingMethods = await FirebaseAuth.instance
        .fetchSignInMethodsForEmail(email);

    if (existingMethods.contains('password')) {
      // ⚠️ Email/password account already exists
      showError(
        "An account with this email exists using Email/Password. Please log in with that method.",
      );
      return null;
    }

    // ✅ Safe to continue with Google
    final userCred = await FirebaseAuth.instance.signInWithCredential(
      googleCredential,
    );

    // Create Firestore doc if needed
    final userDoc = FirebaseFirestore.instance
        .collection('users')
        .doc(userCred.user!.uid);
    if (!(await userDoc.get()).exists) {
      await userDoc.set({
        'uid': userCred.user!.uid,
        'email': userCred.user!.email,
        // 'username': userCred.user!.displayName ?? 'User',
        'username':
            userCred.user!.displayName ??
            userCred.user!.email?.split('@').first ??
            'Unknown Username',

        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    return userCred;
  } on FirebaseAuthException catch (e) {
    if (e.code == 'account-exists-with-different-credential') {
      showError("Account already exists with a different sign-in method.");
    } else {
      showError("Google Sign-In failed: ${e.message}");
    }
    return null;
  } catch (e) {
    showError("Something went wrong. Please try again.");
    return null;
  }
}
