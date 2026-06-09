import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:percobaan/auth_wrapper.dart';
import 'package:percobaan/features/auth/viewmodel/auth_viewmodel.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  String _resolveDisplayName(dynamic userData) {
    if (userData == null) return 'Username Default';
    if (userData.displayName?.isNotEmpty == true) return userData.displayName!;
    if (userData.providerData.isNotEmpty &&
        userData.providerData[0].displayName != null) {
      return userData.providerData[0].displayName!;
    }
    if (userData.email != null) return userData.email!.split('@')[0];
    return 'Username Default';
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();
    final userData = authViewModel.user;
    final namaTampil = _resolveDisplayName(userData);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const Center(
              child: Text(
                'Profile Page',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            CircleAvatar(
              radius: 50,
              backgroundImage: userData?.photoURL != null
                  ? NetworkImage(userData!.photoURL!)
                  : null,
              child: userData?.photoURL == null
                  ? const Icon(Icons.person, size: 50)
                  : null,
            ),
            const SizedBox(height: 16),
            Text(
              namaTampil,
              style: const TextStyle(color: Colors.white, fontSize: 20),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => _showLogoutDialog(context, authViewModel),
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AuthViewModel authViewModel) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Konfirmasi Logout'),
        content: const Text('Yakin mau Logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tidak', style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await authViewModel.signOut();

              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const AuthWrapper()),
                  (route) => false,
                );
              }
            },
            child: const Text('Ya', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}