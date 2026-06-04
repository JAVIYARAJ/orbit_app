import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:orbit_app/features/authentication/domain/entities/user_entity.dart';
import 'package:orbit_app/features/authentication/domain/repositories/auth_repository.dart';
import 'package:orbit_app/features/authentication/domain/usecases/get_current_user_use_case.dart';
import 'package:orbit_app/features/authentication/domain/usecases/login_use_case.dart';
import 'package:orbit_app/features/authentication/domain/usecases/login_with_google_use_case.dart';
import 'package:orbit_app/features/authentication/domain/usecases/logout_use_case.dart';
import 'package:orbit_app/features/authentication/presentation/state/auth_state.dart';

/// Owns the authentication state for the whole app and exposes the login,
/// Google, and logout actions used by the UI.
class AuthCubit extends Cubit<AuthState> {
  AuthCubit({
    required LoginUseCase login,
    required LoginWithGoogleUseCase loginWithGoogle,
    required LogoutUseCase logout,
    required GetCurrentUserUseCase getCurrentUser,
    required AuthRepository repository,
  })  : _login = login,
        _loginWithGoogle = loginWithGoogle,
        _logout = logout,
        _getCurrentUser = getCurrentUser,
        super(const AuthState.unknown()) {
    // React to session changes from any source — password login, OAuth
    // deep-link return, token refresh, or sign-out.
    _authSub = repository.authStateChanges.listen(_onAuthChanged);
    // Seed from any restored session in case the stream's initial event fired
    // before this listener attached.
    _seedInitialState();
  }

  final LoginUseCase _login;
  final LoginWithGoogleUseCase _loginWithGoogle;
  final LogoutUseCase _logout;
  final GetCurrentUserUseCase _getCurrentUser;

  late final StreamSubscription<UserEntity?> _authSub;

  Future<void> _seedInitialState() async {
    if (state.status != AuthStatus.unknown) return;
    final result = await _getCurrentUser();
    // Don't clobber a status the stream may have resolved in the meantime.
    if (state.status != AuthStatus.unknown) return;
    result.match(
      (_) => emit(state.copyWith(status: AuthStatus.unauthenticated)),
      _onAuthChanged,
    );
  }

  void _onAuthChanged(UserEntity? user) {
    if (user != null) {
      emit(
        state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
          isSubmitting: false,
          clearError: true,
        ),
      );
    } else {
      emit(
        state.copyWith(
          status: AuthStatus.unauthenticated,
          isSubmitting: false,
          clearUser: true,
        ),
      );
    }
  }

  Future<void> login({required String email, required String password}) async {
    emit(state.copyWith(isSubmitting: true, clearError: true));
    final result = await _login(
      LoginParams(email: email.trim(), password: password),
    );
    result.match(
      (failure) =>
          emit(state.copyWith(isSubmitting: false, errorMessage: failure.message)),
      // On success the auth stream emits the user and flips status; nothing to
      // do here beyond letting that listener run.
      (_) {},
    );
  }

  Future<void> loginWithGoogle() async {
    emit(state.copyWith(isSubmitting: true, clearError: true));
    final result = await _loginWithGoogle();
    result.match(
      (failure) =>
          emit(state.copyWith(isSubmitting: false, errorMessage: failure.message)),
      // On success the auth stream flips status to authenticated. Stop the
      // spinner here too, which also covers the user dismissing the picker.
      (_) => emit(state.copyWith(isSubmitting: false)),
    );
  }

  Future<void> logout() async {
    await _logout();
    // Status flips to unauthenticated via the auth stream listener.
  }

  /// Clears any visible error (e.g. when the user edits a field).
  void clearError() {
    if (state.errorMessage != null) emit(state.copyWith(clearError: true));
  }

  @override
  Future<void> close() {
    _authSub.cancel();
    return super.close();
  }
}
