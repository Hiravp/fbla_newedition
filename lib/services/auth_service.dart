import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user.dart' as fbla_user;

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;
  fbla_user.User? _currentUser;

  Future<void> init() async {
    await _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    final session = _supabase.auth.currentSession;
    if (session == null) return;

    final data = await _supabase
        .from('users')
        .select()
        .eq('id', session.user.id)
        .single();

    _currentUser = fbla_user.User.fromJson(data);
  }

  fbla_user.User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  // ---------------- LOGIN ----------------
  Future<bool> login(String email, String password) async {
    final response = await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );

    if (response.user == null) return false;

    final data = await _supabase
        .from('users')
        .select()
        .eq('id', response.user!.id)
        .single();

    _currentUser = fbla_user.User.fromJson(data);
    return true;
  }

  // ---------------- SIGN UP ----------------
  Future<bool> signup(String name, String email, String password) async {
    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
      data: {
        'full_name': name, // 🔥 REQUIRED FOR TRIGGER
      },
    );

    if (response.user == null) return false;

    // ⛔ DO NOT INSERT INTO users TABLE HERE
    // Trigger already handled it

    final data = await _supabase
        .from('users')
        .select()
        .eq('id', response.user!.id)
        .single();

    _currentUser = fbla_user.User.fromJson(data);
    return true;
  }

  // ---------------- LOGOUT ----------------
  Future<void> logout() async {
    await _supabase.auth.signOut();
    _currentUser = null;
  }

  // ---------------- UPDATE PROFILE ----------------
  Future<void> updateProfile(fbla_user.User user) async {
    await _supabase.from('users').update(user.toJson()).eq('id', user.id);
    _currentUser = user;
  }
}
