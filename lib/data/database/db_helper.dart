import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  // Singleton Pattern
  static final DBHelper instance = DBHelper._init();
  static Database? _database;

  DBHelper._init();

  /// Mengambil instance database, inisialisasi jika belum ada
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('cafe.db');
    return _database!;
  }

  /// Inisialisasi koneksi database
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2, // Versi database untuk skema saat ini[cite: 1]
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  /// Menjalankan perintah pembuatan tabel saat pertama kali aplikasi dijalankan[cite: 1]
  Future<void> _createDB(Database db, int version) async {
    // Tabel Produk
    await db.execute('''
      CREATE TABLE products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        price INTEGER NOT NULL,
        stock INTEGER NOT NULL,
        category TEXT,
        image TEXT
      )
    ''');

    // Tabel Transaksi Utama[cite: 1]
    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        total INTEGER NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    // Tabel Detail Item per Transaksi[cite: 1]
    await db.execute('''
      CREATE TABLE transaction_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        transaction_id INTEGER NOT NULL,
        product_id INTEGER NOT NULL,
        quantity INTEGER NOT NULL,
        price INTEGER NOT NULL,
        FOREIGN KEY (transaction_id) REFERENCES transactions (id) ON DELETE CASCADE
      )
    ''');

    // Tabel Kategori Produk[cite: 1]
    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL
      )
    ''');
  }

  /// Mengelola migrasi database ketika versi aplikasi ditingkatkan[cite: 1]
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Menambahkan kolom created_at jika migrasi dari versi 1 ke 2[cite: 1]
      await db.execute("ALTER TABLE transactions ADD COLUMN created_at TEXT");
    }
  }
}