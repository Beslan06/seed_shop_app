// lib/screens/product_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../services/cart_service.dart';
// import '../services/favorites_service.dart';

class ProductDetailScreen extends StatelessWidget {
  final Product product;
  final bool isFavorite; // ВОССТАНАВЛИВАЕМ
  final VoidCallback onFavoriteToggle; // ВОССТАНАВЛИВАЕМ

  const ProductDetailScreen({
    super.key,
    required this.product,
    required this.isFavorite, // ВОССТАНАВЛИВАЕМ
    required this.onFavoriteToggle, // ВОССТАНАВЛИВАЕМ
  });

  @override
  Widget build(BuildContext context) {
    final cartService = Provider.of<CartService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Детали товара'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? Colors.red : Colors.white,
            ),
            onPressed: onFavoriteToggle, // ИСПОЛЬЗУЕМ переданный колбэк
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Красивое изображение товара
            Container(
              width: double.infinity,
              height: 250,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.grey[50],
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  color: Colors.white,
                  child: Image.asset(
                    product.imageUrl,
                    fit: BoxFit.contain,
                    width: double.infinity,
                    height: 250,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[100],
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.eco,
                              color: Colors.green[300],
                              size: 80,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Изображение не найдено',
                              style: TextStyle(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Название и цена
            Row(
              children: [
                Expanded(
                  child: Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Text(
                  '${product.price} ₽',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Категория и статус
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getCategoryColor(product.category),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    product.category,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: product.inStock ? Colors.green[50] : Colors.red[50],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: product.inStock ? Colors.green : Colors.red,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        product.inStock ? Icons.check_circle : Icons.cancel,
                        color: product.inStock ? Colors.green : Colors.red,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        product.inStock ? 'В наличии' : 'Нет в наличии',
                        style: TextStyle(
                          color: product.inStock ? Colors.green : Colors.red,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Описание
            const Text(
              'Описание',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              product.description,
              style: const TextStyle(
                fontSize: 16,
                height: 1.5,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 20),

            // Дополнительная информация
            _buildInfoCard(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(context, cartService),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildInfoRow('На складе:', '${product.stockCount} шт.'),
            const SizedBox(height: 8),
            _buildInfoRow('Категория:', product.category),
            const SizedBox(height: 8),
            _buildInfoRow(
                'Статус:', product.inStock ? 'В наличии' : 'Нет в наличии'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String title, String value) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Овощи':
        return Colors.green;
      case 'Цветы':
        return Colors.pink;
      case 'Зелень':
        return Colors.lightGreen;
      case 'Наборы':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  Widget _buildBottomBar(BuildContext context, CartService cartService) {
    return Container(
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
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: product.inStock
                  ? () {
                      cartService.addToCart(product);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${product.name} добавлен в корзину'),
                          backgroundColor: Colors.green,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      );
                    }
                  : null,
              icon: const Icon(Icons.shopping_cart),
              label: const Text('В корзину'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
