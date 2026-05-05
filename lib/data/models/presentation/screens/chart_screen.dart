import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../providers/inventory_provider.dart';

class ChartScreen extends StatefulWidget {
  const ChartScreen({super.key});

  @override
  State<ChartScreen> createState() => _ChartScreenState();
}

class _ChartScreenState extends State<ChartScreen> {
  // Palet warna yang konsisten dengan tema aplikasi
  final List<Color> sectionColors = [
    Colors.teal,
    Colors.indigo,
    Colors.orange,
    Colors.pinkAccent,
    Colors.amber,
  ];

  @override
  void initState() {
    super.initState();
    // Memuat data produk saat layar pertama kali dibuka
    context.read<InventoryProvider>().loadProducts();
  }

  /// Menghitung distribusi kategori dari list produk yang ada di provider
  Map<String, int> _getCategoryData(InventoryProvider provider) {
    final Map<String, int> data = {};
    for (var p in provider.products) {
      data[p.category] = (data[p.category] ?? 0) + 1;
    }
    return data;
  }

  /// Membangun seksi PieChart berdasarkan data kategori
  List<PieChartSectionData> _buildSections(Map<String, int> categoryCount) {
    int i = 0;
    return categoryCount.entries.map((entry) {
      final color = sectionColors[i % sectionColors.length];
      i++;
      return PieChartSectionData(
        color: color,
        value: entry.value.toDouble(),
        title: "${entry.value}",
        radius: 55,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Inventory Analytics"),
        centerTitle: true,
        elevation: 0,
      ),
      body: Consumer<InventoryProvider>(
        builder: (context, provider, child) {
          // Menampilkan loading jika data sedang dimuat
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final categoryCount = _getCategoryData(provider);

          if (categoryCount.isEmpty) {
            return const Center(child: Text("Belum ada data produk tersedia"));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildChartCard(categoryCount),
                const SizedBox(height: 24),
                _buildLegendCard(categoryCount),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildChartCard(Map<String, int> categoryCount) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            "Sebaran Produk per Kategori",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 30),
          SizedBox(
            height: 220,
            child: PieChart(
              PieChartData(
                sections: _buildSections(categoryCount),
                sectionsSpace: 3,
                centerSpaceRadius: 45,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendCard(Map<String, int> categoryCount) {
    int i = 0;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: categoryCount.entries.map((e) {
          final color = sectionColors[i % sectionColors.length];
          i++;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  e.key,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                const Spacer(),
                Text(
                  "${e.value} Item",
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
