import 'package:fpdart/fpdart.dart';
import 'package:orbit_app/core/errors/exceptions.dart';
import 'package:orbit_app/core/errors/failures.dart';
import 'package:orbit_app/core/utils/typedefs.dart';
import 'package:orbit_app/features/tasks/data/datasource/task_remote_data_source.dart';
import 'package:orbit_app/features/tasks/domain/entities/tasks_data_entity.dart';
import 'package:orbit_app/features/tasks/domain/entities/task_detail_entity.dart';
import 'package:orbit_app/features/tasks/domain/entities/task_entity.dart';
import 'package:orbit_app/features/tasks/domain/entities/note_for_linking_entity.dart';
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
  ResultFuture<TaskEntity> createTask(String workstationId, Map<String, dynamic> data) async {
    try {
      final result = await _remoteDataSource.createTask(workstationId, data);
      return Right<Failure, TaskEntity>(result);
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

  @override
  ResultFuture<void> deleteTask(String taskId) async {
    try {
      await _remoteDataSource.deleteTask(taskId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  ResultFuture<void> logManualTime({
    required String workstationId,
    required String projectId,
    required String taskId,
    required int minutes,
    required String notes,
  }) async {
    try {
      await _remoteDataSource.logManualTime(
        workstationId: workstationId,
        projectId: projectId,
        taskId: taskId,
        minutes: minutes,
        notes: notes,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  ResultFuture<void> uploadTaskAttachment({
    required String workstationId,
    required String taskId,
    required List<int> fileBytes,
    required String fileName,
    required String? mimeType,
  }) async {
    try {
      final meta = await _remoteDataSource.uploadCloudinaryFile(
        workstationId: workstationId,
        taskId: taskId,
        fileBytes: fileBytes,
        fileName: fileName,
        mimeType: mimeType,
      );
      await _remoteDataSource.addTaskAttachment(
        taskId: taskId,
        commentId: null,
        data: meta,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  ResultFuture<void> deleteTaskAttachment({
    required String attachmentId,
  }) async {
    try {
      await _remoteDataSource.deleteTaskAttachment(attachmentId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  ResultFuture<List<TaskEntity>> getProjectTasks({
    required String workstationId,
    required String projectShortId,
  }) async {
    try {
      final res = await _remoteDataSource.getProjectTasks(
        workstationId: workstationId,
        projectShortId: projectShortId,
      );
      return Right(res);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  ResultFuture<List<NoteForLinkingEntity>> getNotesForLinking({
    required String workstationId,
  }) async {
    try {
      final res = await _remoteDataSource.getNotesForLinking(
        workstationId: workstationId,
      );
      return Right(res);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
