import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:cafemangemensystem/data/repositorymodels/inventory_repository.dart';
import '../widgets/rupiah_formatter.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final repo = InventoryRepository();
  DateTime? startDate;
  DateTime? endDate;
  List<Map<String, dynamic>> data = [];
  int totalRevenue = 0;
  bool isLoading = false;

  /// Memformat objek DateTime menjadi String YYYY-MM-DD
  String _formatDate(DateTime? date) {
    if (date == null) return "-";
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  /// Menampilkan pemilih tanggal untuk rentang laporan
  Future<void> _pickDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDate: isStart
          ? (startDate ?? DateTime.now())
          : (endDate ?? DateTime.now()),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          startDate = picked;
        } else {
          endDate = picked;
        }
      });
    }
  }

  /// Mengambil data transaksi dari database berdasarkan rentang waktu
  Future<void> _loadReport() async {
    if (startDate == null || endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pilih rentang tanggal terlebih dahulu")),
      );
      return;
    }

    setState(() => isLoading = true);

    final startStr = DateTime(
      startDate!.year,
      startDate!.month,
      startDate!.day,
    ).toIso8601String();
    final endStr = DateTime(
      endDate!.year,
      endDate!.month,
      endDate!.day,
      23,
      59,
      59,
    ).toIso8601String();

    try {
      final results = await repo.getTransactionsByDate(startStr, endStr);
      final revenue = await repo.getTotalSales(startStr, endStr);

      setState(() {
        data = results;
        totalRevenue = revenue;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Gagal memuat data laporan")),
        );
      }
    }
  }

  /// Mengekspor data laporan yang tampil ke dalam format PDF
  Future<void> _exportToPDF() async {
    if (data.isEmpty) return;

    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text(
              "LAPORAN PENDAPATAN CAFE",
              style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Text(
            "Periode: ${_formatDate(startDate)} s/d ${_formatDate(endDate)}",
          ),
          pw.Text("Dicetak pada: ${DateTime.now().toString()}"),
          pw.SizedBox(height: 25),
          pw.TableHelper.fromTextArray(
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            headers: ["Tanggal Transaksi", "Jumlah Pendapatan"],
            data: data.map((e) {
              final rawDate = e['created_at'].toString();
              final dateDisplay = rawDate.contains("T")
                  ? rawDate.split("T")[0]
                  : rawDate;
              return [dateDisplay, RupiahFormatter.format(e['total'] ?? 0)];
            }).toList(),
          ),
          pw.SizedBox(height: 20),
          pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Text(
              "TOTAL PENDAPATAN: ${RupiahFormatter.format(totalRevenue)}",
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
      name: 'Laporan_Penjualan_${_formatDate(startDate)}.pdf',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Laporan Penjualan"),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildFilterSection(),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildReportList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blueGrey.shade900,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(25)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _dateTile("Mulai", startDate, true)),
              const SizedBox(width: 12),
              Expanded(child: _dateTile("Selesai", endDate, false)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.all(15),
                  ),
                  onPressed: _loadReport,
                  icon: const Icon(
                    Icons.analytics_rounded,
                    color: Colors.white,
                  ),
                  label: const Text(
                    "PROSES",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    padding: const EdgeInsets.all(15),
                  ),
                  onPressed: data.isEmpty ? null : _exportToPDF,
                  child: const Icon(Icons.picture_as_pdf, color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _dateTile(String label, DateTime? date, bool isStart) {
    return InkWell(
      onTap: () => _pickDate(isStart),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
            const SizedBox(height: 4),
            Text(
              _formatDate(date),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportList() {
    if (data.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.insert_chart_outlined_rounded,
              size: 80,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            const Text(
              "Tidak ada data untuk periode ini",
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.green.shade100),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Total Pendapatan",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                RupiahFormatter.format(totalRevenue),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade800,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: data.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final item = data[index];
              final rawDate = item['created_at'].toString();
              return ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.receipt_long_rounded, size: 20),
                ),
                title: Text(
                  rawDate.contains("T") ? rawDate.split("T")[0] : rawDate,
                ),
                trailing: Text(
                  RupiahFormatter.format(item['total'] ?? 0),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
