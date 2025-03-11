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
  Future<String?> signUpWithEmail(String email, String password, String userType, BuildContext context) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Save user data to Firestore
      User? user = userCredential.user;
      if (user != null) {
        await _firestore.collection("users").doc(user.uid).set({
          'uid': user.uid,
          'email': email,
          'userType': userType,
          'createdAt': FieldValue.serverTimestamp(),
        });

        // Navigate based on user type
        if (userType == "Teacher") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => AdminDashboard()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Studentpage()),
          );
        }
      }
      return null; // Success
    } catch (e) {
      return e.toString(); // Return error message
    }
  }

  /// **🔑 Sign In with Email & Password**
  Future<String?> signInWithEmail(String email, String password, String expectedUserType) async {
    try {
      // Step 1: Sign in the user with email & password
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      User? user = userCredential.user;

      if (user != null) {
        // Step 2: Fetch user details from Firestore
        DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();

        if (userDoc.exists) {
          String userType = userDoc['userType'] ?? "";

          // Step 3: Check if userType matches the expected type
          if (userType != expectedUserType) {
            return "Access denied: Incorrect user type";
          }

          return null; // Success
        } else {
          return "User not found in database";
        }
      }

      return "Authentication failed";
    } catch (e) {
      return e.toString(); // Return error message
    }
  }

  /// **🔵 Google Sign-In**
  Future<String?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return "Google Sign-In cancelled";

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      UserCredential userCredential = await _auth.signInWithCredential(credential);
      User? user = userCredential.user;

      if (user != null) {
        // Store user data in Firestore
        DocumentReference userRef = _firestore.collection('users').doc(user.uid);

        // Check if user already exists
        DocumentSnapshot userDoc = await userRef.get();
        if (!userDoc.exists) {
          await userRef.set({
            'uid': user.uid,
            'name': user.displayName ?? "No Name",
            'email': user.email ?? "No Email",
            'photoUrl': user.photoURL ?? "",

            'createdAt': FieldValue.serverTimestamp(),
            'lastLoginAt': FieldValue.serverTimestamp(),
          });
        } else {
          // Update last login time
          await userRef.update({
            'lastLoginAt': FieldValue.serverTimestamp(),
          });
        }

      }

      return null; // Success
    } catch (e) {
      return e.toString();
    }
  }

  /// **🚪 Sign Out**
  Future<void> signOut() async {
    await _auth.signOut();
    await GoogleSignIn().signOut();
    notifyListeners();
  }
}
