// File: lib/firebase_options.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      // ВСТАВЬ СВОИ ЗНАЧЕНИЯ ЗДЕСЬ ↓
      return const FirebaseOptions(
        apiKey: "AIzaSyBYOGzfnhcL-6JBO5P7fw3LWP6fwZVWRlM",
        authDomain: "seedshop-68662.firebaseapp.com",
        projectId: "seedshop-68662",
        storageBucket: "seedshop-68662.firebasestorage.app",
        messagingSenderId: "869040939541",
        appId: "1:869040939541:web:6148a44264504f1155641c",
      );
    } else {
      // Конфигурация для Android (использует google-services.json)
      return const FirebaseOptions(
        apiKey: "AIzaSyBYOGzfnhcL-6JBO5P7fw3LWP6fwZVWRlM",
        appId:
            "1:869040939541:android:aaaaaaaaaaaaaaaaaaaaaa", // Это не важно для Android
        messagingSenderId: "869040939541",
        projectId: "seedshop-68662",
        storageBucket: "seedshop-68662.appspot.com",
      );
    }
  }
}
