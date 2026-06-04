import 'package:orbit_app/core/utils/typedefs.dart';

/// A use case that needs input [Params] to produce a [ResultFuture] of [T].
abstract class UseCaseWithParams<T, Params> {
  const UseCaseWithParams();

  ResultFuture<T> call(Params params);
}

/// A use case that takes no input.
abstract class UseCaseWithoutParams<T> {
  const UseCaseWithoutParams();

  ResultFuture<T> call();
}
