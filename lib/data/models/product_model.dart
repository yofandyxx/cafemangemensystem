class Product {
  final int? id;
  final String name;
  final int price;
  final int stock;
  final String category;
  final String? image;

  Product({
    this.id,
    required this.name,
    required this.price,
    required this.stock,
    required this.category,
    this.image,
  });

  /// Mengonversi objek Product ke Map untuk operasi database SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'stock': stock,
      'category': category,
      'image': image,
    };
  }

  /// Membuat instance Product dari data Map yang diambil dari database
  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] as int?,
      name: map['name'] as String,
      price: map['price'] as int,
      stock: map['stock'] as int,
      category: map['category'] as String,
      image: map['image'] as String?,
    );
  }
}