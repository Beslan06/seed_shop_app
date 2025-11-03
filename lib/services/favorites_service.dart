// lib/services/favorites_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/product.dart';

class FavoritesService with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Product> _favorites = [];
  bool _isLoading = false;

  List<Product> get favorites => _favorites;
  bool get isLoading => _isLoading;

  // Получить коллекцию избранного для текущего пользователя
  CollectionReference? get _favoritesCollection {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return null;
    return _firestore.collection('users').doc(userId).collection('favorites');
  }

  // Проверка авторизации
  bool get isUserAuthenticated => _auth.currentUser != null;

  // Загрузить избранное
  Future<void> loadFavorites() async {
    if (_auth.currentUser == null) {
      _favorites = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await _favoritesCollection!.get();
      _favorites =
          snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
      print('✅ Загружено ${_favorites.length} избранных товаров');
    } catch (e) {
      print('❌ Ошибка загрузки избранного: $e');
      _favorites = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Стрим для реального обновления
  Stream<List<Product>> getFavoritesStream() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return Stream.value([]);

    return _firestore
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList());
  }

  // Добавить товар в избранное
  Future<bool> addToFavorites(Product product) async {
    if (!isUserAuthenticated) {
      print('❌ Пользователь не авторизован для добавления в избранное');
      return false;
    }

    try {
      await _favoritesCollection!.doc(product.id).set(product.toJson());
      print('✅ Товар добавлен в избранное: ${product.name}');

      // Обновляем локальный список
      await loadFavorites();
      return true;
    } catch (e) {
      print('❌ Ошибка добавления в избранное: $e');
      return false;
    }
  }

  // Удалить товар из избранного
  Future<bool> removeFromFavorites(String productId) async {
    if (!isUserAuthenticated) {
      print('❌ Пользователь не авторизован для удаления из избранного');
      return false;
    }

    try {
      await _favoritesCollection!.doc(productId).delete();
      print('✅ Товар удален из избранного: $productId');

      // Обновляем локальный список
      await loadFavorites();
      return true;
    } catch (e) {
      print('❌ Ошибка удаления из избранного: $e');
      return false;
    }
  }

  // Переключить избранное
  Future<void> toggleFavorite(Product product) async {
    if (!isUserAuthenticated) {
      print('❌ Пользователь не авторизован');
      return;
    }

    final isCurrentlyFavorite = _favorites.any((p) => p.id == product.id);

    if (isCurrentlyFavorite) {
      await removeFromFavorites(product.id);
    } else {
      await addToFavorites(product);
    }
  }

  // Проверить, есть ли товар в избранном
  bool isFavorite(String productId) {
    if (!isUserAuthenticated) return false;
    return _favorites.any((product) => product.id == productId);
  }

  // Очистить все избранное
  Future<void> clearFavorites() async {
    if (!isUserAuthenticated) return;

    try {
      final batch = _firestore.batch();
      final snapshot = await _favoritesCollection!.get();

      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      _favorites = [];
      notifyListeners();
      print('✅ Избранное очищено');
    } catch (e) {
      print('❌ Ошибка очистки избранного: $e');
    }
  }

  // Получить количество избранных товаров
  int get favoritesCount => _favorites.length;
}
