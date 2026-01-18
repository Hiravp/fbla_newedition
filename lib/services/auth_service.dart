import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import 'dart:convert';

class AuthService {
  static const String _userKey = 'fbla_user';
  late SharedPreferences _prefs;
  User? _currentUser;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _loadUser();
  }

  void _loadUser() {
    final userJson = _prefs.getString(_userKey);
    if (userJson != null) {
      _currentUser = User.fromJson(jsonDecode(userJson));
    }
  }

  User? get currentUser => _currentUser;

  Future<bool> login(String email, String password) async {
    try {
      // Simulated login - in production, connect to Firebase/backend
      if (email.isNotEmpty && password.length >= 6) {
        final user = User(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: email.split('@')[0],
          email: email,
          chapter: 'Local Chapter',
        );
        _currentUser = user;
        await _prefs.setString(_userKey, jsonEncode(user.toJson()));
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> signup(String name, String email, String password) async {
    try {
      if (name.isNotEmpty && email.isNotEmpty && password.length >= 6) {
        final user = User(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: name,
          email: email,
          chapter: 'Local Chapter',
        );
        _currentUser = user;
        await _prefs.setString(_userKey, jsonEncode(user.toJson()));
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<void> logout() async {
    _currentUser = null;
    await _prefs.remove(_userKey);
  }

  bool get isLoggedIn => _currentUser != null;

  Future<void> updateProfile(User user) async {
    _currentUser = user;
    await _prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  Future<bool> signIn(String username, String password) async {
    return login(username, password);
  }

  Future<void> signOut() async {
    await logout();
  }
}
