import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:percobaan/widget/bottom_navbar.dart';
import 'package:percobaan/screens/auth/login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<RegisterPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isloading = false;

  Future<void> loginUser() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showMessage('Email dan Password harus diisi');
      return;
    }

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      _showMessage('Berhasil login!');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        _showMessage('Akun tidak ditemukan');
      } else if (e.code == 'wrong-password') {
        _showMessage('Password salah');
      } else {
        _showMessage('Error: ${e.message}');
      }
    }
  }

  Future<void> registerUser() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showMessage('Email dan Password harus diisi');
      return;
    }

    setState(() {
      _isloading = true;
    });

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      _showMessage('Akun berhasil dibuat');

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => BottomNavbar()),
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        _showMessage('Email sudah digunakan');
      } else if (e.code == 'invalid-email') {
        _showMessage('Fomat email tidak valid');
      } else if (e.code == 'weak-password') {
        _showMessage('Password terlalu lemah (min 6 karakter)');
      } else {
        _showMessage('Error: ${e.message}');
      }
    } finally {
      setState(() {
        _isloading = false;
      });
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Color(0xFF191414),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          FlutterLogo(size: 100,),
          SizedBox(height: 50),
          Text(
            'Register Your Music Accout',
            style: TextStyle(color: Colors.white, fontSize: 25),
          ),

          SizedBox(height: 35),
          Center(
            child: Column(
              children: <Widget>[
                Container(
                  width: 250,
                  height: 50,
                  decoration: BoxDecoration(),
                  child: TextField(
                    controller: _emailController,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Email',
                      hintStyle: TextStyle(color: Colors.grey.shade800),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide(color: Colors.green, width: 2),
                      ),
                      prefixIcon: Icon(Icons.email, color: Colors.grey),
                    ),
                  ),
                ),
                SizedBox(height: 15.0),
                Container(
                  width: 250,
                  height: 50,
                  decoration: BoxDecoration(),
                  child: TextField(
                    obscureText: true,
                    controller: _passwordController,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Password',
                      hintStyle: TextStyle(color: Colors.grey.shade800),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide(color: Colors.green, width: 2),
                      ),
                      prefixIcon: Icon(Icons.key_rounded, color: Colors.grey),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 30),
          ElevatedButton(
            onPressed: _isloading ? null : registerUser,
            child: Text(
              _isloading ? 'Loading' : 'Register',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              minimumSize: Size(250, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          ),
          SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Already have an account?', style: TextStyle(color: Colors.white),),
              TextButton(onPressed: () {
               setState(() {
                 Navigator.pop(context, MaterialPageRoute(builder: (_) => LoginPage()));
               });
              },
               child: Text('Login', style: TextStyle(color: Colors.green),))
            ],
          ),
        ],
      ),
    );
  }
}
