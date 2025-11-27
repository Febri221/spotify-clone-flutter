import 'dart:async';
import 'package:flutter/material.dart';
import 'package:percobaan/main.dart'; 


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override

  void initState()  {
    super.initState();

    Timer(Duration(seconds: 2), () {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => AuthWrapper()));
    });
  }
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget> [
            Icon(Icons.music_note, color: Colors.green, size: 80),
            Text('My Music App', style: TextStyle(color: Colors.white, fontSize: 22),),
          ],
        ),
      ),
    );
  }
}