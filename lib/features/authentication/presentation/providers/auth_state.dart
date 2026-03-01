import 'package:ims_scanner_app/features/authentication/domain/models/auth_user.dart';

enum AuthStatus { unauthenticated, loading, authenticated }

class AuthState {
  const AuthState({
    required this.status,
    this.errorMessage,
    this.user,
  });

  final AuthStatus status;
  final String? errorMessage;
  final AuthUser? user;

  bool get isAuthenticated => status == AuthStatus.authenticated;
  String? get userId => user?.userId;

  AuthState copyWith({
    AuthStatus? status,
    String? errorMessage,
    AuthUser? user,
    bool clearUser = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      errorMessage: errorMessage,
      user: clearUser ? null : (user ?? this.user),
    );
  }

  static const initial = AuthState(status: AuthStatus.unauthenticated);
}
