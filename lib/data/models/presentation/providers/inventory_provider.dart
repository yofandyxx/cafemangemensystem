import 'package:flutter/material.dart';
import 'package:cafemangemensystem/data/models/category_model.dart';
import 'package:cafemangemensystem/data/models/product_model.dart';
import 'package:cafemangemensystem/data/repositorymodels/inventory_repository.dart';

class InventoryProvider extends ChangeNotifier {
  final repo = InventoryRepository();

  // ================= STATE PRODUK =================
  List<Product> _products = [];
  bool _isLoading = false;

  List<Product> get products => _products;
  bool get isLoading => _isLoading;

  /// Memuat semua data produk dari database
  Future<void> loadProducts() async {
    _isLoading = true;
    notifyListeners();

    _products = await repo.getProducts();

    _isLoading = false;
    notifyListeners();
  }

  /// Menambahkan produk baru dan memperbarui tampilan
  Future<void> addProduct(Product product) async {
    await repo.insertProduct(product);
    await loadProducts();
  }

  /// Memperbarui data produk yang sudah ada
  Future<void> updateProduct(Product product) async {
    await repo.updateProduct(product);
    await loadProducts();
  }

  /// Menghapus produk berdasarkan ID
  Future<void> deleteProduct(int id) async {
    await repo.deleteProduct(id);
    await loadProducts();
  }

  // ================= PRODUK BERDASARKAN KATEGORI =================
  List<Product> _categoryProducts = [];
  bool _isCategoryLoading = false;

  List<Product> get categoryProducts => _categoryProducts;
  bool get isCategoryLoading => _isCategoryLoading;

  /// Memuat produk spesifik berdasarkan kategori tertentu[cite: 1]
  Future<void> loadProductsByCategory(String category) async {
    _isCategoryLoading = true;
    notifyListeners();

    // Pastikan metode ini sudah ada di InventoryRepository Anda[cite: 1]
    _categoryProducts = await repo.getProductsByCategory(category);

    _isCategoryLoading = false;
    notifyListeners();
  }

  // ================= STATE KATEGORI =================
  List<Category> _categories = [];
  bool _isLoadingCategories = false;

  List<Category> get categories => _categories;
  bool get isLoadingCategories => _isLoadingCategories;

  /// Memuat daftar semua kategori[cite: 1]
  Future<void> loadCategories() async {
    _isLoadingCategories = true;
    notifyListeners();

    _categories = await repo.getCategories();

    _isLoadingCategories = false;
    notifyListeners();
  }

  /// Menambahkan kategori baru[cite: 1]
  Future<void> addCategory(String name) async {
    await repo.insertCategory(name);
    await loadCategories();
  }

  /// Menghapus kategori berdasarkan ID[cite: 1]
  Future<void> deleteCategory(int id) async {
    await repo.deleteCategory(id);
    await loadCategories();
  }
}
