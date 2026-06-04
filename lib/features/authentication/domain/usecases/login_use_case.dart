import 'package:equatable/equatable.dart';
import 'package:orbit_app/core/utils/typedefs.dart';
import 'package:orbit_app/core/utils/use_case.dart';
import 'package:orbit_app/features/authentication/domain/entities/user_entity.dart';
import 'package:orbit_app/features/authentication/domain/repositories/auth_repository.dart';

/// Signs a user in with email + password.
class LoginUseCase extends UseCaseWithParams<UserEntity, LoginParams> {
  const LoginUseCase(this._repository);

  final AuthRepository _repository;

  @override
  ResultFuture<UserEntity> call(LoginParams params) => _repository.login(
        email: params.email,
        password: params.password,
      );
}

class LoginParams extends Equatable {
  const LoginParams({required this.email, required this.password});

  final String email;
  final String password;

  @override
  List<Object?> get props => [email, password];
}
