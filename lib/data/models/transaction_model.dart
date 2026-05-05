class TransactionModel {
  final int? id;
  final String date;
  final int total;

  TransactionModel({
    this.id,
    required this.date,
    required this.total,
  });

  /// Mengonversi objek TransactionModel ke Map untuk disimpan di tabel transactions
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'created_at': date, // Nama field disesuaikan dengan kolom di DBHelper
      'total': total,
    };
  }

  /// Membuat instance TransactionModel dari data Map hasil query database
  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] as int?,
      date: map['created_at'] as String, // Nama field disesuaikan dengan kolom di DBHelper[cite: 1]
      total: map['total'] as int,
    );
  }
}