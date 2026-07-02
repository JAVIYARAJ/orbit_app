import 'package:fpdart/fpdart.dart';
import 'package:orbit_app/core/errors/exceptions.dart';
import 'package:orbit_app/core/errors/failures.dart';
import 'package:orbit_app/core/utils/typedefs.dart';
import 'package:orbit_app/features/tasks/data/datasource/task_remote_data_source.dart';
import 'package:orbit_app/features/tasks/domain/entities/tasks_data_entity.dart';
import 'package:orbit_app/features/tasks/domain/entities/task_detail_entity.dart';
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

  @override
  ResultFuture<TaskDetailEntity> getTaskDetail(String workstationId, String taskId) async {
    try {
      final result = await _remoteDataSource.getTaskDetail(workstationId, taskId);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  ResultFuture<TaskDetailEntity> updateTask(String taskId, Map<String, dynamic> data) async {
    try {
      final result = await _remoteDataSource.updateTask(taskId, data);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  ResultFuture<void> addTaskComment(String taskId, String body, List<String> mentionedUserIds, String? parentId) async {
    try {
      await _remoteDataSource.addTaskComment(taskId, body, mentionedUserIds, parentId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  ResultFuture<void> deleteTaskComment(String commentId) async {
    try {
      await _remoteDataSource.deleteTaskComment(commentId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
