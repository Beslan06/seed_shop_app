class AuthConfig {
  // Яндекс OAuth настройки
  static const String yandexClientId = '744371f78ec649ac84e0fac255580b26';
  static const String yandexClientSecret = '8c2ca5becea3403482890d05b885788f';
  // Используем custom scheme вместо http://localhost
  static const String yandexRedirectUri = 'seedapp://auth/yandex/callback';

  static const List<String> yandexScopes = [
    'login:email',
    'login:info',
  ];

  // Google OAuth настройки
  static const List<String> googleScopes = [
    'email',
    'profile',
  ];
}
