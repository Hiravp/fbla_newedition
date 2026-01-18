import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user.dart' as fbla_user;

class AuthService {
  late final SupabaseClient _supabase;
  fbla_user.User? _currentUser;

  Future<void> init() async {
    await Supabase.initialize(
      url: 'https://dsiyyucdnlmangtbjrsi.supabase.co',
      anonKey: 'sb_publishable_a7HGhZQlo2UV-k4zfPVxvg_2cS52ina',
    );
    _supabase = Supabase.instance.client;
    await _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    final session = _supabase.auth.currentSession;
    if (session != null) {
      try {
        final response = await _supabase
            .from('users')
            .select()
            .eq('id', session.user.id)
            .single();
        _currentUser = fbla_user.User.fromJson(response);
      } catch (e) {
        _currentUser = null;
      }
    }
  }

  fbla_user.User? get currentUser => _currentUser;

  Future<bool> login(String email, String password) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        final userData = await _supabase
            .from('users')
            .select()
            .eq('id', response.user!.id)
            .single();
        _currentUser = fbla_user.User.fromJson(userData);
        return true;
      }
      return false;
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }

  Future<bool> signup(String name, String email, String password) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user != null) {
        final user = fbla_user.User(
          id: response.user!.id,
          name: name,
          email: email,
          chapter: 'Local Chapter',
        );

        await _supabase.from('users').insert(user.toJson());
        _currentUser = user;
        return true;
      }
      return false;
    } catch (e) {
      print('Signup error: $e');
      return false;
    }
  }

  Future<void> logout() async {
    await _supabase.auth.signOut();
    _currentUser = null;
  }

  bool get isLoggedIn => _currentUser != null && _supabase.auth.currentSession != null;

  Future<void> updateProfile(fbla_user.User user) async {
    try {
      await _supabase.from('users').update(user.toJson()).eq('id', user.id);
      _currentUser = user;
    } catch (e) {
      print('Update profile error: $e');
    }
  }

  SupabaseClient get client => _supabase;
}
