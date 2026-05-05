import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfService {
  /// Fungsi utama untuk menghasilkan dan mencetak PDF laporan penjualan
  static Future<void> generate({
    required List<Map<String, dynamic>> data,
    required int total,
    String? startDate,
    String? endDate,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          _buildHeader(startDate, endDate),
          pw.SizedBox(height: 20),
          _buildSummary(total),
          pw.SizedBox(height: 20),
          _buildTable(data),
          pw.SizedBox(height: 30),
          _buildFooter(),
        ],
      ),
    );

    // Menampilkan pratinjau cetak ke pengguna
    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
      name: 'Laporan_Penjualan_${startDate ?? "Terbaru"}.pdf',
    );
  }

  /// Bagian Header Laporan
  static pw.Widget _buildHeader(String? start, String? end) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          "LAPORAN PENJUALAN CAFE CSM",
          style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
        ),
        pw.Divider(thickness: 2),
        if (start != null && end != null)
          pw.Text(
            "Periode Laporan: $start s/d $end",
            style: const pw.TextStyle(fontSize: 12),
          ),
        pw.Text(
          "Dicetak pada: ${DateTime.now().toString().split('.')[0]}",
          style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
        ),
      ],
    );
  }

  /// Bagian Ringkasan Pendapatan
  static pw.Widget _buildSummary(int total) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: const pw.BoxDecoration(
        color: PdfColors.grey200,
        borderRadius: pw.BorderRadius.all(pw.Radius.circular(5)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            "TOTAL PENDAPATAN",
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          pw.Text(
            "Rp ${_formatNumber(total)}",
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.teal,
            ),
          ),
        ],
      ),
    );
  }

  /// Tabel Data Transaksi
  static pw.Widget _buildTable(List<Map<String, dynamic>> data) {
    return pw.TableHelper.fromTextArray(
      border: pw.TableBorder.all(color: PdfColors.grey300),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.teal),
      headerHeight: 30,
      cellHeight: 25,
      headerStyle: pw.TextStyle(
        color: PdfColors.white,
        fontWeight: pw.FontWeight.bold,
      ),
      headers: ["Tanggal Transaksi", "Total Nominal"],
      data: data.map((e) {
        return [
          _formatDate(e['created_at'] ?? e['date'] ?? '-'),
          "Rp ${_formatNumber(e['total'] ?? 0)}",
        ];
      }).toList(),
      cellAlignments: {0: pw.Alignment.centerLeft, 1: pw.Alignment.centerRight},
    );
  }

  /// Footer untuk tanda tangan penanggung jawab
  static pw.Widget _buildFooter() {
    return pw.Align(
      alignment: pw.Alignment.centerRight,
      child: pw.Column(
        children: [
          pw.Text("Penanggung Jawab,"),
          pw.SizedBox(height: 50),
          pw.Text(
            "____________________",
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          pw.Text("Administrator CSM"),
        ],
      ),
    );
  }

  /// Helper: Format Tanggal ISO ke YYYY-MM-DD
  static String _formatDate(String date) {
    try {
      return date.split('T')[0];
    } catch (e) {
      return date;
    }
  }

  /// Helper: Format Angka ke Ribuan (contoh: 10.000)
  static String _formatNumber(dynamic number) {
    try {
      final n = number is int ? number : int.parse(number.toString());
      return n.toString().replaceAllMapped(
        RegExp(r'\B(?=(\d{3})+(?!\d))'),
        (match) => '.',
      );
    } catch (e) {
      return number.toString();
    }
  }
}
