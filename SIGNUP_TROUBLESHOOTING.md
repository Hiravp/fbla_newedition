# Signup Troubleshooting Guide

## If Signup Fails

### Step 1: Verify Supabase Project
1. Go to https://app.supabase.com
2. Click on your project: `dsiyyucdnlmangtbjrsi`
3. Check that Auth is enabled:
   - Settings → Authentication → User Signup enabled

### Step 2: Create the Users Table

**Critical**: The `users` table MUST exist in Supabase for profiles to save.

Go to **SQL Editor** in Supabase and run:

```sql
-- Enable UUID extension (if not already enabled)
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create users table
CREATE TABLE IF NOT EXISTS public.users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  email TEXT NOT NULL,
  chapter TEXT DEFAULT 'Local Chapter',
  role TEXT DEFAULT 'Member',
  bio TEXT DEFAULT '',
  profile_image_url TEXT DEFAULT '',
  interests TEXT[] DEFAULT '{}',
  join_date TIMESTAMP DEFAULT NOW(),
  created_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(email)
);

-- Create index on email for faster lookups
CREATE INDEX IF NOT EXISTS users_email_idx ON public.users(email);

-- Enable Row Level Security (RLS)
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

-- Allow users to read their own data
CREATE POLICY "Users can read their own data" ON public.users
  FOR SELECT USING (auth.uid() = id);

-- Allow users to update their own data
CREATE POLICY "Users can update their own data" ON public.users
  FOR UPDATE USING (auth.uid() = id);
```

### Step 3: Check Error Messages

When signup fails, the app shows specific errors:

| Error | Solution |
|-------|----------|
| "Email may already exist" | Email already registered. Try login or use different email. |
| "Supabase is not configured" | Verify URL and API key in `lib/main.dart` are correct. |
| Network error | Check internet connection and Supabase server status. |
| "Database error" | Users table doesn't exist. Run SQL above. |

### Step 4: Verify Credentials

Check `lib/main.dart` has correct Supabase URL and API key:

```dart
await Supabase.initialize(
  url: 'https://dsiyyucdnlmangtbjrsi.supabase.co',  // ✅ Correct
  anonKey: 'sb_publishable_a7HGhZQlo2UV-k4zfPVxvg_2cS52ina',  // ✅ Correct
);
```

### Step 5: Test Signup Flow

1. Run: `flutter run`
2. On Login screen, toggle to "Sign Up"
3. Enter:
   - **Name**: John Doe
   - **Email**: john@example.com
   - **Password**: password123 (6+ chars)
4. Click "Sign Up"
5. Check for error messages

### What Happens During Signup

```
┌─────────────────────────────────────┐
│ User enters: Name, Email, Password  │
└──────────────┬──────────────────────┘
               │
               ▼
    ┌──────────────────────┐
    │ Validate input       │
    │ - Name not empty     │
    │ - Valid email        │
    │ - Password 6+ chars  │
    └──────────┬───────────┘
               │
               ▼
    ┌──────────────────────────────────┐
    │ Supabase Auth Sign Up            │
    │ - Creates user in auth.users     │
    │ - Returns User ID                │
    └──────────┬───────────────────────┘
               │
               ▼
    ┌──────────────────────────────────┐
    │ Insert Profile in public.users   │
    │ - Save name, email, etc.         │
    │ - Link to auth user via ID       │
    └──────────┬───────────────────────┘
               │
               ▼
    ┌──────────────────────────────────┐
    │ Success! Navigate to Home        │
    └──────────────────────────────────┘
```

If signup stops at any step, an error is shown.

### Common Issues & Fixes

**Issue**: "User already exists"
- **Cause**: Email already registered
- **Fix**: Use different email or login with existing account

**Issue**: "Database error" or blank error
- **Cause**: Users table doesn't exist
- **Fix**: Run SQL script in Step 2 above

**Issue**: Signup succeeds but doesn't navigate to home
- **Cause**: Session not properly loaded
- **Fix**: Restart app, try login instead

**Issue**: Can signup but can't login
- **Cause**: Auth and DB out of sync
- **Fix**: Delete users table, recreate, signup again

### Debug Mode

To see detailed errors, check the terminal where `flutter run` is executing. Look for lines starting with:
```
Login error:
Signup error:
Database insert error:
```

Copy the full error message and search for solutions.

### Manual Testing in Supabase

1. Go to **SQL Editor** in Supabase
2. Run: `SELECT * FROM public.users;`
3. Check if your user appears in the table after signup

### If Nothing Works

1. **Verify table exists**: Query the users table in Supabase SQL Editor
2. **Check RLS policies**: Settings → Authentication → Policies
3. **Review auth settings**: Settings → Authentication → Email & Password
4. **Test auth API directly**:

```bash
curl -X POST 'https://dsiyyucdnlmangtbjrsi.supabase.co/auth/v1/signup' \
  -H 'apikey: sb_publishable_a7HGhZQlo2UV-k4zfPVxvg_2cS52ina' \
  -H 'Content-Type: application/json' \
  -d '{
    "email": "test@example.com",
    "password": "password123"
  }'
```

---

**Status**: Signup now has better error messages and validation  
**Last Updated**: January 18, 2026
