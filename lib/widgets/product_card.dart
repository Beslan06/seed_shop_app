// lib/widgets/product_card.dart
import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/cart_service.dart'; // ← Добавляем импорт

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;
  final bool isFavorite;
  final bool showFavoriteButton; // Новая опция
  final CartService cartService; // ← Добавляем сервис корзины

  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
    required this.onFavoriteToggle,
    required this.isFavorite,
    this.showFavoriteButton = true, // По умолчанию показываем кнопку
    required this.cartService, // ← Обязательный параметр
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Изображение товара
              _buildProductImage(),
              const SizedBox(width: 12),

              // Информация о товаре
              Expanded(
                child: _buildProductInfo(),
              ),

              // Кнопка избранного (если разрешено)
              if (showFavoriteButton) _buildFavoriteButton(),

              // Кнопка добавления в корзину — только если в наличии
              if (product.inStock) _buildAddToCartButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductImage() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.asset(
          product.imageUrl,
          fit: BoxFit.contain,
          width: 80,
          height: 80,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey[100],
              child: Icon(
                Icons.eco,
                color: Colors.green[300],
                size: 40,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildProductInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Название товара
        Text(
          product.name,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),

        // Категория
        _buildCategoryChip(),
        const SizedBox(height: 6),

        // Цена + Корзина (в одной строке)
        Row(
          children: [
            Text(
              '${product.price} ₽',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(width: 8),
            // Здесь будет кнопка корзины — но она уже вынесена в отдельный виджет выше
          ],
        ),
        const SizedBox(height: 4),

        // Статус наличия
        _buildStockStatus(),
      ],
    );
  }

  Widget _buildCategoryChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: _getCategoryColor(product.category),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        product.category,
        style: const TextStyle(
          fontSize: 10,
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildStockStatus() {
    return Row(
      children: [
        Icon(
          product.inStock ? Icons.check_circle : Icons.cancel,
          color: product.inStock ? Colors.green : Colors.red,
          size: 14,
        ),
        const SizedBox(width: 4),
        Text(
          product.inStock ? 'В наличии' : 'Нет в наличии',
          style: TextStyle(
            color: product.inStock ? Colors.green : Colors.red,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        if (product.inStock)
          Text(
            '${product.stockCount} шт.',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
      ],
    );
  }

  Widget _buildFavoriteButton() {
    return IconButton(
      onPressed: onFavoriteToggle,
      icon: Icon(
        isFavorite ? Icons.favorite : Icons.favorite_border,
        color: isFavorite ? Colors.red : Colors.grey,
        size: 24,
      ),
      tooltip: isFavorite ? 'Удалить из избранного' : 'Добавить в избранное',
    );
  }

  Widget _buildAddToCartButton(BuildContext context) {
    return IconButton(
      onPressed: () {
        // Добавляем товар в корзину
        cartService.addToCart(product);

        // Показываем SnackBar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ ${product.name} добавлен в корзину'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      },
      icon: Icon(
        Icons.shopping_cart_outlined,
        color: Colors.green,
        size: 24,
      ),
      tooltip: 'Добавить в корзину',
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
}
