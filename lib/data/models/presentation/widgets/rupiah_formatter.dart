import 'package:intl/intl.dart';

class RupiahFormatter {
  /// Mengubah angka int menjadi format mata uang Rupiah (contoh: Rp 50.000)
  static String format(num number) {
    try {
      return NumberFormat.currency(
        locale: 'id_ID',
        symbol: 'Rp ',
        decimalDigits: 0,
      ).format(number);
    } catch (e) {
      // Jika terjadi error, kembalikan teks Rp 0 sebagai fallback
      return "Rp 0";
    }
  }

  /// Versi tanpa simbol "Rp" (hanya angka dengan pemisah ribuan)
  static String formatPlain(num number) {
    try {
      return NumberFormat.decimalPattern('id_ID').format(number);
    } catch (e) {
      return "0";
    }
  }
}