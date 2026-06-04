import 'package:fpdart/fpdart.dart';
import 'package:orbit_app/core/errors/exceptions.dart';
import 'package:orbit_app/core/errors/failures.dart';
import 'package:orbit_app/core/utils/typedefs.dart';
import 'package:orbit_app/features/authentication/data/datasource/auth_remote_data_source.dart';
import 'package:orbit_app/features/authentication/domain/entities/user_entity.dart';
import 'package:orbit_app/features/authentication/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl({required AuthRemoteDataSource remoteDataSource})
      : _remote = remoteDataSource;

  final AuthRemoteDataSource _remote;

  @override
  ResultFuture<UserEntity> login({
    required String email,
    required String password,
  }) =>
      _guard(() => _remote.login(email: email, password: password));

  @override
  ResultVoid loginWithGoogle() => _guard(_remote.loginWithGoogle);

  @override
  ResultVoid logout() => _guard(_remote.logout);

  @override
  ResultFuture<UserEntity?> getCurrentUser() async {
    try {
      return Right(_remote.getCurrentUser());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Stream<UserEntity?> get authStateChanges => _remote.authStateChanges;

  /// Runs [action], mapping data-layer exceptions to typed [Failure]s.
  ResultFuture<T> _guard<T>(Future<T> Function() action) async {
    try {
      return Right(await action());
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message, statusCode: e.statusCode));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
