import '../entities/user.dart';

abstract class IAuthRepository {
  /// Signs in a user with email and password
  Future<User> signInWithEmailAndPassword(String email, String password);

  /// Registers a new user with email and password
  Future<User> signUpWithEmailAndPassword(String email, String password);

  /// Signs out the currently authenticated user
  Future<void> signOut();

  /// Gets the currently authenticated user
  Future<User?> getCurrentUser();

  /// Sends a password reset email
  Future<void> sendPasswordResetEmail(String email);
  
  /// Verifies a password reset code
  Future<bool> verifyPasswordResetCode(String code);

  /// Sets a new password using a reset code
  Future<void> confirmPasswordReset(String code, String newPassword);
}
