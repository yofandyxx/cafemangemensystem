class Category {
  final int? id;
  final String name;

  Category({
    this.id, 
    required this.name,
  });

  /// Mengonversi objek Category ke Map untuk disimpan di database[cite: 1]
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }

  /// Membuat instance Category dari data Map (hasil query database)[cite: 1]
  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] as int?,
      name: map['name'] as String,
    );
  }
}