import 'package:flutter/material.dart';
import 'pos_screen.dart';
import 'product_list_screen.dart';
import 'chart_screen.dart';
import 'report_screen.dart';
import 'dashboard_screen.dart';
import 'product_report_screen.dart';
import 'analytics_screen.dart';
import 'about_screen.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Menentukan jumlah kolom berdasarkan lebar layar
    final double screenWidth = MediaQuery.of(context).size.width;
    final int crossAxisCount = screenWidth > 900
        ? 4
        : (screenWidth > 600 ? 3 : 2);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "CSM - Cafe Management",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeHeader(),
            const SizedBox(height: 24),
            const Text(
              "Menu Utama",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio:
                  0.9, // Membuat kartu sedikit lebih tinggi dari lebarnya
              children: [
                _buildMenuCard(
                  context,
                  title: "Kasir (POS)",
                  icon: Icons.point_of_sale_rounded,
                  color: Colors.green,
                  screen: const POSScreen(),
                ),
                _buildMenuCard(
                  context,
                  title: "Produk",
                  icon: Icons.inventory_2_rounded,
                  color: Colors.blue,
                  screen: const ProductListScreen(),
                ),
                _buildMenuCard(
                  context,
                  title: "Grafik Stok",
                  icon: Icons.pie_chart_rounded,
                  color: Colors.orange,
                  screen: const ChartScreen(),
                ),
                _buildMenuCard(
                  context,
                  title: "Dashboard",
                  icon: Icons.dashboard_rounded,
                  color: Colors.purple,
                  screen: const DashboardScreen(),
                ),
                _buildMenuCard(
                  context,
                  title: "Laporan",
                  icon: Icons.receipt_long_rounded,
                  color: Colors.red,
                  screen: const ReportScreen(),
                ),
                _buildMenuCard(
                  context,
                  title: "Kategori",
                  icon: Icons.category_rounded,
                  color: Colors.teal,
                  screen: const ProductReportScreen(),
                ),
                _buildMenuCard(
                  context,
                  title: "Analitik",
                  icon: Icons.analytics_rounded,
                  color: Colors.indigo,
                  screen: const AnalyticsScreen(),
                ),
                _buildMenuCard(
                  context,
                  title: "Tentang",
                  icon: Icons.info_outline_rounded,
                  color: Colors.blueGrey,
                  screen: const AboutScreen(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Widget Header untuk memberikan kesan personal di menu utama
  Widget _buildWelcomeHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: Colors.teal.shade100,
            child: const Icon(Icons.person, color: Colors.teal),
          ),
          const SizedBox(width: 16),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Selamat Datang,",
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              Text(
                "Administrator",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Widget Kartu Menu yang interaktif
  Widget _buildMenuCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required Widget screen,
  }) {
    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.1)),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 32, color: color),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
