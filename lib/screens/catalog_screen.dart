// lib/screens/catalog_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/mock_data.dart';
import '../models/product.dart';
import '../widgets/product_card.dart';
import 'product_detail_screen.dart';
import 'home_screen.dart';
import '../services/favorites_service.dart';
import '../services/cart_service.dart'; // ← добавили импорт

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  String _selectedCategory = 'Все';
  final TextEditingController _searchController = TextEditingController();

  List<Product> get _filteredProducts {
    var products = MockData.products;

    if (_selectedCategory != 'Все') {
      products =
          products.where((p) => p.category == _selectedCategory).toList();
    }

    if (_searchController.text.isNotEmpty) {
      products = products
          .where((p) =>
              p.name
                  .toLowerCase()
                  .contains(_searchController.text.toLowerCase()) ||
              p.description
                  .toLowerCase()
                  .contains(_searchController.text.toLowerCase()))
          .toList();
    }

    return products;
  }

  Future<void> _toggleFavorite(BuildContext context, Product product) async {
    final favoritesService =
        Provider.of<FavoritesService>(context, listen: false);

    if (!favoritesService.isUserAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Войдите в аккаунт чтобы сохранять избранное'),
          backgroundColor: Colors.orange,
          action: SnackBarAction(
            label: 'Войти',
            onPressed: () {
              final homeState =
                  context.findAncestorStateOfType<HomeScreenState>();
              if (homeState != null) {
                homeState.navigateToTab(3);
              }
            },
          ),
        ),
      );
      return;
    }

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

  @override
  Widget build(BuildContext context) {
    final favoritesService = Provider.of<FavoritesService>(context);
    final favoritesCount = favoritesService.favoritesCount;

    final categories = ['Все', ...MockData.categories];

    return Column(
      children: [
        // Поисковая строка
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Поиск семян...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            ),
            onChanged: (value) => setState(() {}),
          ),
        ),

        // Категории
        Container(
          height: 50,
          child: Center(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: categories.map((category) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      label: Text(category),
                      selected: _selectedCategory == category,
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategory = category;
                        });
                      },
                      selectedColor: Colors.green,
                      labelStyle: TextStyle(
                        color: _selectedCategory == category
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ),

        const SizedBox(height: 8),

        // Информация о количестве товаров
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Text(
                'Найдено: ${_filteredProducts.length} ${_getItemsText(_filteredProducts.length)}',
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              if (favoritesCount > 0)
                Text(
                  'В избранном: $favoritesCount',
                  style: const TextStyle(
                    color: Colors.green,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // Список товаров
        Expanded(
          child: _filteredProducts.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search_off,
                        size: 64,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Товары не найдены',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Попробуйте изменить поисковый запрос\nили выбрать другую категорию',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _filteredProducts.length,
                  itemBuilder: (context, index) {
                    final product = _filteredProducts[index];
                    final cartService =
                        Provider.of<CartService>(context, listen: false);

                    return ProductCard(
                      product: product,
                      onTap: () => _navigateToProductDetail(context, product),
                      onFavoriteToggle: () => _toggleFavorite(context, product),
                      isFavorite: _isFavorite(context, product),
                      cartService: cartService, // ← передаём сервис
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
