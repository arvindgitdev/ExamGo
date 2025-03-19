import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:examgo/Student/studentpage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../Teacher/Admindashboard.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  /// **🔥 Sign Up with Email & Password**
  Future<void> signUpWithEmail(
      String email, String password, String userType, BuildContext context) async {
    try {
      UserCredential userCredential =
      await _auth.createUserWithEmailAndPassword(email: email, password: password);
      User? user = userCredential.user;

      if (user != null) {
        await _firestore.collection("users").doc(user.uid).set({
          'uid': user.uid,
          'email': email,
          'userType': userType,
          'createdAt': FieldValue.serverTimestamp(),
        });

        // ✅ Navigate & Clear History
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (context) =>
              userType == "Teacher" ? AdminDashboard() : Studentpage()),
              (route) => false,
        );

        notifyListeners();
      }
    } catch (e) {
      _showSnackbar(context, "Error: ${e.toString()}");
    }
  }

  /// **🔑 Sign In with Email & Password**
  Future<void> signInWithEmail(
      String email, String password, String expectedUserType, BuildContext context) async {
    try {
      UserCredential userCredential =
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      User? user = userCredential.user;

      if (user != null) {
        DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();

        if (userDoc.exists) {
          String userType = userDoc['userType'] ?? "";

          if (userType != expectedUserType) {
            _showSnackbar(context, "Access denied: Incorrect user type");
            return;
          }

          // ✅ Navigate & Clear History
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (context) =>
                userType == "Teacher" ? AdminDashboard() : Studentpage()),
                (route) => false,
          );

          notifyListeners();
        } else {
          _showSnackbar(context, "User not found in database");
        }
      }
    } catch (e) {
      _showSnackbar(context, "Error: ${e.toString()}");
    }
  }

  /// **🔵 Google Sign-In**
  Future<void> signInWithGoogle(String userType, BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await _auth.signInWithCredential(credential);
      User? user = userCredential.user;

      if (user != null) {
        DocumentReference userRef = _firestore.collection('users').doc(user.uid);
        DocumentSnapshot userDoc = await userRef.get();

        if (userDoc.exists) {
          String existingUserType = userDoc['userType'] ?? "";

          if (existingUserType.isNotEmpty && existingUserType != userType) {
            _showSnackbar(context, "Access denied: Incorrect user type");
            return;
          }
        } else {
          await userRef.set({
            'uid': user.uid,
            'name': user.displayName ?? "No Name",
            'email': user.email ?? "No Email",
            'photoUrl': user.photoURL ?? "",
            'userType': userType,
            'createdAt': FieldValue.serverTimestamp(),
            'lastLoginAt': FieldValue.serverTimestamp(),
          });
        }

        // ✅ Navigate after successful login
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (context) =>
              userType == "Teacher" ? AdminDashboard() : Studentpage()),
              (route) => false,
        );

        notifyListeners();
      }
    } catch (e) {
      _showSnackbar(context, "Error: ${e.toString()}");
    }
  }

  /// **🔁 Forgot Password**
  Future<void> resetPassword(String email, BuildContext context) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      _showSnackbar(context, "Password reset link sent to your email");
    } catch (e) {
      _showSnackbar(context, "Error: ${e.toString()}");
    }
  }

  /// **🚪 Sign Out**
  Future<void> signOut(BuildContext context) async {
    try {
      await _auth.signOut();
      await GoogleSignIn().signOut();
      _showSnackbar(context, "Signed out successfully");
      notifyListeners();
    } catch (e) {
      _showSnackbar(context, "Error signing out: ${e.toString()}");
    }
  }

  /// **🔔 Show Snackbar**
  void _showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}
