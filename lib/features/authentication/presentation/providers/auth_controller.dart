import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:ims_scanner_app/features/authentication/data/local/auth_session_storage.dart';
import 'package:ims_scanner_app/features/authentication/data/local/branch_selection_storage.dart';
import 'package:ims_scanner_app/features/authentication/data/repositories/auth_repository.dart';
import 'package:ims_scanner_app/features/authentication/presentation/providers/auth_state.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) => AuthRepository());

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>(
  (ref) => AuthController(ref.read(authRepositoryProvider)),
);

class AuthController extends StateNotifier<AuthState> {
  AuthController(this._repo) : super(AuthState.initial);
  final AuthRepository _repo;

  Future<bool> signIn(String userId, String password) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    try {
      await _repo.login(userId: userId, password: password);
      final profile = await _repo.fetchMe();
      await AuthSessionStorage.saveUserId(profile.userId);
      state = state.copyWith(
        status: AuthStatus.authenticated,
        errorMessage: null,
        user: profile,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: _mapLoginError(e),
        clearUser: true,
      );
      return false;
    }
  }

  String _mapLoginError(Object e) {
    if (e is DioException) {
      final status = e.response?.statusCode;
      final data = e.response?.data;
      if (data is Map && data['message'] is String) return data['message'] as String;
      if (status == 401) return 'Invalid username or password.';
      if (status == 503) return 'Authentication server is unavailable.';
      if (e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionTimeout) {
        return 'Server timeout. Please try again.';
      }
      return 'Cannot connect to server.';
    }
    if (e is Exception) {
      final raw = e.toString();
      return raw.replaceFirst('Exception: ', '').trim();
    }
    return 'Login failed. Please try again.';
  }

  Future<void> restoreSession() async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    try {
      final profile = await _repo.fetchMe();
      await AuthSessionStorage.saveUserId(profile.userId);
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: profile,
      );
      return;
    } catch (_) {
      // cleanup below
    }

    await AuthSessionStorage.clear();
    await BranchSelectionStorage.clear();
    state = state.copyWith(
      status: AuthStatus.unauthenticated,
      clearUser: true,
    );
  }

  Future<void> signOut() async {
    try {
      await _repo.logout();
    } catch (_) {
      // ignore network/logout API issues and continue local signout cleanup
    }
    await AuthSessionStorage.clear();
    await BranchSelectionStorage.clear();
    state = state.copyWith(
      status: AuthStatus.unauthenticated,
      errorMessage: null,
      clearUser: true,
    );
  }
}
