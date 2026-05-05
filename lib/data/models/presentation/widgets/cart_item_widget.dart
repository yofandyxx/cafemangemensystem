import 'package:flutter/material.dart';
import '../../presentation/providers/cart_provider.dart';
import 'rupiah_formatter.dart';

class CartItemWidget extends StatelessWidget {
  final CartItem item;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const CartItemWidget({
    super.key,
    required this.item,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final subtotal = item.product.price * item.quantity;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: CircleAvatar(
          backgroundColor: Colors.teal.shade50,
          child: const Icon(Icons.fastfood, color: Colors.teal, size: 20),
        ),
        title: Text(
          item.product.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${RupiahFormatter.format(item.product.price)} / unit",
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
            Text(
              "Subtotal: ${RupiahFormatter.format(subtotal)}",
              style: const TextStyle(
                color: Colors.teal,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
        trailing: Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildQtyButton(Icons.remove, onRemove, isDelete: item.quantity == 1),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  item.quantity.toString(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              _buildQtyButton(Icons.add, onAdd),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQtyButton(IconData icon, VoidCallback onPressed, {bool isDelete = false}) {
    return IconButton(
      visualDensity: VisualDensity.compact,
      icon: Icon(
        isDelete ? Icons.delete_outline : icon,
        size: 18,
        color: isDelete ? Colors.red : Colors.teal,
      ),
      onPressed: onPressed,
    );
  }
}