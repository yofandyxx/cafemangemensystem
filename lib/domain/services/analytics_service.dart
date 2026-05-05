import '../../data/database/db_helper.dart';

class AnalyticsService {
  final dbHelper = DBHelper.instance;

  // ================= PRODUK PER KATEGORI =================

  /// Mendapatkan jumlah produk berdasarkan kategorinya
  Future<Map<String, int>> getProductByCategory() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT category, COUNT(*) as total 
      FROM products 
      GROUP BY category
    ''');

    return {
      for (var row in result)
        row['category']?.toString() ?? 'Unknown': (row['total'] as num?)?.toInt() ?? 0
    };
  }

  // ================= PENJUALAN PER KATEGORI =================

  /// Mendapatkan total pendapatan (revenue) per kategori produk
  Future<Map<String, int>> getSalesByCategory() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT p.category, SUM(ti.quantity * ti.price) as total 
      FROM transaction_items ti 
      JOIN products p ON ti.product_id = p.id 
      GROUP BY p.category
    ''');

    return {
      for (var row in result)
        row['category']?.toString() ?? 'Unknown': (row['total'] as num?)?.toInt() ?? 0
    };
  }

  // ================= TOP CATEGORY =================

  /// Mendapatkan nama kategori dengan angka penjualan tertinggi
  Future<String> getTopCategory() async {
    final data = await getSalesByCategory();
    if (data.isEmpty) return "-";

    final top = data.entries.reduce(
      (a, b) => a.value > b.value ? a : b,
    );
    return top.key;
  }

  // ================= SUMMARY INSIGHT =================

  /// Memberikan pesan rekomendasi berdasarkan data penjualan
  Future<String> getInsight() async {
    final sales = await getSalesByCategory();
    
    if (sales.isEmpty) {
      return "Belum ada data penjualan tersedia.";
    }

    final top = sales.entries.reduce(
      (a, b) => a.value > b.value ? a : b,
    );

    return "🔥 Kategori terlaris: '${top.key}' (dominasi pendapatan tertinggi).";
  }
}