import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("About CSM"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors
            .transparent, // Membuat AppBar lebih menyatu dengan background
        foregroundColor: Colors.black87,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ================= HEADER =================
            _buildHeader(),
            const SizedBox(height: 20),

            // ================= KONTEN =================
            _buildCard(
              title: "Deskripsi Sistem",
              content:
                  "CSM (Cafe Management System) adalah aplikasi manajemen kafe berbasis Flutter "
                  "yang digunakan untuk mengelola penjualan, produk, laporan, dan analitik secara digital.",
              icon: Icons.description,
            ),
            _buildCard(
              title: "Fitur Utama",
              content:
                  "• Kasir POS (Transaksi cepat)\n"
                  "• Manajemen Produk & Kategori\n"
                  "• Laporan Penjualan + PDF\n"
                  "• Dashboard Analytics\n"
                  "• Smart Insight bisnis",
              icon: Icons.star,
            ),
            _buildCard(
              title: "Cara Kerja Sistem",
              content:
                  "1. Admin menambahkan produk\n"
                  "2. Kasir melakukan transaksi di menu POS\n"
                  "3. Sistem otomatis menyimpan transaksi\n"
                  "4. Data ditampilkan di laporan & dashboard\n"
                  "5. User bisa export PDF & analisis penjualan",
              icon: Icons.settings,
            ),
            _buildCard(
              title: "Teknologi",
              content:
                  "Flutter • SQLite • Provider State Management • FL Chart • PDF Generator",
              icon: Icons.code,
            ),
          ],
        ),
      ),
    );
  }

  /// Widget Header dengan efek Gradient
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Colors.teal,
            Colors.indigo,
          ], // Menggunakan Teal agar senada dengan theme aplikasi
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: const [
          Icon(Icons.coffee_rounded, size: 60, color: Colors.white),
          SizedBox(height: 12),
          Text(
            "CSM - Cafe Management System",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "Smart POS & Inventory System",
            style: TextStyle(color: Colors.white70, letterSpacing: 1.1),
          ),
        ],
      ),
    );
  }

  /// Widget Card Reusable untuk bagian informasi
  Widget _buildCard({
    required String title,
    required String content,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.teal.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: Colors.teal, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1),
          ),
          Text(
            content,
            style: TextStyle(
              height: 1.6,
              color: Colors.grey[800],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
