import '../../data/database/db_helper.dart';

class DashboardService {
  final dbHelper = DBHelper.instance;

  /// Menghitung total jumlah produk unik yang tersedia di inventaris
  Future<int> totalProducts() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> result = await db.rawQuery('SELECT COUNT(*) as total FROM products');
    return (result.first['total'] as int?) ?? 0;
  }

  /// Menghitung total akumulasi transaksi yang telah diproses
  Future<int> totalTransactions() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> result = await db.rawQuery(
      'SELECT COUNT(*) as total FROM transactions',
    );
    return (result.first['total'] as int?) ?? 0;
  }

  /// Menghitung total seluruh pendapatan (revenue) dari database
  Future<int> totalRevenue() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> result = await db.rawQuery(
      'SELECT SUM(total) as total FROM transactions',
    );
    // Menggunakan num? untuk menangani potensi nilai null jika belum ada transaksi
    return (result.first['total'] as num?)?.toInt() ?? 0;
  }

  /// Mengambil data produk dengan volume penjualan tertinggi[cite: 1]
  Future<Map<String, dynamic>?> bestProduct() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT p.name, SUM(ti.quantity) as qty
      FROM transaction_items ti
      JOIN products p ON ti.product_id = p.id
      GROUP BY p.name
      ORDER BY qty DESC
      LIMIT 1
    ''');
    
    return result.isNotEmpty ? result.first : null;
  }

  // ================= DATA UNTUK GRAFIK =================

  /// Mendapatkan ringkasan penjualan harian untuk visualisasi chart[cite: 1]
  Future<List<Map<String, dynamic>>> salesPerDay() async {
    final db = await dbHelper.database;
    // Menggunakan substr untuk mengambil bagian tanggal (YYYY-MM-DD) dari kolom created_at[cite: 1]
    return await db.rawQuery('''
      SELECT substr(created_at, 1, 10) as date, 
             SUM(total) as total
      FROM transactions
      GROUP BY substr(created_at, 1, 10)
      ORDER BY date ASC
    ''');
  }
}