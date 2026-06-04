import 'package:orbit_app/core/utils/typedefs.dart';
import 'package:orbit_app/features/authentication/domain/entities/user_entity.dart';

/// Contract for authentication. Implemented in the data layer against Supabase.
abstract interface class AuthRepository {
  /// Sign in with email + password. Returns the authenticated user.
  ResultFuture<UserEntity> login({
    required String email,
    required String password,
  });

  /// Start the Google OAuth flow (opens an external browser / custom tab).
  ///
  /// The session arrives asynchronously via [authStateChanges] once the user
  /// returns through the deep-link redirect, so this completes with no value.
  ResultVoid loginWithGoogle();

  /// Sign the current user out.
  ResultVoid logout();

  /// The currently signed-in user, or `null` if there is no active session.
  ResultFuture<UserEntity?> getCurrentUser();

  /// Emits the current user on sign-in and `null` on sign-out. Used to drive
  /// route guards so the UI reacts to session changes (including OAuth).
  Stream<UserEntity?> get authStateChanges;
}
