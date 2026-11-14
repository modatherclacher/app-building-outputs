import 'package:flutter/material.dart';

import '../store.dart';

const _fallbackEmojis = ['🛍️', '📦', '🧺', '☕', '🪴'];

class ManagePage extends StatelessWidget {
  final Store store;

  const ManagePage({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    final products = store.products;
    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 80),
          children: [
            for (final p in products)
              Card(
                child: ListTile(
                  leading: Text(p.emoji, style: const TextStyle(fontSize: 26)),
                  title: Text(p.name),
                  subtitle: Text(
                    '${p.category} · ${p.price.toStringAsFixed(2)} ر.س · المتوفر: ${p.stock}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: 'تعديل',
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: () => _showForm(context, existing: p),
                      ),
                      IconButton(
                        tooltip: 'حذف',
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => _confirmDelete(context, p),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        Positioned(
          bottom: 16,
          left: 16,
          child: FloatingActionButton.extended(
            onPressed: () => _showForm(context),
            icon: const Icon(Icons.add),
            label: const Text('منتج جديد'),
          ),
        ),
      ],
    );
  }

  String _pickEmoji(String name) =>
      _fallbackEmojis[name.length % _fallbackEmojis.length];

  Future<void> _showForm(BuildContext context, {Product? existing}) {
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final catCtrl = TextEditingController(text: existing?.category ?? '');
    final priceCtrl =
        TextEditingController(text: existing?.price.toString() ?? '');
    final stockCtrl =
        TextEditingController(text: existing?.stock.toString() ?? '');
    final formKey = GlobalKey<FormState>();
    final categories = store.categories;

    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(existing == null ? 'منتج جديد' : 'تعديل المنتج'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'اسم المنتج',
                    prefixIcon: Icon(Icons.label_outline),
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'أدخل الاسم' : null,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: catCtrl,
                  decoration: const InputDecoration(
                    labelText: 'التصنيف',
                    prefixIcon: Icon(Icons.category_outlined),
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'أدخل التصنيف' : null,
                ),
                Wrap(
                  spacing: 6,
                  children: [
                    for (final c in categories)
                      ActionChip(
                        label: Text(c),
                        onPressed: () => catCtrl.text = c,
                      ),
                  ],
                ),
                TextFormField(
                  controller: priceCtrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'السعر (ر.س)'),
                  validator: (v) =>
                      ((double.tryParse(v?.trim() ?? '') ?? 0) <= 0)
                          ? 'أدخل سعراً صحيحاً'
                          : null,
                ),
                TextFormField(
                  controller: stockCtrl,
                  keyboardType: TextInputType.number,
                  decoration:
                      const InputDecoration(labelText: 'الكمية المتوفرة'),
                  validator: (v) =>
                      ((int.tryParse(v?.trim() ?? '') ?? -1) < 0)
                          ? 'أدخل كمية صحيحة'
                          : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () {
              if (!(formKey.currentState?.validate() ?? false)) return;
              store.saveProduct(
                id: existing?.id,
                name: nameCtrl.text.trim(),
                category: catCtrl.text.trim(),
                price: double.parse(priceCtrl.text.trim()),
                stock: int.parse(stockCtrl.text.trim()),
                emoji: existing?.emoji ?? _pickEmoji(nameCtrl.text.trim()),
              );
              Navigator.of(context).pop();
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, Product p) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف المنتج'),
        content: Text('هل تريد حذف "${p.name}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
    if (!context.mounted || ok != true) return;
    store.deleteProduct(p.id);
  }
}
