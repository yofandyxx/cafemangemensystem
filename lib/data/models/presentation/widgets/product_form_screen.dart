import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:cafemangemensystem/data/models/product_model.dart';
import '../providers/inventory_provider.dart';

class ProductFormScreen extends StatefulWidget {
  final Product? product;
  const ProductFormScreen({super.key, this.product});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final priceController = TextEditingController();
  final stockController = TextEditingController();

  String? selectedCategory;
  File? imageFile;
  final ImagePicker picker = ImagePicker();
  bool isSaving = false;
  bool isLoadingCategory = true;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  /// Inisialisasi data untuk mode Edit atau Tambah Baru
  Future<void> _initData() async {
    final provider = Provider.of<InventoryProvider>(context, listen: false);
    await provider.loadCategories();

    if (widget.product != null) {
      final p = widget.product!;
      nameController.text = p.name;
      priceController.text = _formatNumber(p.price.toString());
      stockController.text = p.stock.toString();
      selectedCategory = p.category;
      if (p.image != null && p.image!.isNotEmpty) {
        imageFile = File(p.image!);
      }
    }

    if (mounted) {
      setState(() => isLoadingCategory = false);
    }
  }

  String _formatNumber(String s) {
    if (s.isEmpty) return "";
    final number = int.parse(s.replaceAll(RegExp(r'[^0-9]'), ''));
    return NumberFormat("#,###", "id_ID").format(number);
  }

  Future<void> _pickImage() async {
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (picked != null) {
      setState(() => imageFile = File(picked.path));
    }
  }

  Future<void> _saveProduct() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => isSaving = true);
    try {
      final provider = Provider.of<InventoryProvider>(context, listen: false);
      final cleanPrice = int.parse(priceController.text.replaceAll('.', ''));

      final product = Product(
        id: widget.product?.id,
        name: nameController.text.trim(),
        price: cleanPrice,
        stock: int.tryParse(stockController.text) ?? 0,
        category: selectedCategory ?? "Umum",
        image: imageFile?.path ?? "",
      );

      if (widget.product == null) {
        await provider.addProduct(product);
      } else {
        await provider.updateProduct(product);
      }

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gagal menyimpan: $e")));
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<InventoryProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.product == null ? "Tambah Produk" : "Edit Produk"),
        centerTitle: true,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImagePicker(),
              const SizedBox(height: 25),
              _buildTextField(
                controller: nameController,
                label: "Nama Produk",
                icon: Icons.fastfood_outlined,
              ),
              const SizedBox(height: 16),
              _buildPriceField(),
              const SizedBox(height: 16),
              _buildTextField(
                controller: stockController,
                label: "Stok Barang",
                icon: Icons.inventory_2_outlined,
                isNumber: true,
              ),
              const SizedBox(height: 16),
              _buildCategoryDropdown(provider),
              const SizedBox(height: 30),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return Center(
      child: GestureDetector(
        onTap: _pickImage,
        child: Container(
          height: 160,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.grey.shade300,
              strokeAlign: BorderSide.strokeAlignOutside,
            ),
            image: imageFile != null
                ? DecorationImage(
                    image: FileImage(imageFile!),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: imageFile == null
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_a_photo_outlined,
                      size: 40,
                      color: Colors.teal.shade300,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Tambah Foto Produk",
                      style: TextStyle(color: Colors.teal.shade700),
                    ),
                  ],
                )
              : const SizedBox.shrink(),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isNumber = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: _inputDecoration(label, icon),
      validator: (v) =>
          v == null || v.trim().isEmpty ? "Field ini wajib diisi" : null,
    );
  }

  Widget _buildPriceField() {
    return TextFormField(
      controller: priceController,
      keyboardType: TextInputType.number,
      decoration: _inputDecoration("Harga Jual", Icons.payments_outlined)
          .copyWith(
            prefixText: "Rp ",
            prefixStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.teal,
            ),
          ),
      onChanged: (value) {
        if (value.isEmpty) return;
        final formatted = _formatNumber(value);
        priceController.value = TextEditingValue(
          text: formatted,
          selection: TextSelection.collapsed(offset: formatted.length),
        );
      },
      validator: (v) => v == null || v.isEmpty ? "Harga wajib diisi" : null,
    );
  }

  Widget _buildCategoryDropdown(InventoryProvider provider) {
    if (isLoadingCategory) return const LinearProgressIndicator();

    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<String>(
            initialValue: selectedCategory,
            decoration: _inputDecoration("Kategori", Icons.category_outlined),
            items: provider.categories.map<DropdownMenuItem<String>>((c) {
              return DropdownMenuItem<String>(
                value: c.name,
                child: Text(c.name),
              );
            }).toList(),
            onChanged: (v) => setState(() => selectedCategory = v),
            validator: (v) => v == null ? "Pilih kategori" : null,
          ),
        ),
        const SizedBox(width: 10),
        IconButton.filled(
          onPressed: () => _addCategoryDialog(provider),
          icon: const Icon(Icons.add),
          style: IconButton.styleFrom(backgroundColor: Colors.teal),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        onPressed: isSaving ? null : _saveProduct,
        child: isSaving
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(
                widget.product == null ? "TAMBAH PRODUK" : "SIMPAN PERUBAHAN",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.teal),
      filled: true,
      fillColor: Colors.grey.shade50,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Colors.teal, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
    );
  }

  void _addCategoryDialog(InventoryProvider provider) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Kategori Baru"),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: "Contoh: Minuman Dingin"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("BATAL"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.trim().isEmpty) return;
              final categoryName = controller.text.trim();
              await provider.addCategory(categoryName);
              if (!mounted) return;
              setState(() => selectedCategory = categoryName);
              if (mounted) Navigator.pop(context);
            },
            child: const Text("TAMBAH"),
          ),
        ],
      ),
    );
  }
}
