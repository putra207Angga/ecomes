// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter
import 'dart:convert';
import 'dart:html' as html;
import '../models/app_models.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal() {
    _loadSession();
  }

  UserSession? _currentUser;

  UserSession? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  void _loadSession() {
    try {
      final sessionStr = html.window.localStorage['ecomes_session'];
      if (sessionStr != null && sessionStr.isNotEmpty) {
        _currentUser = UserSession.fromJson(jsonDecode(sessionStr));
      } else {
        _currentUser = null;
      }
    } catch (e) {
      _currentUser = null;
    }
  }

  void _saveSession() {
    if (_currentUser != null) {
      html.window.localStorage['ecomes_session'] = jsonEncode(_currentUser!.toJson());
    } else {
      html.window.localStorage.remove('ecomes_session');
    }
  }

  // Credentials diambil dari file .akun (lihat .akun di root project)
  // Daftar user harus sinkron dengan isi .akun
  static const List<Map<String, String>> _users = [
    {
      'name': 'Angga Wijaya',
      'email': 'admin@ecomes.com',
      'password': 'admin123',
      'role': 'Super Admin',
      'avatar': 'https://picsum.photos/seed/admin/100/100',
    },
    {
      'name': 'Budi Kurniawan',
      'email': 'manager@ecomes.com',
      'password': 'manager123',
      'role': 'Store Manager',
      'avatar': 'https://picsum.photos/seed/manager/100/100',
    },
    {
      'name': 'Siti Aminah',
      'email': 'cs@ecomes.com',
      'password': 'cs123',
      'role': 'CS Support',
      'avatar': 'https://picsum.photos/seed/cs/100/100',
    },
  ];

  bool login(String email, String password) {
    for (final user in _users) {
      if (user['email']!.toLowerCase() == email.trim().toLowerCase() &&
          user['password'] == password) {
        _currentUser = UserSession(
          name: user['name']!,
          email: user['email']!,
          role: user['role']!,
          avatar: user['avatar']!,
          token: 'session-${DateTime.now().millisecondsSinceEpoch}',
        );
        _saveSession();
        return true;
      }
    }
    return false;
  }

  void logout() {
    _currentUser = null;
    _saveSession();
  }

  void updateProfile(String name, String email, String avatar) {
    if (_currentUser != null) {
      _currentUser!.name = name;
      _currentUser!.email = email;
      if (avatar.isNotEmpty) _currentUser!.avatar = avatar;
      _saveSession();
    }
  }
}
