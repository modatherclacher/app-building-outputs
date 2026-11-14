import 'package:flutter/material.dart';

import '../store.dart';

class CartPage extends StatelessWidget {
  final Store store;

  const CartPage({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    final lines = store.cartLines;
    if (lines.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.shopping_cart_outlined, size: 64),
            SizedBox(height: 12),
            Text('سلتك فارغة — أضف بعض المنتجات!'),
          ],
        ),
      );
    }
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(12),
            children: [
              for (final line in lines)
                Card(
                  child: ListTile(
                    leading: Text(
                      line.product.emoji,
                      style: const TextStyle(fontSize: 28),
                    ),
                    title: Text(line.product.name),
                    subtitle: Text(
                      '${line.product.price.toStringAsFixed(2)} ر.س × ${line.qty} = ${line.total.toStringAsFixed(2)} ر.س',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: 'إنقاص',
                          onPressed: () => store.decrement(line.product.id),
                          icon: const Icon(Icons.remove_circle_outline),
                        ),
                        Text(
                          '${line.qty}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          tooltip: 'زيادة',
                          onPressed: () => store.addToCart(line.product.id),
                          icon: const Icon(Icons.add_circle_outline),
                        ),
                        IconButton(
                          tooltip: 'حذف',
                          onPressed: () => store.removeFromCart(line.product.id),
                          icon: const Icon(Icons.delete_outline),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        SafeArea(
          minimum: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'الإجمالي: ${store.cartTotal.toStringAsFixed(2)} ر.س',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              FilledButton.icon(
                onPressed: () => _checkout(context),
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('إتمام الطلب'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _checkout(BuildContext context) {
    final order = store.checkout();
    if (order == null) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('تم إنشاء الطلب ${order.id} بنجاح')),
    );
  }
}
