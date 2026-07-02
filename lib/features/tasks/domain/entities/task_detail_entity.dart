import 'package:equatable/equatable.dart';

class TaskDetailEntity extends Equatable {
  const TaskDetailEntity({
    required this.task,
    required this.history,
    required this.comments,
    required this.metadata,
    required this.subtasks,
    required this.workLogs,
    required this.attachments,
    required this.linkedNotes,
  });

  final TaskDetailDataEntity task;
  final List<TaskHistoryEntity> history;
  final List<TaskCommentEntity> comments;
  final TaskMetadataEntity metadata;
  final List<TaskSubtaskEntity> subtasks;
  final List<TaskWorkLogEntity> workLogs;
  final List<TaskAttachmentEntity> attachments;
  final List<TaskLinkedNoteEntity> linkedNotes;

  @override
  List<Object?> get props => [task, history, comments, metadata, subtasks, workLogs, attachments, linkedNotes];

  TaskDetailEntity copyWith({
    TaskDetailDataEntity? task,
    List<TaskHistoryEntity>? history,
    List<TaskCommentEntity>? comments,
    TaskMetadataEntity? metadata,
    List<TaskSubtaskEntity>? subtasks,
    List<TaskWorkLogEntity>? workLogs,
    List<TaskAttachmentEntity>? attachments,
    List<TaskLinkedNoteEntity>? linkedNotes,
  }) {
    return TaskDetailEntity(
      task: task ?? this.task,
      history: history ?? this.history,
      comments: comments ?? this.comments,
      metadata: metadata ?? this.metadata,
      subtasks: subtasks ?? this.subtasks,
      workLogs: workLogs ?? this.workLogs,
      attachments: attachments ?? this.attachments,
      linkedNotes: linkedNotes ?? this.linkedNotes,
    );
  }
}

