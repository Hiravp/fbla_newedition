class AuthService {
  Future<bool> signIn(String username, String password) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return username == 'user' && password == 'pass';
  }

  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 100));
  }
}
