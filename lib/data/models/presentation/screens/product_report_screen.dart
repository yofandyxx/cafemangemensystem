import 'package:flutter/material.dart';
import 'package:cafemangemensystem/data/models/product_model.dart';
import 'package:provider/provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../providers/inventory_provider.dart';
import '../widgets/rupiah_formatter.dart';

class ProductReportScreen extends StatefulWidget {
  const ProductReportScreen({super.key});

  @override
  State<ProductReportScreen> createState() => _ProductReportScreenState();
}

class _ProductReportScreenState extends State<ProductReportScreen> {
  String? selectedCategory;

  @override
  void initState() {
    super.initState();
    context.read<InventoryProvider>().loadCategories();
  }

  /// Memuat data produk berdasarkan kategori yang dipilih
  Future<void> _fetchReportData() async {
    if (selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Silakan pilih kategori terlebih dahulu")),
      );
      return;
    }
    await Provider.of<InventoryProvider>(
      context,
      listen: false,
    ).loadProductsByCategory(selectedCategory!);
  }

  /// Menghasilkan dokumen PDF dan membuka pratinjau cetak
  Future<void> _exportToPDF(List<Product> products) async {
    if (products.isEmpty) return;

    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text(
              "LAPORAN DATA PRODUK",
              style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Text("Kategori: ${selectedCategory?.toUpperCase()}"),
          pw.Text(
            "Tanggal Laporan: ${DateTime.now().toString().split(' ')[0]}",
          ),
          pw.SizedBox(height: 20),
          pw.TableHelper.fromTextArray(
            headers: ["Nama Produk", "Sisa Stok", "Harga"],
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            border: pw.TableBorder.all(),
            data: products.map((p) {
              return [
                p.name,
                p.stock.toString(),
                RupiahFormatter.format(p.price),
              ];
            }).toList(),
          ),
          pw.SizedBox(height: 20),
          pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Text(
              "Total Item: ${products.length}",
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
      name: 'Laporan_Produk_${selectedCategory?.replaceAll(' ', '_')}.pdf',
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<InventoryProvider>(context);
    final products = provider.categoryProducts;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Laporan Produk"),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildFilterPanel(provider),
          Expanded(
            child: provider.isCategoryLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildContentArea(products),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterPanel(InventoryProvider provider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.teal.shade700,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            dropdownColor: Colors.teal.shade50,
            initialValue: selectedCategory,
            hint: const Text(
              "Pilih Kategori Produk",
              style: TextStyle(color: Colors.white70),
            ),
            style: const TextStyle(color: Colors.black87),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            items: provider.categories.map<DropdownMenuItem<String>>((c) {
              return DropdownMenuItem<String>(
                value: c.name,
                child: Text(c.name),
              );
            }).toList(),
            onChanged: (v) => setState(() => selectedCategory = v),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(15),
                  ),
                  onPressed: _fetchReportData,
                  icon: const Icon(Icons.search),
                  label: const Text("CARI DATA"),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(15),
                  ),
                  onPressed: provider.categoryProducts.isEmpty
                      ? null
                      : () => _exportToPDF(provider.categoryProducts),
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text("PDF"),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContentArea(List<Product> products) {
    if (products.isEmpty) {
      return const Center(
        child: Text("Gunakan filter di atas untuk melihat data"),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Hasil Laporan",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              Chip(
                label: Text("${products.length} Item"),
                backgroundColor: Colors.teal.shade100,
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: products.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final p = products[i];
              return Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.orange.shade50,
                    child: const Icon(
                      Icons.inventory_2_rounded,
                      color: Colors.orange,
                    ),
                  ),
                  title: Text(
                    p.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text("Stok Tersisa: ${p.stock}"),
                  trailing: Text(
                    RupiahFormatter.format(p.price),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
