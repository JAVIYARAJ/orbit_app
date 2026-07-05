import 'package:equatable/equatable.dart';
import 'package:orbit_app/features/tasks/domain/entities/task_detail_entity.dart';

abstract class TaskDetailEvent extends Equatable {
  const TaskDetailEvent();

  @override
  List<Object?> get props => [];
}

class FetchTaskDetailEvent extends TaskDetailEvent {
  const FetchTaskDetailEvent({required this.workstationId, required this.taskId});
  
  final String workstationId;
  final String taskId;

  @override
  List<Object?> get props => [workstationId, taskId];
}

class UpdateTaskStatusEvent extends TaskDetailEvent {
  const UpdateTaskStatusEvent({required this.workstationId, required this.taskId, required this.statusId});
  final String workstationId;
  final String taskId;
  final String statusId;
  @override List<Object?> get props => [workstationId, taskId, statusId];
}

class UpdateTaskPriorityEvent extends TaskDetailEvent {
  const UpdateTaskPriorityEvent({required this.workstationId, required this.taskId, required this.priorityId});
  final String workstationId;
  final String taskId;
  final String priorityId;
  @override List<Object?> get props => [workstationId, taskId, priorityId];
}

class UpdateTaskDueDateEvent extends TaskDetailEvent {
  const UpdateTaskDueDateEvent({required this.workstationId, required this.taskId, this.dueDate});
  final String workstationId;
  final String taskId;
  final DateTime? dueDate;
  @override List<Object?> get props => [workstationId, taskId, dueDate];
}

class UpdateTaskAssigneeEvent extends TaskDetailEvent {
  const UpdateTaskAssigneeEvent({required this.workstationId, required this.taskId, required this.assigneeId});
  final String workstationId;
  final String taskId;
  final String assigneeId;
  @override List<Object?> get props => [workstationId, taskId, assigneeId];
}

class UpdateTaskReporterEvent extends TaskDetailEvent {
  const UpdateTaskReporterEvent({required this.workstationId, required this.taskId, required this.reporterId});
  final String workstationId;
  final String taskId;
  final String reporterId;
  @override List<Object?> get props => [workstationId, taskId, reporterId];
}

class UpdateTaskBranchEvent extends TaskDetailEvent {
  const UpdateTaskBranchEvent({required this.workstationId, required this.taskId, required this.branch});
  final String workstationId;
  final String taskId;
  final String branch;
  @override List<Object?> get props => [workstationId, taskId, branch];
}

class DeleteTaskEvent extends TaskDetailEvent {
  const DeleteTaskEvent({required this.workstationId, required this.taskId});
  final String workstationId;
  final String taskId;
  @override List<Object?> get props => [workstationId, taskId];
}

class UpdateTaskTagsEvent extends TaskDetailEvent {
  const UpdateTaskTagsEvent({required this.workstationId, required this.taskId, required this.tags});
  final String workstationId;
  final String taskId;
  final List<TaskTagItemEntity> tags;
  @override List<Object?> get props => [workstationId, taskId, tags];
}

class UpdateTaskTitleEvent extends TaskDetailEvent {
  const UpdateTaskTitleEvent({required this.workstationId, required this.taskId, required this.title});
  final String workstationId;
  final String taskId;
  final String title;
  @override List<Object?> get props => [workstationId, taskId, title];
}

class UpdateTaskDescriptionEvent extends TaskDetailEvent {
  const UpdateTaskDescriptionEvent({required this.workstationId, required this.taskId, required this.description});
  final String workstationId;
  final String taskId;
  final String description;
  @override List<Object?> get props => [workstationId, taskId, description];
}

class UpdateTaskEstimateEvent extends TaskDetailEvent {
  const UpdateTaskEstimateEvent({required this.workstationId, required this.taskId, required this.estimateMinutes});
  final String workstationId;
  final String taskId;
  final int estimateMinutes;
  @override List<Object?> get props => [workstationId, taskId, estimateMinutes];
}

class AddTaskCommentEvent extends TaskDetailEvent {
  const AddTaskCommentEvent({
    required this.workstationId,
    required this.taskId,
    required this.body,
    required this.mentionedUserIds,
    this.parentId,
  });

  final String workstationId;
  final String taskId;
  final String body;
  final List<String> mentionedUserIds;
  final String? parentId;

  @override
  List<Object?> get props => [workstationId, taskId, body, mentionedUserIds, parentId];
}

class DeleteTaskCommentEvent extends TaskDetailEvent {
  const DeleteTaskCommentEvent({
    required this.workstationId,
    required this.taskId,
    required this.commentId,
  });

  final String workstationId;
  final String taskId;
  final String commentId;

  @override
  List<Object?> get props => [workstationId, taskId, commentId];
}

class LogTaskTimeEvent extends TaskDetailEvent {
  const LogTaskTimeEvent({
    required this.workstationId,
    required this.projectId,
    required this.taskId,
    required this.minutes,
    required this.notes,
  });

  final String workstationId;
  final String projectId;
  final String taskId;
  final int minutes;
  final String notes;

  @override
  List<Object?> get props => [workstationId, projectId, taskId, minutes, notes];
}

class UploadTaskAttachmentEvent extends TaskDetailEvent {
  const UploadTaskAttachmentEvent({
    required this.workstationId,
    required this.taskId,
    required this.fileBytes,
    required this.fileName,
    required this.mimeType,
  });

  final String workstationId;
  final String taskId;
  final List<int> fileBytes;
  final String fileName;
  final String? mimeType;

  @override
  List<Object?> get props => [workstationId, taskId, fileName, mimeType];
}

class DeleteTaskAttachmentEvent extends TaskDetailEvent {
  const DeleteTaskAttachmentEvent({
    required this.workstationId,
    required this.taskId,
    required this.attachmentId,
  });

  final String workstationId;
  final String taskId;
  final String attachmentId;

  @override
  List<Object?> get props => [workstationId, taskId, attachmentId];
}

class FetchProjectTasksEvent extends TaskDetailEvent {
  const FetchProjectTasksEvent({
    required this.workstationId,
    required this.projectShortId,
  });

  final String workstationId;
  final String projectShortId;

  @override
  List<Object?> get props => [workstationId, projectShortId];
}

class LinkSubtaskEvent extends TaskDetailEvent {
  const LinkSubtaskEvent({
    required this.workstationId,
    required this.childTaskId,
    required this.parentTaskId,
  });

  final String workstationId;
  final String childTaskId;
  final String? parentTaskId;

  @override
  List<Object?> get props => [workstationId, childTaskId, parentTaskId];
}

class FetchNotesForLinkingEvent extends TaskDetailEvent {
  const FetchNotesForLinkingEvent({
    required this.workstationId,
  });

  final String workstationId;

  @override
  List<Object?> get props => [workstationId];
}

class LinkNoteEvent extends TaskDetailEvent {
  const LinkNoteEvent({
    required this.workstationId,
    required this.taskId,
    required this.linkedNoteIds,
  });

  final String workstationId;
  final String taskId;
  final List<String> linkedNoteIds;

  @override
  List<Object?> get props => [workstationId, taskId, linkedNoteIds];
}
