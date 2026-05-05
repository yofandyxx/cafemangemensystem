import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cafemangemensystem/data/repositorymodels/inventory_repository.dart';
import '../providers/cart_provider.dart';
import '../providers/inventory_provider.dart';
import '../widgets/cart_item_widget.dart';
import '../widgets/rupiah_formatter.dart';

class POSScreen extends StatefulWidget {
  const POSScreen({super.key});

  @override
  State<POSScreen> createState() => _POSScreenState();
}

class _POSScreenState extends State<POSScreen> {
  final repo = InventoryRepository();

  @override
  void initState() {
    super.initState();
    // Memuat ulang produk saat masuk ke layar POS untuk memastikan stok terbaru
    context.read<InventoryProvider>().loadProducts();
  }

  /// Memproses transaksi: Simpan ke database, tampilkan struk, dan bersihkan keranjang
  Future<void> _processCheckout(CartProvider cart) async {
    if (cart.items.isEmpty) return;

    final total = cart.total;

    try {
      // 1. Simpan Header Transaksi
      final transactionId = await repo.insertTransaction(total);

      // 2. Simpan Detail Item Transaksi
      for (var item in cart.items) {
        await repo.insertTransactionItem(
          transactionId: transactionId,
          productId: item.product.id!,
          qty: item.quantity,
          price: item.product.price,
        );
      }

      // 3. Salin data untuk struk sebelum keranjang dibersihkan
      final itemsSnapshot = List<CartItem>.from(cart.items);
      cart.clear();

      // 4. Tampilkan Struk Pembayaran
      if (mounted) {
        _showReceiptDialog(context, itemsSnapshot, total);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Gagal memproses transaksi")),
        );
      }
    }
  }

  void _showReceiptDialog(
    BuildContext context,
    List<CartItem> items,
    int total,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle_outline,
                color: Colors.green,
                size: 70,
              ),
              const SizedBox(height: 12),
              const Text(
                "TRANSAKSI BERHASIL",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildReceiptContent(items, total),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "SELESAI",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReceiptContent(List<CartItem> items, int total) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          const Text(
            "STRUK BELANJA",
            style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
          ),
          const Divider(height: 24),
          ...items.map((item) {
            final subtotal = item.product.price * item.quantity;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      item.product.name,
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                  Text(
                    "x${item.quantity}",
                    style: const TextStyle(fontSize: 13),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    RupiahFormatter.format(subtotal),
                    style: const TextStyle(fontSize: 13),
                  ),
                ],
              ),
            );
          }),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "TOTAL",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                RupiahFormatter.format(total),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.teal,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<InventoryProvider>(context);
    final cart = Provider.of<CartProvider>(context);
    final isTablet = MediaQuery.of(context).size.width > 750;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Kasir Digital CSM"),
        centerTitle: true,
        elevation: 0,
      ),
      body: isTablet
          ? Row(
              children: [
                Expanded(flex: 3, child: _productPanel(productProvider, cart)),
                const VerticalDivider(width: 1),
                Expanded(flex: 2, child: _cartPanel(cart)),
              ],
            )
          : Column(
              children: [
                Expanded(flex: 4, child: _productPanel(productProvider, cart)),
                _cartPanel(cart),
              ],
            ),
    );
  }

  Widget _productPanel(InventoryProvider productProvider, CartProvider cart) {
    return productProvider.isLoading
        ? const Center(child: CircularProgressIndicator())
        : GridView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: productProvider.products.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.85,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemBuilder: (_, i) {
              final product = productProvider.products[i];
              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.coffee_rounded,
                      size: 40,
                      color: Colors.teal,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      product.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      RupiahFormatter.format(product.price),
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: () => cart.addToCart(product),
                      child: const Text("Tambah"),
                    ),
                  ],
                ),
              );
            },
          );
  }

  Widget _cartPanel(CartProvider cart) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Keranjang",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                "${cart.items.length} Item",
                style: const TextStyle(color: Colors.teal),
              ),
            ],
          ),
          const SizedBox(height: 15),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.3,
            ),
            child: cart.items.isEmpty
                ? const Center(child: Text("Keranjang kosong"))
                : ListView.separated(
                    shrinkWrap: true,
                    itemCount: cart.items.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (_, i) {
                      final item = cart.items[i];
                      return CartItemWidget(
                        item: item,
                        onAdd: () => cart.increaseQty(item),
                        onRemove: () => cart.decreaseQty(item),
                      );
                    },
                  ),
          ),
          const Divider(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Total Pembayaran",
                style: TextStyle(color: Colors.grey),
              ),
              Text(
                RupiahFormatter.format(cart.total),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding: const EdgeInsets.all(15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: cart.items.isEmpty
                  ? null
                  : () => _processCheckout(cart),
              icon: const Icon(
                Icons.shopping_cart_checkout,
                color: Colors.white,
              ),
              label: const Text(
                "BAYAR SEKARANG",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
