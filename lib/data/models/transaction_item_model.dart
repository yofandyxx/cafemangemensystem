class TransactionItem {
  final int? id;
  final int transactionId;
  final int productId;
  final int quantity;
  final int price;

  TransactionItem({
    this.id,
    required this.transactionId,
    required this.productId,
    required this.quantity,
    required this.price,
  });

  /// Mengonversi objek TransactionItem ke Map untuk disimpan di tabel transaction_items
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'transaction_id': transactionId,
      'product_id': productId,
      'quantity': quantity,
      'price': price,
    };
  }

  /// Membuat instance TransactionItem dari data Map hasil query database
  factory TransactionItem.fromMap(Map<String, dynamic> map) {
    return TransactionItem(
      id: map['id'] as int?,
      transactionId: map['transaction_id'] as int,
      productId: map['product_id'] as int,
      quantity: map['quantity'] as int,
      price: map['price'] as int,
    );
  }
}