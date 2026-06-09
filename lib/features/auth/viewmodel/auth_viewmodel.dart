import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:percobaan/data/services/auth_service.dart';

class AuthViewModel with ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _user;
  User? get user => _user;
  bool get isLoggedIn => _user != null;

  AuthViewModel() {
    // Dengerin perubahan status login dari Firebase
    _authService.authStateChanges.listen((user) {
      _user = user;
      notifyListeners();
    });
  }

  Future<void> signInWithGoogle() async {
    try {
      _user = await _authService.signInWithGoogle();
      notifyListeners();
    } catch (e) {
      debugPrint('Login gagal: $e');
      rethrow; // Lempar ke UI biar bisa tampilin error ke user
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }
}