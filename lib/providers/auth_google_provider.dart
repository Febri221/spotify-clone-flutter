import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthGoogleProvider with ChangeNotifier {
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  
  
  User? _user = FirebaseAuth.instance.currentUser;
  User? get user => _user;

  bool _isInitialized = false;

  AuthGoogleProvider() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  Future<void> signInWithGoogle() async {
    try {
      if (!_isInitialized) {
        await _googleSignIn.initialize(
          serverClientId: '940281609046-819rbgtmnd9ok7eqh64k0i445jf2javl.apps.googleusercontent.com',
        );
        
        _isInitialized = true;
      }
      final googleUser = await _googleSignIn.authenticate();

      final GoogleSignInAuthentication googleAuth = googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
      _user = FirebaseAuth.instance.currentUser;
      print('Login successful');
    } catch (e) {
      print('Login failed: $e');
      print("Waduh, error pas login: $e");
    }
  }

}
