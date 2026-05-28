import 'package:flutter/material.dart';
// Jangan lupa import halaman SearchPage lu yang tadi
import 'search_page.dart'; 

class TriggerSearch extends StatelessWidget {
  const TriggerSearch({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF191414), // Tema gelap Meraki
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Cari',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              
              // 🔥 INI DIA FAKE SEARCH BAR-NYA 🔥
              GestureDetector(
                onTap: () {
                  // Pas dipencet, langsung lempar ke kodingan SearchPage lu!
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SearchPage(),
                    ),
                  );
                },
                child: Container(
                  height: 50,
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  decoration: BoxDecoration(
                    color: Colors.white, // Dibikin putih biar ngejreng kayak Spotify
                    borderRadius: BorderRadius.circular(5), // Kotak ujung tumpul
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.search, color: Colors.black87, size: 28),
                      SizedBox(width: 10),
                      Text(
                        'Apa yang ingin kamu dengarkan?',
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}