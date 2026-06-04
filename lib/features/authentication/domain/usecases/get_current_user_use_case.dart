import 'package:orbit_app/core/utils/typedefs.dart';
import 'package:orbit_app/core/utils/use_case.dart';
import 'package:orbit_app/features/authentication/domain/entities/user_entity.dart';
import 'package:orbit_app/features/authentication/domain/repositories/auth_repository.dart';

/// Returns the currently signed-in user, or `null` if no session exists.
class GetCurrentUserUseCase extends UseCaseWithoutParams<UserEntity?> {
  const GetCurrentUserUseCase(this._repository);

  final AuthRepository _repository;

  @override
  ResultFuture<UserEntity?> call() => _repository.getCurrentUser();
}
