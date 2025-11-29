import 'package:flutter/material.dart';
import '../services/database_service.dart';

class CartProvider with ChangeNotifier {
  final DatabaseService _db = DatabaseService();
  final List<Map<String, dynamic>> _items = [];

  List<Map<String, dynamic>> get items => _items;

  double get total {
    return _items.fold(0, (sum, item) => sum + (item['price'] * item['qty']));
  }

  void addToCart(Map<String, dynamic> product) {
    final index = _items.indexWhere((item) => item['id'] == product['id']);
    if (index >= 0) {
      _items[index]['qty'] += 1;
    } else {
      _items.add({
        ...product,
        'qty': 1,
        'price':
            product['sellPrice'] ??
            product['price'] ??
            0, // Handle price field variations
      });
    }
    notifyListeners();
  }

  void removeFromCart(String productId) {
    _items.removeWhere((item) => item['id'] == productId);
    notifyListeners();
  }

  void updateQty(String productId, int qty) {
    final index = _items.indexWhere((item) => item['id'] == productId);
    if (index >= 0) {
      if (qty <= 0) {
        _items.removeAt(index);
      } else {
        _items[index]['qty'] = qty;
      }
      notifyListeners();
    }
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  Future<bool> processPayment(
    String storeId,
    double amountPaid,
    String paymentMethod,
  ) async {
    if (_items.isEmpty) return false;

    try {
      final transaction = {
        'storeId': storeId,
        'items': _items,
        'total': total,
        'amountPaid': amountPaid,
        'change': amountPaid - total,
        'paymentMethod': paymentMethod,
        'date': DateTime.now().toIso8601String(),
        'status': 'completed',
      };

      await _db.createTransaction(transaction);
      clearCart();
      return true;
    } catch (e) {
      print("Payment error: $e");
      return false;
    }
  }
}
