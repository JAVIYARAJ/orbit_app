import 'package:fpdart/fpdart.dart';
import 'package:orbit_app/core/errors/exceptions.dart';
import 'package:orbit_app/core/errors/failures.dart';
import 'package:orbit_app/core/utils/typedefs.dart';
import 'package:orbit_app/features/tasks/data/datasource/task_remote_data_source.dart';
import 'package:orbit_app/features/tasks/domain/entities/tasks_data_entity.dart';
import 'package:orbit_app/features/tasks/domain/repositories/task_repository.dart';

class TaskRepositoryImpl implements TaskRepository {
  TaskRepositoryImpl({required TaskRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  final TaskRemoteDataSource _remoteDataSource;

  @override
  ResultFuture<TasksDataEntity> getWorkstationTasks(String workstationId) async {
    try {
      final result = await _remoteDataSource.getWorkstationTasks(workstationId);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
