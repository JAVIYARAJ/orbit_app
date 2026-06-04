import 'package:fpdart/fpdart.dart';
import 'package:orbit_app/core/errors/failures.dart';

/// A future that resolves to either a [Failure] or a value of type [T].
typedef ResultFuture<T> = Future<Either<Failure, T>>;

/// A future operation that either fails or completes with no return value.
typedef ResultVoid = ResultFuture<void>;

/// A plain JSON map.
typedef DataMap = Map<String, dynamic>;
