import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Typed access to runtime configuration loaded from the `.env` file.
///
/// Call [AppConfig.load] once at startup (before [AppConfig] getters are read)
/// — see `main.dart`.
abstract final class AppConfig {
  /// Loads the `.env` file into memory. Must be awaited before any getter.
  static Future<void> load() => dotenv.load();

  static String _require(String key) {
    final value = dotenv.env[key];
    if (value == null || value.isEmpty) {
      throw StateError(
        'Missing "$key" in .env — copy .env.example to .env and fill it in.',
      );
    }
    return value;
  }

  /// Supabase project URL (shared with the Orbit web platform).
  static String get supabaseUrl => _require('SUPABASE_URL');

  /// Supabase anon/publishable key.
  static String get supabaseAnonKey => _require('SUPABASE_ANON_KEY');

  /// Google OAuth **Web** client ID. Used as `serverClientId` for native Google
  /// Sign-In so the returned ID token's audience matches the client Supabase
  /// trusts. Required on both Android and iOS.
  static String get googleWebClientId => _require('GOOGLE_WEB_CLIENT_ID');

  /// Google OAuth **iOS** client ID. Only needed on iOS; null elsewhere.
  static String? get googleIosClientId {
    final value = dotenv.env['GOOGLE_IOS_CLIENT_ID'];
    return (value == null || value.isEmpty) ? null : value;
  }
}
