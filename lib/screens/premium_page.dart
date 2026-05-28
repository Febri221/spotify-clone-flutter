import 'package:flutter/material.dart';
import 'package:percobaan/services/youtube_service.dart';

class PremiumPage extends StatefulWidget {
  const PremiumPage({super.key});

  @override
  State<PremiumPage> createState() => _PremiumPageState();
}

class _PremiumPageState extends State<PremiumPage> {

  final YoutubeService _ytService = YoutubeService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        
      ),
    );
  }
}
