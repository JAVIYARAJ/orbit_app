import 'package:fpdart/fpdart.dart';
import 'package:orbit_app/core/errors/exceptions.dart';
import 'package:orbit_app/core/errors/failures.dart';
import 'package:orbit_app/features/workspaces/data/datasource/workspace_remote_data_source.dart';
import 'package:orbit_app/features/workspaces/domain/entities/workspace_context_entity.dart';
import 'package:orbit_app/features/workspaces/domain/repositories/workspace_repository.dart';

class WorkspaceRepositoryImpl implements WorkspaceRepository {
  WorkspaceRepositoryImpl({required WorkspaceRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  final WorkspaceRemoteDataSource _remoteDataSource;

  @override
  Future<Either<Failure, WorkspaceContextEntity>> getMyContext() async {
    try {
      final context = await _remoteDataSource.getMyContext();
      return Right(context);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
