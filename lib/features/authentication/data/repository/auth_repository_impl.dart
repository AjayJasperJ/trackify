import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/repository/auth_repository.dart';
import '../datasource/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<UserCredential> login(String email, String password) async {
    return await remoteDataSource.login(email, password);
  }

  @override
  Future<UserCredential> register(String name, String email, String password, {String? phone, String? image}) async {
    final credential = await remoteDataSource.register(email, password);
    await remoteDataSource.updateProfile(name, phone: phone, image: image);
    return credential;
  }

  @override
  Future<void> forgotPassword(String email) async {
    await remoteDataSource.forgotPassword(email);
  }

  @override
  Future<void> updatePassword(String currentPassword, String newPassword) async {
    final user = remoteDataSource.currentUser;
    if (user != null && user.email != null) {
      await remoteDataSource.reauthenticate(user.email!, currentPassword);
      await remoteDataSource.updatePassword(newPassword);
    } else {
      throw Exception('User is not logged in.');
    }
  }

  @override
  Stream<User?> get authStateChanges => remoteDataSource.authStateChanges;

  @override
  User? get currentUser => remoteDataSource.currentUser;

  @override
  Future<void> logout() async {
    await remoteDataSource.logout();
  }
}
