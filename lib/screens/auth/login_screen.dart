import 'package:flutter/material.dart';
import 'package:percobaan/screens/auth/sign_up_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:percobaan/widgets/bottom_navbar.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_svg/svg.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isobscure = true;

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

      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => BottomNavbar()));

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
                    'images/undraw_login_weas.svg',
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
                                    'Login',
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
                                  text: 'Belum punya akun? ',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 11.55,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w400,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: 'Daftar',
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
                                              builder: (_) => SignUpScreen(),
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
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey.shade800),
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
                            obscureText: _isobscure,
                            controller: _passwordController,
                            style: TextStyle(color: Colors.black),
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 16,
                              ),
                              hintText: 'Password',
                              suffixIcon: IconButton(onPressed: () {
                                setState(() {
                                  _isobscure = !_isobscure;
                                });
                              }, icon: Icon(_isobscure ? Icons.visibility_off : Icons.visibility),color: Colors.black,
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
                        SizedBox(height: 144.72),
                      ],
                    ),
                  ),

                  ElevatedButton(
                    onPressed: loginUser,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black87,
                      minimumSize: Size(345, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    child: Text(
                      'Login',
                      style: TextStyle(color: Colors.white, fontSize: 19),
                    ),
                  ),
                  SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account?',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
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
