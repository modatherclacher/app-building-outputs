import 'package:flutter/foundation.dart';

@immutable
class Product {
  final String id;
  final String name;
  final String category;
  final double price;
  final int stock;
  final String emoji;

  const Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.stock,
    required this.emoji,
  });

  Product copyWith({
    String? name,
    String? category,
    double? price,
    int? stock,
    String? emoji,
  }) =>
      Product(
        id: id,
        name: name ?? this.name,
        category: category ?? this.category,
        price: price ?? this.price,
        stock: stock ?? this.stock,
        emoji: emoji ?? this.emoji,
      );
}

class CartLine {
  final Product product;
  final int qty;

  const CartLine({required this.product, required this.qty});

  double get total => product.price * qty;
}

class Order {
  final String id;
  final DateTime at;
  final List<CartLine> lines;

  const Order({required this.id, required this.at, required this.lines});

  double get total => lines.fold(0.0, (sum, line) => sum + line.total);
}

class Store extends ChangeNotifier {
  final List<Product> _products = const [
    Product(id: 'p1', name: 'تفاح أحمر', category: 'فواكه', price: 4.50, stock: 20, emoji: '🍎'),
    Product(id: 'p2', name: 'موز', category: 'فواكه', price: 3.00, stock: 15, emoji: '🍌'),
    Product(id: 'p3', name: 'جزر', category: 'خضروات', price: 2.00, stock: 30, emoji: '🥕'),
    Product(id: 'p4', name: 'طماطم', category: 'خضروات', price: 2.50, stock: 25, emoji: '🍅'),
    Product(id: 'p5', name: 'حليب', category: 'ألبان', price: 6.00, stock: 12, emoji: '🥛'),
    Product(id: 'p6', name: 'جبن', category: 'ألبان', price: 9.00, stock: 8, emoji: '🧀'),
    Product(id: 'p7', name: 'خبز', category: 'مخبوزات', price: 1.50, stock: 10, emoji: '🍞'),
    Product(id: 'p8', name: 'كرواسون', category: 'مخبوزات', price: 2.75, stock: 6, emoji: '🥐'),
    Product(id: 'p9', name: 'عصير برتقال', category: 'مشروبات', price: 5.00, stock: 18, emoji: '🧃'),
    Product(id: 'p10', name: 'ماء', category: 'مشروبات', price: 1.00, stock: 40, emoji: '💧'),
  ];

  final Map<String, int> _cart = {};
  final List<Order> _orders = [];
  int _seq = 1;

  List<Product> get products => List.unmodifiable(_products);

  List<Order> get orders => List.unmodifiable(_orders);

  List<String> get categories => _products.map((p) => p.category).toSet().toList();

  List<CartLine> get cartLines {
    final lines = <CartLine>[];
    for (final entry in _cart.entries) {
      final i = _products.indexWhere((p) => p.id == entry.key);
      if (i >= 0) lines.add(CartLine(product: _products[i], qty: entry.value));
    }
    return lines;
  }

  int get cartCount => _cart.values.fold(0, (a, b) => a + b);

  double get cartTotal => cartLines.fold(0.0, (sum, line) => sum + line.total);

  void addToCart(String id) {
    final i = _products.indexWhere((p) => p.id == id);
    if (i < 0) return;
    final inCart = _cart[id] ?? 0;
    if (inCart >= _products[i].stock) return;
    _cart[id] = inCart + 1;
    notifyListeners();
  }

  void decrement(String id) {
    final qty = (_cart[id] ?? 0) - 1;
    if (qty <= 0) {
      _cart.remove(id);
    } else {
      _cart[id] = qty;
    }
    notifyListeners();
  }

  void removeFromCart(String id) {
    _cart.remove(id);
    notifyListeners();
  }

  Order? checkout() {
    final lines = cartLines;
    if (lines.isEmpty) return null;
    final order = Order(id: 'ORD-$_seq', at: DateTime.now(), lines: lines);
    _seq++;
    for (final line in lines) {
      final i = _products.indexWhere((p) => p.id == line.product.id);
      if (i >= 0) {
        _products[i] = _products[i].copyWith(stock: _products[i].stock - line.qty);
      }
    }
    _orders.insert(0, order);
    _cart.clear();
    notifyListeners();
    return order;
  }

  void saveProduct({
    String? id,
    required String name,
    required String category,
    required double price,
    required int stock,
    required String emoji,
  }) {
    if (id == null) {
      _products.add(Product(
        id: 'p${DateTime.now().microsecondsSinceEpoch}',
        name: name,
        category: category,
        price: price,
        stock: stock,
        emoji: emoji,
      ));
    } else {
      final i = _products.indexWhere((p) => p.id == id);
      if (i >= 0) {
        _products[i] = Product(
          id: id,
          name: name,
          category: category,
          price: price,
          stock: stock,
          emoji: emoji,
        );
      }
    }
    notifyListeners();
  }

  void deleteProduct(String id) {
    _products.removeWhere((p) => p.id == id);
    _cart.remove(id);
    notifyListeners();
  }
}
