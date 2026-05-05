import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:cafemangemensystem/domain/services/analytics_service.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  final service = AnalyticsService();
  Map<String, int> productByCategory = {};
  Map<String, int> salesByCategory = {};
  bool isLoading = true;

  // Daftar warna untuk grafik agar terlihat bervariasi
  final List<Color> chartColors = [
    Colors.teal,
    Colors.indigo,
    Colors.orange,
    Colors.pinkAccent,
    Colors.amber,
    Colors.cyan,
  ];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    // Mengambil data dari AnalyticsService yang sudah kita rapikan sebelumnya
    productByCategory = await service.getProductByCategory();
    salesByCategory = await service.getSalesByCategory();

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  // ================= PEMBUAT SEKSI GRAFIK =================

  List<PieChartSectionData> _buildChartSections(Map<String, int> data) {
    int index = 0;
    return data.entries.map((e) {
      final color = chartColors[index % chartColors.length];
      index++;
      return PieChartSectionData(
        value: e.value.toDouble(),
        title: "${e.value}", // Menampilkan angka saja di dalam grafik agar rapi
        radius: 55,
        color: color,
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
        title: const Text("Business Analytics"),
        centerTitle: true,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ================= INSIGHT CARD =================
                  _buildInsightCard(),
                  const SizedBox(height: 24),

                  // ================= PRODUK CHART =================
                  _buildChartCard(
                    title: "Distribusi Produk",
                    subtitle: "Jumlah produk berdasarkan kategori",
                    data: productByCategory,
                  ),
                  const SizedBox(height: 20),

                  // ================= SALES CHART =================
                  _buildChartCard(
                    title: "Performa Penjualan",
                    subtitle: "Total pendapatan per kategori",
                    data: salesByCategory,
                    isCurrency: true,
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildInsightCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.indigo.shade400, Colors.indigo.shade700],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.auto_awesome, color: Colors.amber, size: 20),
              SizedBox(width: 8),
              Text(
                "Smart Insight",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          FutureBuilder<String>(
            future: service.getInsight(),
            builder: (context, snapshot) {
              return Text(
                snapshot.data ?? "Menganalisis data...",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  height: 1.4,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildChartCard({
    required String title,
    required String subtitle,
    required Map<String, int> data,
    bool isCurrency = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            subtitle,
            style: TextStyle(color: Colors.grey[600], fontSize: 13),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: data.isEmpty
                ? const Center(child: Text("Data tidak tersedia"))
                : PieChart(
                    PieChartData(
                      sections: _buildChartSections(data),
                      centerSpaceRadius: 45,
                      sectionsSpace: 2,
                    ),
                  ),
          ),
          const SizedBox(height: 20),
          // Legenda
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: data.keys.toList().asMap().entries.map((entry) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: chartColors[entry.key % chartColors.length],
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(entry.value, style: const TextStyle(fontSize: 12)),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
