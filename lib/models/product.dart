// lib/models/product.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String category;
  final bool inStock;
  final int stockCount;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
    required this.inStock,
    required this.stockCount,
  });

  // Конвертация в JSON для Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'category': category,
      'inStock': inStock,
      'stockCount': stockCount,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  // Создание объекта из JSON Firestore
  factory Product.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Product(
      id: data['id'] ?? doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] as num).toDouble(),
      imageUrl: data['imageUrl'] ?? '',
      category: data['category'] ?? '',
      inStock: data['inStock'] ?? true,
      stockCount: (data['stockCount'] as num?)?.toInt() ?? 0,
    );
  }

  // Для совместимости с существующим кодом
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] as num).toDouble(),
      imageUrl: json['imageUrl'] ?? '',
      category: json['category'] ?? '',
      inStock: json['inStock'] ?? true,
      stockCount: (json['stockCount'] as num?)?.toInt() ?? 0,
    );
  }

  Product copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? imageUrl,
    String? category,
    bool? inStock,
    int? stockCount,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      inStock: inStock ?? this.inStock,
      stockCount: stockCount ?? this.stockCount,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Product && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
