import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:examgo/Screens/Login_page.dart';
import 'package:examgo/Student/studentpage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Teacher/Admindashboard.dart';

class CustomAuthProvider extends ChangeNotifier {
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

        // ✅ Store login state
        await _saveLoginState(userType);

        // ✅ Navigate & Clear History
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (context) =>
              userType == "Teacher" ? const AdminDashboard() : const Studentpage()),
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

          // ✅ Store login state
          await _saveLoginState(userType);

          // ✅ Navigate & Clear History
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (context) =>
                userType == "Teacher" ? const AdminDashboard() : const Studentpage()),
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

        // ✅ Store login state
        await _saveLoginState(userType);

        // ✅ Navigate after successful login
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (context) =>
              userType == "Teacher" ? const AdminDashboard() : const Studentpage()),
              (route) => false,
        );

        notifyListeners();
      }
    } catch (e) {
      _showSnackbar(context, "Error: ${e.toString()}");
    }
  }

  /// **🚪 Sign Out**
  Future<void> signOut(BuildContext context) async {
    try {
      await _auth.signOut();
      await GoogleSignIn().signOut();

      // ✅ Clear login state
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      _showSnackbar(context, "Signed out successfully");

      // Navigate to LoginPage after logout
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
            (route) => false,
      );

      notifyListeners();
    } catch (e) {
      _showSnackbar(context, "Error signing out: ${e.toString()}");
    }
  }

  /// **🔐 Save Login State**
  Future<void> _saveLoginState(String userType) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('userType', userType);
  }

  /// **🔔 Show Snackbar**
  void _showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}
