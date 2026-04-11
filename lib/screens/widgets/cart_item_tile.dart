import 'package:flutter/material.dart';
import '../../controllers/cart_controller.dart';

class CartItemTile extends StatelessWidget {
  final CartItem item;
  final CartController controller;

  const CartItemTile({
    super.key,
    required this.item,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(item.productId),
      direction: DismissDirection.horizontal,
      onDismissed: (_) => controller.removeItem(item),
      background: _bg(Alignment.centerLeft),
      secondaryBackground: _bg(Alignment.centerRight),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                item.image,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                const Icon(Icons.image, size: 60),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style:
                      const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text('₹${item.price}',
                      style:
                      const TextStyle(color: Colors.red)),
                ],
              ),
            ),
            _qty(Icons.remove,
                    () => controller.decreaseQty(item)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text(item.quantity.toString()),
            ),
            _qty(Icons.add,
                    () => controller.increaseQty(item)),
          ],
        ),
      ),
    );
  }

  Widget _qty(IconData icon, VoidCallback onTap) {
    return CircleAvatar(
      radius: 16,
      backgroundColor: Colors.orange,
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: Icon(icon, size: 16, color: Colors.white),
        onPressed: onTap,
      ),
    );
  }

  Widget _bg(Alignment a) {
    return Container(
      alignment: a,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      color: Colors.red.withOpacity(0.2),
      child: const Icon(Icons.delete, color: Colors.red),
    );
  }
}
