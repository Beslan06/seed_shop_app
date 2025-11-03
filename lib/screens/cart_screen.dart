import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/cart_item.dart'; // Добавьте этот импорт
import '../services/cart_service.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  void _updateQuantity(
      CartItem item, int newQuantity, CartService cartService) {
    cartService.updateQuantity(item, newQuantity);
  }

  void _removeItem(CartItem item, CartService cartService) {
    cartService.removeItem(item);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item.product.name} удален из корзины'),
        action: SnackBarAction(
          label: 'Отменить',
          onPressed: () {
            cartService.addToCart(item.product);
          },
        ),
      ),
    );
  }

  void _clearCart(CartService cartService) {
    cartService.clearCart();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Корзина очищена')),
    );
  }

  void _showCheckoutDialog(CartService cartService, BuildContext context) {
    if (cartService.cartItems.isEmpty) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Оформление заказа',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Выберите способ оформления заказа:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Text(
              'Итого: ${cartService.totalPrice.toStringAsFixed(2)} ₽',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Товаров: ${cartService.itemCount} ${_getItemsText(cartService.itemCount)}',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Продолжить покупки'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _processEmailOrder(cartService, context);
            },
            icon: const Icon(Icons.email),
            label: const Text('Через почту'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _processPhoneOrder(cartService, context);
            },
            icon: const Icon(Icons.phone),
            label: const Text('Позвонить'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _processEmailOrder(CartService cartService, BuildContext context) {
    final orderDetails = _generateOrderDetails(cartService);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.email, color: Colors.blue),
            SizedBox(width: 8),
            Text('Заказ через почту'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Ваш заказ оформлен! Отправьте нам письмо с деталями:'),
            const SizedBox(height: 12),
            Text(
              'Email: seeds.store@example.com',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue[700],
              ),
            ),
            const SizedBox(height: 8),
            const Text('Тема: Заказ семян'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                orderDetails,
                style: const TextStyle(fontSize: 12),
              ),
            ),
            const SizedBox(height: 8),
            const Text('Скопируйте эту информацию в письмо.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Закрыть'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _clearCart(cartService);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: const Text('Заказ отправлен',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _processPhoneOrder(CartService cartService, BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.phone, color: Colors.green),
            SizedBox(width: 8),
            Text('Заказ по телефону'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Позвоните нам для оформления заказа:'),
            const SizedBox(height: 12),
            Text(
              'Телефон: +7 (938) 006-91-00',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green[700],
              ),
            ),
            const SizedBox(height: 8),
            const Text('Время работы: 9:00 - 18:00'),
            const SizedBox(height: 8),
            const Text('Назовите оператору выбранные товары:'),
            const SizedBox(height: 8),
            ...cartService.cartItems
                .take(3)
                .map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        '• ${item.product.name} - ${item.quantity} шт.',
                        overflow:
                            TextOverflow.ellipsis, // Добавляем обрезку текста
                        maxLines: 1, // Ограничиваем в одну строку
                      ),
                    ))
                .toList(),
            if (cartService.cartItems.length > 3)
              const Text('... и другие товары'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Закрыть'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _clearCart(cartService);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Заказ оформлен',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  String _generateOrderDetails(CartService cartService) {
    final buffer = StringBuffer();
    buffer.writeln('Детали заказа:');
    buffer.writeln('================');
    for (final item in cartService.cartItems) {
      buffer.writeln(
          '${item.product.name} - ${item.quantity} шт. x ${item.product.price} ₽ = ${item.totalPrice.toStringAsFixed(2)} ₽');
    }
    buffer.writeln('================');
    buffer.writeln('Итого: ${cartService.totalPrice.toStringAsFixed(2)} ₽');
    buffer.writeln('Количество товаров: ${cartService.itemCount}');
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    final cartService = Provider.of<CartService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Корзина'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          if (cartService.cartItems.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: () => _clearCart(cartService),
              tooltip: 'Очистить корзину',
            ),
        ],
      ),
      body: cartService.cartItems.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Корзина пуста',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Добавляйте товары в корзину,\nнажимая на кнопку "В корзину"',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Text(
                        'Корзина',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${cartService.itemCount} ${_getItemsText(cartService.itemCount)}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: cartService.cartItems.length,
                    itemBuilder: (context, index) {
                      final item = cartService.cartItems[index];
                      return _buildCartItem(item, cartService);
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Итого:',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${cartService.totalPrice.toStringAsFixed(2)} ₽',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Товаров:'),
                          Text(
                              '${cartService.itemCount} ${_getItemsText(cartService.itemCount)}'),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => _clearCart(cartService),
                              style: OutlinedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text('Очистить корзину'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () =>
                                  _showCheckoutDialog(cartService, context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text('Оформить заказ'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildCartItem(CartItem item, CartService cartService) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  item.product.imageUrl,
                  fit: BoxFit.contain,
                  width: 60,
                  height: 60,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[100],
                      child: Icon(
                        Icons.eco,
                        color: Colors.green[300],
                        size: 30,
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.product.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${item.product.price} ₽/шт',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${item.totalPrice.toStringAsFixed(2)} ₽',
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove, size: 18),
                    onPressed: () =>
                        _updateQuantity(item, item.quantity - 1, cartService),
                    padding: const EdgeInsets.all(4),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    child: Text(
                      item.quantity.toString(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add, size: 18),
                    onPressed: () =>
                        _updateQuantity(item, item.quantity + 1, cartService),
                    padding: const EdgeInsets.all(4),
                  ),
                ],
              ),
            ),
            IconButton(
              icon:
                  const Icon(Icons.delete_outline, color: Colors.red, size: 24),
              onPressed: () => _removeItem(item, cartService),
            ),
          ],
        ),
      ),
    );
  }

  String _getItemsText(int count) {
    if (count % 10 == 1 && count % 100 != 11) {
      return 'товар';
    } else if (count % 10 >= 2 &&
        count % 10 <= 4 &&
        (count % 100 < 10 || count % 100 >= 20)) {
      return 'товара';
    } else {
      return 'товаров';
    }
  }
}
