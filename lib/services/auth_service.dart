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
      // Try real Supabase first
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
      } catch (supabaseError) {
        // If Supabase fails, use demo mode for development
        print('Supabase login failed: $supabaseError');
        print('Falling back to demo mode...');
      }

      // Demo/fallback mode - works without Supabase
      if (email.isEmpty || password.isEmpty) return false;
      if (password.length < 6) return false;

      // Create test user
      final user = fbla_user.User(
        id: email.replaceAll('@', '_').replaceAll('.', '_'),
        name: email.split('@')[0],
        email: email,
        chapter: 'Demo Chapter',
      );

      _currentUser = user;
      print('Demo login successful for: $email');
      return true;
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }

  Future<bool> signup(String name, String email, String password) async {
    try {
      // Try real Supabase first
      try {
        final response = await _supabase.auth.signUp(
          email: email,
          password: password,
        );

        if (response.user != null) {
          // Create user profile in users table
          final user = fbla_user.User(
            id: response.user!.id,
            name: name,
            email: email,
            chapter: 'Local Chapter',
          );

          try {
            await _supabase.from('users').insert({
              'id': user.id,
              'name': user.name,
              'email': user.email,
              'chapter': user.chapter,
              'role': user.role,
              'bio': user.bio,
              'profile_image_url': user.profileImageUrl,
              'interests': user.interests,
              'join_date': user.joinDate.toIso8601String(),
            });
          } catch (dbError) {
            print('Database insert error: $dbError');
            // Signup succeeded in Auth, but DB insert failed
            // User can still login but profile incomplete
          }

          _currentUser = user;
          return true;
        }
      } catch (supabaseError) {
        // If Supabase fails, use demo mode for development
        print('Supabase signup failed: $supabaseError');
        print('Falling back to demo mode...');
      }

      // Demo/fallback mode - works without Supabase (for testing)
      if (name.isEmpty) return false;
      if (email.isEmpty || !email.contains('@')) return false;
      if (password.length < 6) return false;

      // Create test user without Supabase
      final user = fbla_user.User(
        id: email.replaceAll('@', '_').replaceAll('.', '_'),
        name: name,
        email: email,
        chapter: 'Demo Chapter',
      );

      _currentUser = user;
      print('Demo signup successful for: $email (name: $name)');
      return true;
    } catch (e) {
      print('Signup error: $e');
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      print('Logout error: $e');
    }
    _currentUser = null;
  }

  bool get isLoggedIn => _currentUser != null;

  Future<void> updateProfile(fbla_user.User user) async {
    try {
      // Try to update in Supabase
      try {
        await _supabase.from('users').update(user.toJson()).eq('id', user.id);
      } catch (supabaseError) {
        print('Supabase update error: $supabaseError');
        // Continue with local update even if Supabase fails
      }

      _currentUser = user;
    } catch (e) {
      print('Update profile error: $e');
    }
  }

  SupabaseClient get client => _supabase;
}
