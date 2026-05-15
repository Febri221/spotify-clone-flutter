import 'package:flutter/material.dart';
import 'package:percobaan/providers/auth_google_provider.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:percobaan/screens/auth/login_screen.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _CreatePageState();
}

class _CreatePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthGoogleProvider>();
    final userData = authProvider.user;

    String namaTampil = 'Username Default'; // Siapkan nama cadangan
    if (userData != null) {
      if (userData.displayName != null && userData.displayName!.isNotEmpty) {
        namaTampil = userData.displayName!;
      } else if (userData.providerData.isNotEmpty &&
          userData.providerData[0].displayName != null) {
        // 2. Kalau utama kosong, bongkar data bawaan Google-nya (providerData)
        namaTampil = userData.providerData[0].displayName!;
      } else if (userData.email != null) {
        // 3. Kalau dua-duanya kosong juga, baru deh potong emailnya
        namaTampil = userData.email!.split('@')[0];
      }
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Center(
              child: Text(
                'Profile Page',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            CircleAvatar(
              radius: 50,
              backgroundImage: (userData != null && userData.photoURL != null)
                  ? NetworkImage(userData.photoURL!)
                  : null,
              child: (userData == null || userData.photoURL == null)
                  ? Icon(Icons.person, size: 50)
                  : null,
            ),
            const SizedBox(height: 16),
            Text(
              namaTampil,
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            SizedBox(height: 8),

            Center(
              child: ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Konfirmasi Logout'),
                      content: Text('Yakin mau Logout?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('Tidak', style: TextStyle(color: Colors.white)),
                        ),
                        TextButton(
                          onPressed: () async {
                            Navigator.pop(context);
                            await FirebaseAuth.instance.signOut();
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (_) => LoginPage()),
                              (route) => false,
                            );
                          },
                          child: Text('Ya', style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );
                },
                child: Text('Logout'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
