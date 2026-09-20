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
  bool login(String email, String password) {
    if (email.trim().toLowerCase() == 'admin@ecomes.com' && password == 'admin123') {
      _currentUser = UserSession(
        name: 'Angga Wijaya',
        email: 'admin@ecomes.com',
        role: 'Super Admin',
        avatar: 'https://picsum.photos/seed/admin/100/100',
        token: 'session-${DateTime.now().millisecondsSinceEpoch}',
      );
      _saveSession();
      return true;
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
