import 'package:flutter/material.dart';

import '../store.dart';

class OrdersPage extends StatelessWidget {
  final Store store;

  const OrdersPage({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    final orders = store.orders;
    if (orders.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.receipt_long_outlined, size: 64),
            SizedBox(height: 12),
            Text('لا توجد طلبات بعد'),
          ],
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        for (final order in orders)
          Card(
            child: ExpansionTile(
              leading: const Icon(Icons.receipt_long),
              title: Text('الطلب ${order.id}'),
              subtitle: Text(
                '${order.at.day}/${order.at.month}/${order.at.year} · ${order.lines.length} صنف',
              ),
              childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              children: [
                for (final line in order.lines)
                  ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: Text(
                      line.product.emoji,
                      style: const TextStyle(fontSize: 22),
                    ),
                    title: Text(line.product.name),
                    trailing: Text(
                      '${line.qty} × ${line.product.price.toStringAsFixed(2)} ر.س',
                    ),
                  ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'الإجمالي',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${order.total.toStringAsFixed(2)} ر.س',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }
}
