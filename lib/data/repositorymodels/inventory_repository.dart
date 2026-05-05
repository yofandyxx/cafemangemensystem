import '../database/db_helper.dart';
import '../models/product_model.dart';
import '../models/category_model.dart';

class InventoryRepository {
  final dbHelper = DBHelper.instance;

  // ================= PRODUK =================

  /// Menambahkan produk baru ke database
  Future<int> insertProduct(Product product) async {
    final db = await dbHelper.database;
    return await db.insert('products', product.toMap());
  }

  /// Mengambil semua daftar produk
  Future<List<Product>> getProducts() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> result = await db.query('products');
    return result.map((e) => Product.fromMap(e)).toList();
  }

  /// Mengambil produk berdasarkan kategori untuk laporan produk.
  Future<List<Product>> getProductsByCategory(String category) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> result = await db.query(
      'products',
      where: 'category = ?',
      whereArgs: [category],
      orderBy: 'name ASC',
    );
    return result.map((e) => Product.fromMap(e)).toList();
  }

  /// Memperbarui data produk berdasarkan ID
  Future<int> updateProduct(Product product) async {
    final db = await dbHelper.database;
    return await db.update(
      'products',
      product.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  /// Menghapus produk dari database
  Future<int> deleteProduct(int id) async {
    final db = await dbHelper.database;
    return await db.delete('products', where: 'id = ?', whereArgs: [id]);
  }

  // ================= KATEGORI =================

  /// Mengambil daftar kategori diurutkan sesuai abjad[cite: 1]
  Future<List<Category>> getCategories() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> result = await db.query(
      'categories',
      orderBy: 'name ASC',
    );
    return result.map((e) => Category.fromMap(e)).toList();
  }

  /// Menambahkan kategori baru[cite: 1]
  Future<int> insertCategory(String name) async {
    final db = await dbHelper.database;
    return await db.insert('categories', {'name': name});
  }

  /// Menghapus kategori berdasarkan ID[cite: 1]
  Future<int> deleteCategory(int id) async {
    final db = await dbHelper.database;
    return await db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }

  // ================= TRANSAKSI =================

  /// Mencatat transaksi baru dan mengembalikan ID transaksi tersebut[cite: 1]
  Future<int> insertTransaction(int total) async {
    final db = await dbHelper.database;
    return await db.insert('transactions', {
      'total': total,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  /// Mencatat detail item yang dibeli dalam satu transaksi[cite: 1]
  Future<void> insertTransactionItem({
    required int transactionId,
    required int productId,
    required int qty,
    required int price,
  }) async {
    final db = await dbHelper.database;
    await db.insert('transaction_items', {
      'transaction_id': transactionId,
      'product_id': productId,
      'quantity': qty,
      'price': price,
    });
  }

  // ================= LAPORAN =================

  /// Mendapatkan total penjualan dalam rentang waktu tertentu[cite: 1]
  Future<int> getTotalSales(String start, String end) async {
    final db = await dbHelper.database;
    final result = await db.rawQuery(
      '''
      SELECT SUM(total) as total 
      FROM transactions 
      WHERE created_at BETWEEN ? AND ?
    ''',
      [start, end],
    );

    return (result.first['total'] as num?)?.toInt() ?? 0;
  }

  /// Mengambil daftar transaksi untuk laporan berdasarkan rentang tanggal.
  Future<List<Map<String, dynamic>>> getTransactionsByDate(
    String start,
    String end,
  ) async {
    final db = await dbHelper.database;
    return db.query(
      'transactions',
      where: 'created_at BETWEEN ? AND ?',
      whereArgs: [start, end],
      orderBy: 'created_at DESC',
    );
  }
}
