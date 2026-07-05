import 'package:orbit_app/core/utils/typedefs.dart';
import 'package:orbit_app/features/tasks/domain/entities/tasks_data_entity.dart';
import 'package:orbit_app/features/tasks/domain/entities/task_detail_entity.dart';
import 'package:orbit_app/features/tasks/domain/entities/task_entity.dart';
import 'package:orbit_app/features/tasks/domain/entities/note_for_linking_entity.dart';

abstract interface class TaskRepository {
  ResultFuture<TasksDataEntity> getWorkstationTasks(String workstationId);
  ResultFuture<TaskEntity> createTask(String workstationId, Map<String, dynamic> data);
  ResultFuture<TaskDetailEntity> getTaskDetail(String workstationId, String taskId);
  ResultFuture<TaskDetailEntity> updateTask(String taskId, Map<String, dynamic> data);
  ResultFuture<void> addTaskComment(String taskId, String body, List<String> mentionedUserIds, String? parentId);
  ResultFuture<void> deleteTaskComment(String commentId);
  ResultFuture<void> deleteTask(String taskId);
  ResultFuture<void> logManualTime({
    required String workstationId,
    required String projectId,
    required String taskId,
    required int minutes,
    required String notes,
  });
  ResultFuture<void> uploadTaskAttachment({
    required String workstationId,
    required String taskId,
    required List<int> fileBytes,
    required String fileName,
    required String? mimeType,
  });
  ResultFuture<void> deleteTaskAttachment({
    required String attachmentId,
  });
  ResultFuture<List<TaskEntity>> getProjectTasks({
    required String workstationId,
    required String projectShortId,
  });
  ResultFuture<List<NoteForLinkingEntity>> getNotesForLinking({
    required String workstationId,
  });
}
