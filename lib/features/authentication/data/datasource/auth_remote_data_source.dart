import 'dart:io' show Platform;

import 'package:google_sign_in/google_sign_in.dart';
import 'package:orbit_app/core/errors/exceptions.dart';
import 'package:orbit_app/features/authentication/data/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

/// Talks directly to Supabase auth (GoTrue). Translates SDK errors into the
/// app's own [AuthException] / [ServerException].
abstract interface class AuthRemoteDataSource {
  Future<UserModel> login({required String email, required String password});

  Future<void> loginWithGoogle();

  Future<void> logout();

  UserModel? getCurrentUser();

  Stream<UserModel?> get authStateChanges;
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl(
    this._client, {
    required String googleWebClientId,
    String? googleIosClientId,
  })  : _googleWebClientId = googleWebClientId,
        _googleIosClientId = googleIosClientId;

  final sb.SupabaseClient _client;
  final String _googleWebClientId;
  final String? _googleIosClientId;

  /// Guards [GoogleSignIn.initialize] so it runs exactly once.
  Future<void>? _googleInit;

  sb.GoTrueClient get _auth => _client.auth;

  Future<void> _ensureGoogleInitialized() => _googleInit ??=
      GoogleSignIn.instance.initialize(
        clientId: Platform.isIOS ? _googleIosClientId : null,
        serverClientId: _googleWebClientId,
      );

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final res = await _auth.signInWithPassword(
        email: email,
        password: password,
      );
      final user = res.user;
      if (user == null) {
        throw const AuthException(message: 'Sign in failed. Please try again.');
      }
      return UserModel.fromSupabaseUser(user);
    } on sb.AuthException catch (e) {
      throw AuthException(
        message: _friendlyError(e.message),
        statusCode: e.statusCode,
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> loginWithGoogle() async {
    try {
      await _ensureGoogleInitialized();

      // Native account picker — shown in-app, not in an external browser.
      final GoogleSignInAccount account;
      try {
        account = await GoogleSignIn.instance.authenticate(
          scopeHint: const ['email', 'profile'],
        );
      } on GoogleSignInException catch (e) {
        // User dismissed the picker — not an error, just stop quietly.
        if (e.code == GoogleSignInExceptionCode.canceled) return;
        throw AuthException(
          message: 'Google sign-in failed. Please try again.',
          statusCode: e.code.name,
        );
      }

      final idToken = account.authentication.idToken;
      if (idToken == null) {
        throw const AuthException(
          message: 'Could not get Google credentials. Please try again.',
        );
      }

      // Access token is optional for Supabase; include it when already granted
      // (no extra consent prompt).
      final authorization = await account.authorizationClient
          .authorizationForScopes(const ['email', 'profile']);

      final res = await _auth.signInWithIdToken(
        provider: sb.OAuthProvider.google,
        idToken: idToken,
        accessToken: authorization?.accessToken,
      );
      if (res.user == null) {
        throw const AuthException(message: 'Sign in failed. Please try again.');
      }
    } on AuthException {
      rethrow;
    } on sb.AuthException catch (e) {
      throw AuthException(
        message: _friendlyError(e.message),
        statusCode: e.statusCode,
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> logout() async {
    try {
      // Best-effort: clear the cached Google account so the picker reappears on
      // the next sign-in. Ignored if Google was never used / not initialised.
      try {
        await GoogleSignIn.instance.signOut();
      } catch (_) {}

      // Local scope: revoke only this device's session. The web platform and
      // any other signed-in devices stay logged in.
      await _auth.signOut(scope: sb.SignOutScope.local);
    } on sb.AuthException catch (e) {
      throw AuthException(message: e.message, statusCode: e.statusCode);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  UserModel? getCurrentUser() {
    final user = _auth.currentUser;
    return user == null ? null : UserModel.fromSupabaseUser(user);
  }

  @override
  Stream<UserModel?> get authStateChanges => _auth.onAuthStateChange.map(
        (event) {
          final user = event.session?.user;
          return user == null ? null : UserModel.fromSupabaseUser(user);
        },
      );

  /// Maps raw Supabase auth messages to the same friendly copy the web app
  /// shows (see `orbit/src/pages/auth.jsx` `friendlyError`).
  String _friendlyError(String msg) {
    if (msg.contains('Invalid login credentials')) {
      return 'Incorrect email or password.';
    }
    if (msg.contains('Email not confirmed')) {
      return 'Please confirm your email before signing in.';
    }
    if (msg.contains('Unable to validate email')) {
      return 'Enter a valid email address.';
    }
    if (msg.contains('For security purposes')) {
      return 'Too many attempts. Please wait a moment and try again.';
    }
    return msg;
  }
}
