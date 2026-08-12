import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../domain/repository/auth_repository.dart';
import 'auth_provider.dart';

class AuthController extends StateNotifier<AsyncValue<void>> {
  final AuthRepository _authRepository;

  AuthController(this._authRepository) : super(const AsyncValue.data(null));
  
  User? get currentUser => _authRepository.currentUser;

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      await _authRepository.login(email, password);
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> register(String name, String email, String password, {String? phone, String? image}) async {
    state = const AsyncValue.loading();
    try {
      await _authRepository.register(name, email, password, phone: phone, image: image);
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> forgotPassword(String email) async {
    state = const AsyncValue.loading();
    try {
      await _authRepository.forgotPassword(email);
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> updatePassword(String currentPassword, String newPassword) async {
    state = const AsyncValue.loading();
    try {
      await _authRepository.updatePassword(currentPassword, newPassword);
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> logout() async {
    state = const AsyncValue.loading();
    try {
      await _authRepository.logout();
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}

final authControllerProvider = StateNotifierProvider<AuthController, AsyncValue<void>>((ref) {
  return AuthController(ref.watch(authRepositoryProvider));
});