class TaskDetailDataEntity extends Equatable {
  const TaskDetailDataEntity({
    required this.id,
    required this.taskId,
    required this.title,
    this.description,
    required this.status,
    this.priority,
    this.project,
    this.assignee,
    this.reporter,
    this.dueDate,
    this.progress = 0,
    this.loggedMinutes = 0,
    this.estimateMinutes = 0,
    this.tags = const [],
    this.branchName,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String taskId;
  final String title;
  final String? description;
  final TaskStatusItemEntity status;
  final TaskPriorityItemEntity? priority;
  final TaskProjectItemEntity? project;
  final TaskUserItemEntity? assignee;
  final TaskUserItemEntity? reporter;
  final DateTime? dueDate;
  final num progress;
  final num loggedMinutes;
  final num estimateMinutes;
  final List<TaskTagItemEntity> tags;
  final String? branchName;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  @override
  List<Object?> get props => [id, taskId, title, description, status, priority, project, assignee, reporter, dueDate, progress, loggedMinutes, estimateMinutes, tags, branchName, createdAt, updatedAt];

  TaskDetailDataEntity copyWith({
    String? id,
    String? taskId,
    String? title,
    String? description,
    TaskStatusItemEntity? status,
    TaskPriorityItemEntity? priority,
    TaskProjectItemEntity? project,
    TaskUserItemEntity? assignee,
    TaskUserItemEntity? reporter,
    DateTime? dueDate,
    bool clearDueDate = false,
    num? progress,
    num? loggedMinutes,
    num? estimateMinutes,
    List<TaskTagItemEntity>? tags,
    String? branchName,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TaskDetailDataEntity(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      project: project ?? this.project,
      assignee: assignee ?? this.assignee,
      reporter: reporter ?? this.reporter,
      dueDate: clearDueDate ? null : (dueDate ?? this.dueDate),
      progress: progress ?? this.progress,
      loggedMinutes: loggedMinutes ?? this.loggedMinutes,
      estimateMinutes: estimateMinutes ?? this.estimateMinutes,
      tags: tags ?? this.tags,
      branchName: branchName ?? this.branchName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class TaskStatusItemEntity extends Equatable {
  const TaskStatusItemEntity({required this.id, required this.color, required this.label, this.isDone = false});
  final String id;
  final String color;
  final String label;
  final bool isDone;
  @override
  List<Object?> get props => [id, color, label, isDone];
}

class TaskPriorityItemEntity extends Equatable {
  const TaskPriorityItemEntity({required this.id, required this.color, required this.label});
  final String id;
  final String color;
  final String label;
  @override
  List<Object?> get props => [id, color, label];
}

class TaskProjectItemEntity extends Equatable {
  const TaskProjectItemEntity({required this.id, required this.name, required this.shortId});
  final String id;
  final String name;
  final String shortId;
  @override
  List<Object?> get props => [id, name, shortId];
}

class TaskUserItemEntity extends Equatable {
  const TaskUserItemEntity({required this.id, required this.name, this.email, this.avatar, this.role});
  final String id;
  final String name;
  final String? email;
  final String? avatar;
  final String? role;
  @override
  List<Object?> get props => [id, name, email, avatar, role];
}

class TaskTagItemEntity extends Equatable {
  const TaskTagItemEntity({required this.id, required this.name, required this.color});
  final String id;
  final String name;
  final String color;
  @override
  List<Object?> get props => [id, name, color];
}

class TaskHistoryEntity extends Equatable {
  const TaskHistoryEntity({required this.id, required this.toStatus, required this.changedAt, required this.changedBy, required this.fromStatus});
  final String id;
  final TaskStatusItemEntity toStatus;
  final DateTime changedAt;
  final TaskUserItemEntity changedBy;
  final TaskStatusItemEntity fromStatus;
  @override
  List<Object?> get props => [id, toStatus, changedAt, changedBy, fromStatus];
}

class TaskCommentEntity extends Equatable {
  const TaskCommentEntity({required this.id, required this.body, required this.author, this.editedAt, this.parentId, required this.createdAt, this.mentionedUserIds = const []});
  final String id;
  final String body;
  final TaskUserItemEntity author;
  final DateTime? editedAt;
  final String? parentId;
  final DateTime createdAt;
  final List<String> mentionedUserIds;
  @override
  List<Object?> get props => [id, body, author, editedAt, parentId, createdAt, mentionedUserIds];
}

class TaskMetadataEntity extends Equatable {
  const TaskMetadataEntity({required this.tags, required this.members, required this.statuses, required this.priorities});
  final List<TaskTagItemEntity> tags;
  final List<TaskUserItemEntity> members;
  final List<TaskStatusItemEntity> statuses;
  final List<TaskPriorityItemEntity> priorities;
  @override
  List<Object?> get props => [tags, members, statuses, priorities];
}

class TaskSubtaskEntity extends Equatable {
  const TaskSubtaskEntity({required this.id, required this.title, required this.status, required this.taskId, this.dueDate, this.priority, required this.createdAt});
  final String id;
  final String title;
  final TaskStatusItemEntity status;
  final String taskId;
  final DateTime? dueDate;
  final TaskPriorityItemEntity? priority;
  final DateTime createdAt;
  @override
  List<Object?> get props => [id, title, status, taskId, dueDate, priority, createdAt];
}

class TaskWorkLogEntity extends Equatable {
  const TaskWorkLogEntity({required this.id, required this.user, required this.notes, required this.status, required this.endedAt, this.isManual = false, required this.createdAt, required this.startedAt, required this.totalSeconds});
  final String id;
  final TaskUserItemEntity user;
  final String notes;
  final String status;
  final DateTime endedAt;
  final bool isManual;
  final DateTime createdAt;
  final DateTime startedAt;
  final int totalSeconds;
  @override
  List<Object?> get props => [id, user, notes, status, endedAt, isManual, createdAt, startedAt, totalSeconds];
}

class TaskAttachmentEntity extends Equatable {
  const TaskAttachmentEntity({required this.id, required this.url, required this.fileName, required this.mimeType, required this.sizeBytes, required this.uploadedBy, required this.createdAt});
  final String id;
  final String url;
  final String fileName;
  final String mimeType;
  final int sizeBytes;
  final TaskUserItemEntity uploadedBy;
  final DateTime createdAt;
  @override
  List<Object?> get props => [id, url, fileName, mimeType, sizeBytes, uploadedBy, createdAt];
}

class TaskLinkedNoteEntity extends Equatable {
  const TaskLinkedNoteEntity({required this.id, required this.title, this.pinned = false, this.updatedAt});
  final String id;
  final String title;
  final bool pinned;
  final DateTime? updatedAt;
  @override
  List<Object?> get props => [id, title, pinned, updatedAt];
}
