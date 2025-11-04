// lib/services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/auth_config.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;

  Stream<User?> get userStream => _auth.authStateChanges();

  // Анонимный вход
  Future<User?> signInAnonymously() async {
    if (_isLoading) return null;
    _isLoading = true;

    try {
      final userCredential = await _auth.signInAnonymously();
      print('✅ Анонимный вход успешен: ${userCredential.user?.uid}');
      return userCredential.user;
    } catch (e) {
      print('❌ Ошибка анонимного входа: $e');
      return null;
    } finally {
      _isLoading = false;
    }
  }

  // Вход через Яндекс
  Future<User?> signInWithYandex() async {
    if (_isLoading) return null;
    _isLoading = true;

    try {
      print('🔄 Начинаем вход через Яндекс...');

      final authCode = await _getYandexAuthCode();
      if (authCode == null) return null;

      final accessToken = await _exchangeYandexCodeForToken(authCode);
      if (accessToken == null) return null;

      final userInfo = await _getYandexUserInfo(accessToken);
      if (userInfo == null) return null;

      print(
          '✅ Яндекс пользователь: ${userInfo['login']} (${userInfo['email']})');

      // Для простоты — временно анонимный вход
      final userCredential = await _auth.signInAnonymously();
      if (userInfo['real_name'] != null) {
        await userCredential.user?.updateDisplayName(userInfo['real_name']);
      }

      return userCredential.user;
    } catch (e) {
      print('❌ Ошибка входа через Яндекс: $e');
      print('🔄 Используем анонимный вход вместо Яндекс');
      return await signInAnonymously();
    } finally {
      _isLoading = false;
    }
  }

  Future<String?> _getYandexAuthCode() async {
    try {
      final authUrl = Uri.https('oauth.yandex.ru', '/authorize', {
        'response_type': 'code',
        'client_id': AuthConfig.yandexClientId,
        'redirect_uri': AuthConfig.yandexRedirectUri,
        'scope': AuthConfig.yandexScopes.join(' '),
        'display': 'popup',
      });

      print('🔗 Открываем OAuth: $authUrl');

      // Используем схему "seedapp" — без "://", только имя схемы
      final result = await FlutterWebAuth2.authenticate(
        url: authUrl.toString(),
        callbackUrlScheme: 'seedapp',
      );

      final code = Uri.parse(result).queryParameters['code'];
      print('✅ Код авторизации: ${code != null ? 'получен' : 'не получен'}');
      return code;
    } catch (e) {
      print('❌ Ошибка получения кода Яндекс: $e');
      return null;
    }
  }

  Future<String?> _exchangeYandexCodeForToken(String authCode) async {
    try {
      // УБРАЛ ПРОБЕЛЫ В КОНЦЕ URL!
      final response = await http.post(
        Uri.parse('https://oauth.yandex.ru/token'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'grant_type': 'authorization_code',
          'code': authCode,
          'client_id': AuthConfig.yandexClientId,
          'client_secret': AuthConfig.yandexClientSecret,
        },
      );

      print('🔁 Ответ от Яндекс: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final accessToken = data['access_token'];
        print('✅ Access token получен');
        return accessToken;
      } else {
        print(
            '❌ Ошибка обмена кода: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('❌ Ошибка обмена кода на токен: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> _getYandexUserInfo(String accessToken) async {
    try {
      // УБРАЛ ПРОБЕЛЫ В КОНЦЕ URL!
      final response = await http.get(
        Uri.parse('https://login.yandex.ru/info'),
        headers: {'Authorization': 'OAuth $accessToken'},
      );

      if (response.statusCode == 200) {
        final userInfo = json.decode(response.body);
        print('📧 Яндекс пользователь: ${userInfo['login']}');
        return userInfo;
      } else {
        print('❌ Ошибка получения информации: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('❌ Ошибка получения информации пользователя: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    if (_isLoading) return;
    _isLoading = true;

    try {
      await _auth.signOut();
      print('✅ Выход выполнен успешно');
    } catch (e) {
      print('❌ Ошибка выхода: $e');
      rethrow;
    } finally {
      _isLoading = false;
    }
  }

  User? get currentUser => _auth.currentUser;
  bool get isLoading => _isLoading;
}
