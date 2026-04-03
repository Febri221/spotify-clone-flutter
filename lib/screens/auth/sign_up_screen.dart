import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:percobaan/widgets/bottom_navbar.dart';
import 'package:percobaan/screens/auth/login_screen.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter/gestures.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<SignUpScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isloading = false;
  bool _isObscure = true;

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
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: <Widget>[
            SafeArea(
              child: Column(
                children: <Widget>[
                  SizedBox(height: 100),

                  SvgPicture.asset(
                    'images/undraw_sign-up_qamz.svg',
                    width: 232,
                    height: 238,
                  ),
                  SizedBox(height: 20.74),
                  Container(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 20.55),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Sign Up',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 24,
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 23.11),
                              RichText(
                                text: TextSpan(
                                  text: 'Sudah punya akun? ',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 11.55,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w400,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: 'Login',
                                      style: TextStyle(
                                        color: Color(0xff0D3995),
                                        fontSize: 11.55,
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.w400,
                                      ),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => LoginPage(),
                                            ),
                                          );
                                        },
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 22.63),
                            ],
                          ),
                        ),
                        Container(
                          child: SizedBox(
                            width: 343.64,
                            child: TextField(
                              controller: _emailController,
                              style: TextStyle(color: Colors.black),
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                hintText: 'Email',
                                hintStyle: TextStyle(
                                  color: Colors.grey.shade800,
                                ),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                                icon: Icon(
                                  Icons.email_outlined,
                                  color: Color(0xff000000),
                                  size: 24,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 12.95),
                        Container(
                          width: 343.64,
                          child: TextField(
                            style: TextStyle(color: Colors.black),
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 16,
                              ),
                              hintText: 'Username',
                              hintStyle: TextStyle(color: Colors.grey.shade800),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey),
                              ),
                              icon: Icon(
                                Icons.person_outlined,
                                color: Color(0xff000000),
                                size: 24,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 12.95),
                        Container(
                          width: 343.64,
                          child: TextField(
                            obscureText: _isObscure,
                            controller: _passwordController,
                            style: TextStyle(color: Colors.black),
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 16,
                              ),
                              hintText: 'Password',
                              suffixIcon: IconButton(onPressed: () {
                                setState(() {
                                  _isObscure = !_isObscure;
                                });
                              }, icon: Icon(_isObscure ? Icons.visibility_off : Icons.visibility),color: Colors.black,
                              ),
                              hintStyle: TextStyle(color: Colors.grey.shade800),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey),
                              ),
                              icon: Icon(
                                Icons.lock_outlined,
                                color: Color(0xff000000),
                                size: 24,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 18.35),

                        Container(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 17.55),
                            child: RichText(
                              text: TextSpan(
                                text: 'By signing up, you’ve agree to our',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 11.55,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w400,
                                ),
                                children: [
                                  TextSpan(
                                    text: ' Terms and Conditions',
                                    style: TextStyle(
                                      color: Color(0xff0D3995),
                                      fontSize: 11.55,
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w400,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {},
                                  ),
                                  TextSpan(
                                    text: ' and',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 11.55,
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  TextSpan(
                                    text: ' Privacy Policy',
                                    style: TextStyle(
                                      color: Color(0xff0D3995),
                                      fontSize: 11.55,
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w400,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {},
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 24.02),
                      ],
                    ),
                  ),

                  ElevatedButton(
                    onPressed: _isloading ? null : registerUser,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black87,
                      minimumSize: Size(345, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    child: Text(
                      'Sign Up',
                      style: TextStyle(color: Colors.white, fontSize: 19),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
