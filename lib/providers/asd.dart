import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthGoogleProvider with ChangeNotifier {
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  bool _isInitialized = false;

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
      print('Login successful');
    } catch (e) {
      print('Login failed: $e');
      print("Waduh, error pas login: $e");
    }
  }
}
