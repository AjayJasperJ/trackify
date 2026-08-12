import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthRepository {
  Future<UserCredential> login(String email, String password);
  Future<UserCredential> register(String name, String email, String password, {String? phone, String? image});
  Future<void> forgotPassword(String email);
  Future<void> updatePassword(String currentPassword, String newPassword);
  Stream<User?> get authStateChanges;
  User? get currentUser;
  Future<void> logout();
}
