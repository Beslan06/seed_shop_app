// lib/screens/favorites_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../widgets/product_card.dart';
import 'product_detail_screen.dart';
import '../services/favorites_service.dart';
import '../services/cart_service.dart'; // ← добавили импорт

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final favoritesService =
          Provider.of<FavoritesService>(context, listen: false);
      favoritesService.loadFavorites();
    });
  }

  Future<void> _toggleFavorite(BuildContext context, Product product) async {
    final favoritesService =
        Provider.of<FavoritesService>(context, listen: false);
    await favoritesService.toggleFavorite(product);
  }

  bool _isFavorite(BuildContext context, Product product) {
    final favoritesService =
        Provider.of<FavoritesService>(context, listen: false);
    return favoritesService.isFavorite(product.id);
  }

  void _navigateToProductDetail(BuildContext context, Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailScreen(
          product: product,
          isFavorite: _isFavorite(context, product),
          onFavoriteToggle: () => _toggleFavorite(context, product),
        ),
      ),
    );
  }

  void _navigateToCatalog(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Перейдите во вкладку "Каталог"'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Избранное'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Consumer<FavoritesService>(
        builder: (context, favoritesService, child) {
          if (favoritesService.isLoading) {
            return _buildLoadingState();
          }

          final favorites = favoritesService.favorites;

          if (favorites.isEmpty) {
            return _buildEmptyState(context);
          }

          return _buildFavoritesList(context, favorites, favoritesService);
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Colors.green),
          SizedBox(height: 16),
          Text('Загрузка избранного...'),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.favorite_border,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          const Text(
            'Нет избранных товаров',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          const Text(
            'Добавляйте товары в избранное,\nнажимая на сердечко',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => _navigateToCatalog(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Перейти в каталог'),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoritesList(BuildContext context, List<Product> favorites,
      FavoritesService favoritesService) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Text(
                'Избранное',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                '${favorites.length} ${_getItemsText(favorites.length)}',
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
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final product = favorites[index];
              final cartService = Provider.of<CartService>(context,
                  listen: false); // ← получаем

              return ProductCard(
                product: product,
                onTap: () => _navigateToProductDetail(context, product),
                onFavoriteToggle: () => _toggleFavorite(context, product),
                isFavorite: true,
                cartService: cartService, // ← передаём
              );
            },
          ),
        ),
      ],
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
