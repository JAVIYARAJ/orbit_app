import 'package:equatable/equatable.dart';

/// Base type for everything that can go wrong in a way the UI may want to show.
///
/// Repositories return `Either<Failure, T>` so callers handle errors as values
/// instead of try/catch.
abstract class Failure extends Equatable {
  const Failure({required this.message, this.statusCode});

  final String message;
  final String? statusCode;

  @override
  List<Object?> get props => [message, statusCode];
}

/// Authentication-related failure (invalid credentials, OAuth cancelled, …).
class AuthFailure extends Failure {
  const AuthFailure({required super.message, super.statusCode});
}

/// Generic server / network failure.
class ServerFailure extends Failure {
  const ServerFailure({required super.message, super.statusCode});
}
