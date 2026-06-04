/// Low-level exceptions thrown by the data layer (data sources).
///
/// These are caught in the repository layer and mapped to `Failure`s so the
/// rest of the app never has to deal with raw exceptions.
library;

/// Thrown when an authentication operation fails — bad credentials, OAuth
/// cancelled, expired session, etc.
class AuthException implements Exception {
  const AuthException({required this.message, this.statusCode});

  final String message;
  final String? statusCode;

  @override
  String toString() => 'AuthException($statusCode): $message';
}

/// Thrown for unexpected server / network errors.
class ServerException implements Exception {
  const ServerException({required this.message, this.statusCode});

  final String message;
  final String? statusCode;

  @override
  String toString() => 'ServerException($statusCode): $message';
}
