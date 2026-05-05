import 'package:flutter/material.dart';
import 'package:cafemangemensystem/data/models/product_model.dart';

/// Model untuk membungkus produk di dalam keranjang belanja
class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});
}

class CartProvider extends ChangeNotifier {
  // Menggunakan List dengan tipe data eksplisit untuk keamanan
  final List<CartItem> _items = [];

  List<CartItem> get items => _items;

  /// Menambahkan produk ke keranjang atau menambah jumlah jika sudah ada
  void addToCart(Product product) {
    final index = _items.indexWhere((item) => item.product.id == product.id);

    if (index >= 0) {
      _items[index].quantity++;
    } else {
      _items.add(CartItem(product: product));
    }
    notifyListeners();
  }

  /// Menambah jumlah item tertentu di keranjang
  void increaseQty(CartItem item) {
    item.quantity++;
    notifyListeners();
  }

  /// Mengurangi jumlah item atau menghapusnya jika jumlah mencapai nol[cite: 1]
  void decreaseQty(CartItem item) {
    if (item.quantity > 1) {
      item.quantity--;
    } else {
      _items.remove(item);
    }
    notifyListeners();
  }

  /// Menghitung total harga seluruh item di keranjang[cite: 1]
  int get total {
    return _items.fold(
      0,
      (sum, item) => sum + (item.product.price * item.quantity),
    );
  }

  /// Menghapus semua item dari keranjang (setelah transaksi berhasil)[cite: 1]
  void clear() {
    _items.clear();
    notifyListeners();
  }
}
