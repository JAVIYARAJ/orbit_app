import 'package:orbit_app/core/utils/typedefs.dart';
import 'package:orbit_app/features/tasks/domain/entities/tasks_data_entity.dart';
import 'package:orbit_app/features/tasks/domain/entities/task_detail_entity.dart';
import 'package:orbit_app/features/tasks/domain/entities/task_entity.dart';

abstract interface class TaskRepository {
  ResultFuture<TasksDataEntity> getWorkstationTasks(String workstationId);
  ResultFuture<TaskEntity> createTask(String workstationId, Map<String, dynamic> data);
  ResultFuture<TaskDetailEntity> getTaskDetail(String workstationId, String taskId);
  ResultFuture<TaskDetailEntity> updateTask(String taskId, Map<String, dynamic> data);
  ResultFuture<void> addTaskComment(String taskId, String body, List<String> mentionedUserIds, String? parentId);
  ResultFuture<void> deleteTaskComment(String commentId);
  ResultFuture<void> deleteTask(String taskId);
}
