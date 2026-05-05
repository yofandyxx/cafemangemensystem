import 'package:flutter/material.dart';
import 'package:cafemangemensystem/domain/services/dashboard_service.dart';
import '../widgets/dashboard_card.dart';
import '../widgets/rupiah_formatter.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final service = DashboardService();

  // Variabel State
  int totalProducts = 0;
  int totalTransactions = 0;
  int totalRevenue = 0;
  String bestProduct = "-";
  List<Map<String, dynamic>> sales = [];
  bool isLoading = true;
  String insightText = "";

  @override
  void initState() {
    super.initState();
    loadData();
  }

  /// Memuat semua data statistik dari DashboardService
  Future<void> loadData() async {
    final results = await Future.wait([
      service.totalProducts(),
      service.totalTransactions(),
      service.totalRevenue(),
      service.bestProduct(),
      service.salesPerDay(),
    ]);

    totalProducts = results[0] as int;
    totalTransactions = results[1] as int;
    totalRevenue = results[2] as int;

    final best = results[3] as Map<String, dynamic>?;
    if (best != null) {
      bestProduct = best['name'];
    }

    sales = results[4] as List<Map<String, dynamic>>;

    _generateInsight();

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  /// Menghasilkan analisis cerdas berdasarkan data penjualan terbaru
  void _generateInsight() {
    if (sales.isEmpty) {
      insightText = "Belum ada data transaksi untuk dianalisis hari ini.";
      return;
    }

    final totalValue = sales.fold(
      0,
      (sum, item) => sum + ((item['total'] as num?) ?? 0).toInt(),
    );
    final avg = totalValue / sales.length;

    String trend = "➖ Tren penjualan stabil.";
    if (sales.length >= 2) {
      final last = (sales.last['total'] as num?) ?? 0;
      final prev = (sales[sales.length - 2]['total'] as num?) ?? 0;
      if (last > prev) trend = "📈 Tren penjualan sedang MENINGKAT.";
      if (last < prev) trend = "📉 Tren penjualan MENURUN.";
    }

    insightText =
        """
📊 PENJUALAN HARIAN
Rata-rata: ${RupiahFormatter.format(avg.toInt())}
Produk Unggulan: $bestProduct

$trend

💡 REKOMENDASI STRATEGIS:
• Prioritaskan stok untuk $bestProduct.
• Tingkatkan promosi pada jam-jam ramai.
• Evaluasi performa item dengan margin rendah.
""";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Business Dashboard"),
        centerTitle: true,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: loadData,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // ================= GRID STATISTIK =================
                  _buildStatGrid(),
                  const SizedBox(height: 24),

                  // ================= SMART INSIGHT CARD =================
                  _buildInsightCard(),
                ],
              ),
            ),
    );
  }

  Widget _buildStatGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.4,
      children: [
        DashboardCard(
          title: "Total Produk",
          value: totalProducts.toString(),
          icon: Icons.inventory_2_rounded,
          color: Colors.teal,
        ),
        DashboardCard(
          title: "Transaksi",
          value: totalTransactions.toString(),
          icon: Icons.shopping_bag_rounded,
          color: Colors.indigo,
        ),
        DashboardCard(
          title: "Pendapatan",
          value: RupiahFormatter.format(totalRevenue),
          icon: Icons.account_balance_wallet_rounded,
          color: Colors.orange,
        ),
        DashboardCard(
          title: "Terlaris",
          value: bestProduct,
          icon: Icons.auto_graph_rounded,
          color: Colors.pinkAccent,
        ),
      ],
    );
  }

  Widget _buildInsightCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.indigo.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.tips_and_updates_rounded, color: Colors.amber[700]),
              const SizedBox(width: 10),
              const Text(
                "SMART INSIGHT",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const Divider(height: 30),
          Text(
            insightText,
            style: TextStyle(
              height: 1.6,
              fontSize: 14,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }
}
