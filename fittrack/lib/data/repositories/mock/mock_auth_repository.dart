import 'package:shared_preferences/shared_preferences.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/repositories/i_auth_repository.dart';

class MockAuthRepository implements IAuthRepository {
  User? _currentUser;

  @override
  Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('auth_user_id');
    final email = prefs.getString('auth_email');
    if (userId != null && email != null) {
      _currentUser = User(id: userId, email: email, createdAt: DateTime.now());
    }
    return _currentUser;
  }

  @override
  Future<User> signInWithEmailAndPassword(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    _currentUser = User(id: '123', email: email, createdAt: DateTime.now());
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_user_id', '123');
    await prefs.setString('auth_email', email);
    return _currentUser!;
  }

  @override
  Future<User> signUpWithEmailAndPassword(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    _currentUser = User(id: '123', email: email, createdAt: DateTime.now());
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_user_id', '123');
    await prefs.setString('auth_email', email);
    return _currentUser!;
  }

  @override
  Future<void> signOut() async {
    await Future.delayed(const Duration(seconds: 1));
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_user_id');
    await prefs.remove('auth_email');
    _currentUser = null;
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await Future.delayed(const Duration(seconds: 1));
  }

  @override
  Future<bool> verifyPasswordResetCode(String code) async {
    await Future.delayed(const Duration(seconds: 1));
    return code == '123456';
  }

  @override
  Future<void> confirmPasswordReset(String code, String newPassword) async {
    await Future.delayed(const Duration(seconds: 1));
  }
}
