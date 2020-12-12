import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Stream<String> get onAuthStateChanged => _firebaseAuth.authStateChanges().map(
        (User user) => user?.uid,
      );

  Future<String> getCurrentUID() async {
    return (_firebaseAuth.currentUser).uid;
  }

  Future getCurrentUser() async {
    return _firebaseAuth.currentUser;
  }

  getProfileImage() {
    if (_firebaseAuth.currentUser.photoURL != null) {
      return Image.network(
        _firebaseAuth.currentUser.photoURL.toString(),
        height: 100,
        width: 100,
      );
    } else {
      return Icon(
        Icons.account_circle,
        color: Colors.blue.shade400,
        size: 100,
      );
    }
  }
}
