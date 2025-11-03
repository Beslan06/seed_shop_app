import '../models/product.dart';

class MockData {
  static final List<Product> products = [
    Product(
      id: '1',
      name: 'Томат Бычье сердце',
      description:
          'Крупноплодный сорт томатов для открытого грунта и теплиц. Плоды мясистые, сладкие, массой до 500 г.',
      price: 45.0,
      imageUrl: 'assets/images/tomato.png',
      category: 'Овощи',
      inStock: true,
      stockCount: 50,
    ),
    Product(
      id: '2',
      name: 'Огурец Зозуля',
      description:
          'Скороспелый партенокарпический гибрид для защищенного грунта. Устойчив к болезням.',
      price: 35.0,
      imageUrl: 'assets/images/cucumber.png',
      category: 'Овощи',
      inStock: true,
      stockCount: 30,
    ),
    Product(
      id: '3',
      name: 'Морковь Нантская',
      description:
          'Среднеранний сорт с цилиндрическими корнеплодами ярко-оранжевого цвета. Отличные вкусовые качества.',
      price: 25.0,
      imageUrl: 'assets/images/carrot.png',
      category: 'Овощи',
      inStock: true,
      stockCount: 40,
    ),
    Product(
      id: '4',
      name: 'Салат Латук',
      description:
          'Листовой салат с нежными хрустящими листьями. Быстро растет и богат витаминами.',
      price: 28.0,
      imageUrl: 'assets/images/lettuce.png',
      category: 'Зелень',
      inStock: true,
      stockCount: 25,
    ),
    Product(
      id: '5',
      name: 'Перец сладкий',
      description:
          'Крупноплодный сладкий перец для теплиц и открытого грунта. Плоды толстостенные, ароматные.',
      price: 55.0,
      imageUrl: 'assets/images/pepper.png',
      category: 'Овощи',
      inStock: true,
      stockCount: 20,
    ),
    Product(
      id: '6',
      name: 'Редис Французский',
      description:
          'Скороспелый сорт с округлыми ярко-красными корнеплодами. Мякоть сочная, без горечи.',
      price: 22.0,
      imageUrl: 'assets/images/radish.png',
      category: 'Овощи',
      inStock: true,
      stockCount: 35,
    ),
    Product(
      id: '7',
      name: 'Подсолнух декоративный',
      description:
          'Яркие солнечные цветы для украшения сада. Высота растений до 1.5 метров.',
      price: 40.0,
      imageUrl: 'assets/images/sunflower.png',
      category: 'Цветы',
      inStock: true,
      stockCount: 15,
    ),
    Product(
      id: '8',
      name: 'Набор семян "Стартовый"',
      description:
          'Идеальный набор для начинающего садовода. Включает основные культуры для огорода.',
      price: 150.0,
      imageUrl: 'assets/images/seed.png',
      category: 'Наборы',
      inStock: true,
      stockCount: 10,
    ),
  ];

  static List<String> get categories {
    return products.map((product) => product.category).toSet().toList();
  }

  static List<Product> getProductsByCategory(String category) {
    return products.where((product) => product.category == category).toList();
  }
}
