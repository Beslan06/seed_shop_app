import 'package:flutter/material.dart';

import '../models/cart_item.dart';
import '../models/product.dart';

class CartService with ChangeNotifier {
  List<CartItem> _cartItems = [];

  List<CartItem> get cartItems => _cartItems;

  double get totalPrice {
    return _cartItems.fold(0, (total, item) => total + item.totalPrice);
  }

  int get itemCount {
    return _cartItems.fold(0, (total, item) => total + item.quantity);
  }

  // Добавление товара в корзину
  void addToCart(Product product) {
    final existingIndex =
        _cartItems.indexWhere((item) => item.product.id == product.id);

    if (existingIndex != -1) {
      // Увеличиваем количество если товар уже в корзине
      _cartItems[existingIndex] = _cartItems[existingIndex].copyWith(
        quantity: _cartItems[existingIndex].quantity + 1,
      );
    } else {
      // Добавляем новый товар
      _cartItems.add(CartItem(product: product, quantity: 1));
    }
    notifyListeners();
  }

  // Обновление количества
  void updateQuantity(CartItem item, int newQuantity) {
    if (newQuantity <= 0) {
      _cartItems
          .removeWhere((cartItem) => cartItem.product.id == item.product.id);
    } else {
      final index = _cartItems
          .indexWhere((cartItem) => cartItem.product.id == item.product.id);
      if (index != -1) {
        _cartItems[index] = item.copyWith(quantity: newQuantity);
      }
    }
    notifyListeners();
  }

  // Удаление товара
  void removeItem(CartItem item) {
    _cartItems
        .removeWhere((cartItem) => cartItem.product.id == item.product.id);
    notifyListeners();
  }

  // Очистка корзины
  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }

  // Проверка есть ли товар в корзине
  bool isInCart(Product product) {
    return _cartItems.any((item) => item.product.id == product.id);
  }

  // Получение количества конкретного товара
  int getProductQuantity(Product product) {
    final item = _cartItems.firstWhere(
      (item) => item.product.id == product.id,
      orElse: () => CartItem(product: product, quantity: 0),
    );
    return item.quantity;
  }
}
