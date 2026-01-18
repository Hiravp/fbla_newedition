# Signup Fix - Local Testing & Workaround

## Issue Found

The signup is failing with a **socket connection error** to Supabase. This typically means:

1. **Network connectivity issue** - macOS/device can't reach supabase.co
2. **Firewall/proxy blocking** - Corporate network may block the connection
3. **Development environment issue** - Local testing limitations

## Quick Fix: Enable Local/Demo Mode

For testing and development without real Supabase connection, use this:

### Option 1: Use Test Credentials (No Real Signup)

Edit `lib/services/auth_service.dart` - replace signup method:

```dart
Future<bool> signup(String name, String email, String password) async {
  try {
    // For testing: accept signup without real Supabase
    // In production, remove this and use real Supabase
    
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    // Simple validation
    if (email.isEmpty || !email.contains('@')) return false;
    if (password.length < 6) return false;
    
    // Create test user
    final user = fbla_user.User(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      email: email,
      chapter: 'Test Chapter',
    );
    
    _currentUser = user;
    print('Demo signup successful for: $email');
    return true;
  } catch (e) {
    print('Signup error: $e');
    return false;
  }
}
```

### Option 2: Try Real Supabase (For Production)

If you want to use real Supabase:

1. **Restart your computer** (sometimes helps with socket issues)
2. **Check internet connection** - verify you can reach https://supabase.com
3. **Update pubspec.yaml** - ensure supabase_flutter is latest:
   ```yaml
   supabase_flutter: ^2.5.0
   ```
4. **Run `flutter clean`**:
   ```bash
   cd /Users/manish/fbla_newedition
   flutter clean
   flutter pub get
   flutter run
   ```

### Option 3: Use Supabase Emulator (Advanced)

For local development without internet:

```bash
# Install Supabase CLI
brew install supabase/tap/supabase

# Start local Supabase
supabase start

# Update credentials in lib/main.dart to use localhost
```

## Recommended Approach for Now

Use **Option 1** (test/demo mode) for development, then switch to **Option 2** (real Supabase) for production.

### Implementation Steps

1. **Open** `lib/services/auth_service.dart`
2. **Replace** the `signup()` method with the test version above
3. **Do same for `login()`**:

```dart
Future<bool> login(String email, String password) async {
  try {
    // For testing: simple password check
    await Future.delayed(const Duration(seconds: 1));
    
    if (email.isEmpty || password.isEmpty) return false;
    
    // In real app, query Supabase for user
    // For demo, create test user
    final user = fbla_user.User(
      id: email.hashCode.toString(),
      name: email.split('@')[0],
      email: email,
      chapter: 'Test Chapter',
    );
    
    _currentUser = user;
    print('Demo login successful for: $email');
    return true;
  } catch (e) {
    print('Login error: $e');
    return false;
  }
}
```

4. **Test signup**:
   ```bash
   flutter run
   # Try signup with any email/password
   # Should work without Supabase
   ```

5. **Later switch to real Supabase** when network is available

---

## What Happens With Demo Mode

✅ **Works Offline**
- Sign up with any email
- Login with any email/password
- Profile editing works
- Calendar/News show mock data
- AI chat works

❌ **Doesn't Persist**
- Data lost on app restart (use SharedPreferences if needed)
- No real user database
- Multiple devices won't sync

---

## Production Switch Checklist

When you're ready for real Supabase:

- [ ] Supabase project created and verified
- [ ] Users table created with SQL schema
- [ ] Auth enabled in Supabase settings
- [ ] Use `signUpWithPassword()` method
- [ ] Remove test/demo code
- [ ] Test on real device/network
- [ ] Deploy to stores

---

**Current Issue**: Network connectivity to Supabase  
**Workaround**: Use demo/test mode for development  
**Status**: App functional with local testing  
**Last Updated**: January 18, 2026
