import 'package:flutter/gestures.dart'; // masih dipake buat Terms & Privacy
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:percobaan/auth_wrapper.dart';
import 'package:percobaan/features/auth/viewmodel/auth_viewmodel.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool _isLoading = false;

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);

    try {
      await context.read<AuthViewModel>().signInWithGoogle();

      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const AuthWrapper()),
          (route) => false,
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login gagal: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 100),
              SvgPicture.asset(
                'images/undraw_sign-up_qamz.svg',
                width: 232,
                height: 238,
              ),
              const SizedBox(height: 20.74),

              // Header
              Padding(
                padding: const EdgeInsets.only(left: 20.55),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Masuk atau Daftar',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 24,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Kalau udah punya akun, langsung masuk.\nBelum punya? Otomatis dibuatkan.',
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 12,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    SizedBox(height: 22.63),
                  ],
                ),
              ),

              // Google Sign In Button
              ElevatedButton(
                onPressed: _isLoading ? null : _signInWithGoogle,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  minimumSize: const Size(345, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                    side: const BorderSide(color: Colors.grey),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Continue with Google',
                        style: TextStyle(color: Colors.white, fontSize: 19),
                      ),
              ),

              const SizedBox(height: 18.35),

              // Terms & Privacy
              Padding(
                padding: const EdgeInsets.only(left: 17.55),
                child: RichText(
                  text: TextSpan(
                    text: 'By signing up, you\'ve agreed to our',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 11.55,
                      fontFamily: 'Poppins',
                    ),
                    children: [
                      TextSpan(
                        text: ' Terms and Conditions',
                        style: const TextStyle(
                          color: Color(0xff0D3995),
                          fontSize: 11.55,
                          fontFamily: 'Poppins',
                        ),
                        recognizer: TapGestureRecognizer()..onTap = () {},
                      ),
                      const TextSpan(
                        text: ' and',
                        style: TextStyle(color: Colors.black, fontSize: 11.55),
                      ),
                      TextSpan(
                        text: ' Privacy Policy',
                        style: const TextStyle(
                          color: Color(0xff0D3995),
                          fontSize: 11.55,
                          fontFamily: 'Poppins',
                        ),
                        recognizer: TapGestureRecognizer()..onTap = () {},
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}