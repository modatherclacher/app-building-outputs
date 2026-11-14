import 'package:flutter/material.dart';

import '../store.dart';

class ProductsPage extends StatefulWidget {
  final Store store;

  const ProductsPage({super.key, required this.store});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  String _category = 'الكل';
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final store = widget.store;
    final categories = ['الكل', ...store.categories];
    final products = store.products
        .where((p) => _category == 'الكل' || p.category == _category)
        .where((p) => _query.isEmpty || p.name.contains(_query))
        .toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: TextField(
            onChanged: (v) => setState(() => _query = v.trim()),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: 'ابحث عن منتج…',
              isDense: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        SizedBox(
          height: 52,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            children: [
              for (final c in categories)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text(c),
                    selected: _category == c,
                    onSelected: (_) => setState(() => _category = c),
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: products.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.search_off, size: 56),
                      SizedBox(height: 12),
                      Text('لا توجد منتجات مطابقة'),
                    ],
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 220,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 0.82,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, i) => _ProductCard(
                    product: products[i],
                    onAdd: () => store.addToCart(products[i].id),
                  ),
                ),
        ),
      ],
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onAdd;

  const _ProductCard({required this.product, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final soldOut = product.stock == 0;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Center(
                child: Text(product.emoji, style: const TextStyle(fontSize: 44)),
              ),
            ),
            Text(
              product.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 2),
            Text(
              '${product.category} · ${product.price.toStringAsFixed(2)} ر.س',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              soldOut ? 'نفذت الكمية' : 'المتوفر: ${product.stock}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: soldOut ? Theme.of(context).colorScheme.error : null,
                  ),
            ),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: soldOut ? null : onAdd,
              icon: const Icon(Icons.add_shopping_cart, size: 18),
              label: const Text('أضف للسلة'),
            ),
          ],
        ),
      ),
    );
  }
}
