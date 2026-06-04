import 'package:equatable/equatable.dart';
import 'package:orbit_app/features/authentication/domain/entities/user_entity.dart';

/// Session status used to drive route guards.
enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthState extends Equatable {
  const AuthState({
    this.status = AuthStatus.unknown,
    this.user,
    this.isSubmitting = false,
    this.errorMessage,
  });

  const AuthState.unknown() : this();

  final AuthStatus status;
  final UserEntity? user;

  /// True while a login / Google / logout action is in flight (button spinner).
  final bool isSubmitting;

  /// Non-null when the last action failed; shown in the form's error banner.
  final String? errorMessage;

  bool get isAuthenticated => status == AuthStatus.authenticated;

  AuthState copyWith({
    AuthStatus? status,
    UserEntity? user,
    bool? isSubmitting,
    String? errorMessage,
    bool clearError = false,
    bool clearUser = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: clearUser ? null : (user ?? this.user),
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [status, user, isSubmitting, errorMessage];
}
