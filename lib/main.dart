import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'screens/home_screen.dart';
import 'services/cart_service.dart';
import 'services/favorites_service.dart'; // ДОБАВЛЕНО
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase подключен успешно!');

    // ДАВАЙ ПРОВЕРИМ ЗАПИСЬ В FIRESTORE
    await _testFirestoreConnection();
  } catch (e) {
    print('❌ Ошибка Firebase: $e');
  }

  runApp(const MyApp());
}

// Функция для тестирования Firestore
Future<void> _testFirestoreConnection() async {
  try {
    // Ждем немного чтобы Firebase полностью инициализировался
    await Future.delayed(const Duration(seconds: 1));

    // Записываем тестовые данные
    await FirebaseFirestore.instance
        .collection('test_app')
        .doc('connection_test')
        .set({
      'message': 'Привет! Firestore работает! 🎉',
      'app_name': 'Seed Shop',
      'created_at': FieldValue.serverTimestamp(),
    });

    print('✅ Тестовые данные записаны в Firestore!');
    print('📱 Проверь в Firebase Console → Firestore → Data');
  } catch (e) {
    print('❌ Ошибка записи в Firestore: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      // ИЗМЕНЕНО: ChangeNotifierProvider на MultiProvider
      providers: [
        ChangeNotifierProvider(create: (context) => CartService()),
        ChangeNotifierProvider(
            create: (context) => FavoritesService()), // ДОБАВЛЕНО
      ],
      child: MaterialApp(
        title: 'Магазин семян "Урожай"',
        theme: ThemeData(
          primarySwatch: Colors.green,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          fontFamily: 'Roboto',
        ),
        home: const HomeScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
