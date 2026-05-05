import 'package:flutter/material.dart';
import 'dashboard_screen.dart'; // Ganti dengan path dashboard kamu

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Berpindah ke Dashboard setelah 3 detik
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Sesuaikan dengan tema hitam-ungu kamu
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Tampilkan Logo Cafe kamu
            Image.asset(
              'assets/logo/logo_cafe.jpg', 
              width: 200,
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(
              color: Colors.purple, // Warna ungu sesuai tema
            ),
          ],
        ),
      ),
    );
  }
}