// lib/screens/account_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  // Константы для избежания магических чисел
  static const _defaultPadding = 20.0;
  static const _avatarRadius = 50.0;
  static const _iconSize = 80.0;

  Future<void> _handleSignIn(Future<User?> Function() signInMethod) async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      final user = await signInMethod();
      if (user == null) {
        _showErrorSnackBar('Не удалось войти в аккаунт');
      }
    } catch (e) {
      _showErrorSnackBar('Ошибка при входе: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleSignOut() async {
    setState(() => _isLoading = true);

    try {
      await _authService.signOut();
      _showSuccessSnackBar('Вы успешно вышли из аккаунта');
    } catch (e) {
      _showErrorSnackBar('Ошибка при выходе: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Мой аккаунт'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: StreamBuilder<User?>(
        stream: _authService.userStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingState();
          }

          if (snapshot.hasError) {
            return _buildErrorState(snapshot.error.toString());
          }

          final user = snapshot.data;
          return user == null ? _buildLoginScreen() : _buildProfileScreen(user);
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
          Text(
            'Загрузка...',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(_defaultPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[300],
            ),
            const SizedBox(height: 16),
            const Text(
              'Ошибка загрузки',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _getUserFriendlyError(error),
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => setState(() {}),
              icon: const Icon(Icons.refresh),
              label: const Text('Повторить'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getUserFriendlyError(String error) {
    if (error.contains('network')) {
      return 'Проблемы с подключением к интернету';
    } else if (error.contains('permission')) {
      return 'Недостаточно прав для выполнения операции';
    }
    return error;
  }

  Widget _buildLoginScreen() {
    return Padding(
      padding: const EdgeInsets.all(_defaultPadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_outline,
            size: _iconSize,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 20),
          const Text(
            'Войдите в аккаунт',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text(
            'Чтобы сохранять избранное и историю заказов',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 30),

          // Кнопка входа через Яндекс
          _buildLoginButton(
            'Войти через Яндекс',
            Icons.mail_outline,
            Colors.orange,
            _isLoading
                ? null
                : () => _handleSignIn(_authService.signInWithYandex),
          ),
          const SizedBox(height: 15),

          // Кнопка анонимного входа
          _buildLoginButton(
            'Продолжить без входа',
            Icons.person_outline,
            Colors.grey,
            _isLoading
                ? null
                : () => _handleSignIn(_authService.signInAnonymously),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileScreen(User user) {
    final isAnonymous = user.isAnonymous;
    final userName = user.displayName ??
        (isAnonymous ? 'Анонимный пользователь' : 'Пользователь');
    final userEmail = user.email;

    return Padding(
      padding: const EdgeInsets.all(_defaultPadding),
      child: Column(
        children: [
          // Аватар
          CircleAvatar(
            radius: _avatarRadius,
            backgroundColor: Colors.green[50],
            backgroundImage:
                user.photoURL != null ? NetworkImage(user.photoURL!) : null,
            child: user.photoURL == null
                ? Icon(
                    Icons.person,
                    size: 50,
                    color: Colors.green[600],
                  )
                : null,
          ),
          const SizedBox(height: 20),

          // Имя пользователя
          Text(
            userName,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 5),

          // Email (если не анонимный)
          if (!isAnonymous && userEmail != null) ...[
            Text(
              userEmail,
              style: const TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 5),
          ],

          // Статус анонимного пользователя
          if (isAnonymous)
            Container(
              margin: const EdgeInsets.only(top: 5),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Некоторые функции недоступны',
                style: TextStyle(
                  color: Colors.orange[700],
                  fontSize: 12,
                ),
              ),
            ),

          const SizedBox(height: 30),

          // Информационная карточка
          _buildInfoCard(),
          const Spacer(),

          // Кнопка выхода
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _handleSignOut,
              icon: const Icon(Icons.logout, size: 20),
              label: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Выйти',
                      style: TextStyle(fontSize: 16),
                    ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                disabledBackgroundColor: Colors.red.withOpacity(0.6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginButton(
    String text,
    IconData icon,
    Color color,
    VoidCallback? onPressed,
  ) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: onPressed == null
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Icon(icon, size: 20),
        label: onPressed == null
            ? const Text('Загрузка...')
            : Text(
                text,
                style: const TextStyle(fontSize: 16),
              ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 15),
          disabledBackgroundColor: color.withOpacity(0.6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildInfoRow('Избранные товары', '0', Icons.favorite_border),
            const Divider(height: 20),
            _buildInfoRow('Заказы', '0', Icons.shopping_bag_outlined),
            const Divider(height: 20),
            _buildInfoRow('Бонусы', '0', Icons.card_giftcard),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String title, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.green, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontSize: 16),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
      ],
    );
  }
}
