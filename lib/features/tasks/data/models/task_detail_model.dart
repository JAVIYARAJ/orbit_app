import 'package:orbit_app/features/tasks/domain/entities/task_detail_entity.dart';

class TaskDetailModel extends TaskDetailEntity {
  const TaskDetailModel({
    required super.task,
    required super.history,
    required super.comments,
    required super.metadata,
    required super.subtasks,
    required super.workLogs,
    required super.attachments,
    required super.linkedNotes,
  });

  factory TaskDetailModel.fromJson(Map<String, dynamic> json) {
    return TaskDetailModel(
      task: TaskDetailDataModel.fromJson(json['task'] as Map<String, dynamic>),
      history: (json['history'] as List<dynamic>?)?.map((e) => TaskHistoryModel.fromJson(e as Map<String, dynamic>)).toList() ?? [],
      comments: (json['comments'] as List<dynamic>?)?.map((e) => TaskCommentModel.fromJson(e as Map<String, dynamic>)).toList() ?? [],
      metadata: TaskMetadataModel.fromJson(json['metadata'] as Map<String, dynamic>),
      subtasks: (json['subtasks'] as List<dynamic>?)?.map((e) => TaskSubtaskModel.fromJson(e as Map<String, dynamic>)).toList() ?? [],
      workLogs: (json['workLogs'] as List<dynamic>?)?.map((e) => TaskWorkLogModel.fromJson(e as Map<String, dynamic>)).toList() ?? [],
      attachments: (json['attachments'] as List<dynamic>?)?.map((e) => TaskAttachmentModel.fromJson(e as Map<String, dynamic>)).toList() ?? [],
      linkedNotes: (json['linkedNotes'] as List<dynamic>?)?.map((e) => TaskLinkedNoteModel.fromJson(e as Map<String, dynamic>)).toList() ?? [],
    );
  }
}

class TaskDetailDataModel extends TaskDetailDataEntity {
  const TaskDetailDataModel({
    required super.id,
    required super.taskId,
    required super.title,
    super.description,
    required super.status,
    super.priority,
    super.project,
    super.assignee,
    super.reporter,
    super.dueDate,
    super.progress,
    super.loggedMinutes,
    super.estimateMinutes,
    super.tags,
    super.branchName,
    super.createdAt,
    super.updatedAt,
  });

  factory TaskDetailDataModel.fromJson(Map<String, dynamic> json) {
    return TaskDetailDataModel(
      id: json['id'] as String,
      taskId: json['taskId'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      status: TaskStatusItemModel.fromJson(json['status'] as Map<String, dynamic>),
      priority: json['priority'] != null ? TaskPriorityItemModel.fromJson(json['priority'] as Map<String, dynamic>) : null,
      project: json['project'] != null ? TaskProjectItemModel.fromJson(json['project'] as Map<String, dynamic>) : null,
      assignee: json['assignee'] != null ? TaskUserItemModel.fromJson(json['assignee'] as Map<String, dynamic>) : null,
      reporter: json['reporter'] != null ? TaskUserItemModel.fromJson(json['reporter'] as Map<String, dynamic>) : null,
      dueDate: json['dueDate'] != null ? DateTime.tryParse(json['dueDate'] as String) : null,
      progress: json['progress'] as num? ?? 0,
      loggedMinutes: json['loggedMinutes'] as num? ?? 0,
      estimateMinutes: json['estimateMinutes'] as num? ?? 0,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => TaskTagItemModel.fromJson(e as Map<String, dynamic>)).toList() ?? [],
      branchName: json['branch']?['name'] as String?,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'] as String) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt'] as String) : null,
    );
  }
}

class TaskStatusItemModel extends TaskStatusItemEntity {
  const TaskStatusItemModel({required super.id, required super.color, required super.label, super.isDone});
  factory TaskStatusItemModel.fromJson(Map<String, dynamic> json) {
    return TaskStatusItemModel(
      id: json['id'] as String,
      color: json['color'] as String,
      label: json['label'] as String,
      isDone: json['isDone'] as bool? ?? false,
    );
  }
}

class TaskPriorityItemModel extends TaskPriorityItemEntity {
  const TaskPriorityItemModel({required super.id, required super.color, required super.label});
  factory TaskPriorityItemModel.fromJson(Map<String, dynamic> json) {
    return TaskPriorityItemModel(
      id: json['id'] as String,
      color: json['color'] as String,
      label: json['label'] as String,
    );
  }
}

class TaskProjectItemModel extends TaskProjectItemEntity {
  const TaskProjectItemModel({required super.id, required super.name, required super.shortId});
  factory TaskProjectItemModel.fromJson(Map<String, dynamic> json) {
    return TaskProjectItemModel(
      id: json['id'] as String,
      name: json['name'] as String,
      shortId: json['shortId'] as String,
    );
  }
}

class TaskUserItemModel extends TaskUserItemEntity {
  const TaskUserItemModel({required super.id, required super.name, super.email, super.avatar, super.role});
  factory TaskUserItemModel.fromJson(Map<String, dynamic> json) {
    return TaskUserItemModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String?,
      avatar: json['avatar'] as String?,
      role: json['role'] as String?,
    );
  }
}

class TaskTagItemModel extends TaskTagItemEntity {
  const TaskTagItemModel({required super.id, required super.name, required super.color});
  factory TaskTagItemModel.fromJson(Map<String, dynamic> json) {
    return TaskTagItemModel(
      id: json['id'] as String,
      name: json['name'] as String,
      color: json['color'] as String,
    );
  }
}

class TaskHistoryModel extends TaskHistoryEntity {
  const TaskHistoryModel({required super.id, required super.toStatus, required super.changedAt, required super.changedBy, required super.fromStatus});
  factory TaskHistoryModel.fromJson(Map<String, dynamic> json) {
    return TaskHistoryModel(
      id: json['id'] as String,
      toStatus: TaskStatusItemModel.fromJson(json['toStatus'] as Map<String, dynamic>),
      changedAt: DateTime.parse(json['changedAt'] as String),
      changedBy: TaskUserItemModel.fromJson(json['changedBy'] as Map<String, dynamic>),
      fromStatus: TaskStatusItemModel.fromJson(json['fromStatus'] as Map<String, dynamic>),
    );
  }
}

class TaskCommentModel extends TaskCommentEntity {
  const TaskCommentModel({required super.id, required super.body, required super.author, super.editedAt, super.parentId, required super.createdAt, super.mentionedUserIds});
  factory TaskCommentModel.fromJson(Map<String, dynamic> json) {
    return TaskCommentModel(
      id: json['id'] as String,
      body: json['body'] as String,
      author: TaskUserItemModel.fromJson(json['author'] as Map<String, dynamic>),
      editedAt: json['editedAt'] != null ? DateTime.tryParse(json['editedAt'] as String) : null,
      parentId: json['parentId'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      mentionedUserIds: (json['mentionedUserIds'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
    );
  }
}

class TaskMetadataModel extends TaskMetadataEntity {
  const TaskMetadataModel({required super.tags, required super.members, required super.statuses, required super.priorities});
  factory TaskMetadataModel.fromJson(Map<String, dynamic> json) {
    return TaskMetadataModel(
      tags: (json['tags'] as List<dynamic>?)?.map((e) => TaskTagItemModel.fromJson(e as Map<String, dynamic>)).toList() ?? [],
      members: (json['members'] as List<dynamic>?)?.map((e) => TaskUserItemModel.fromJson(e as Map<String, dynamic>)).toList() ?? [],
      statuses: (json['statuses'] as List<dynamic>?)?.map((e) => TaskStatusItemModel.fromJson(e as Map<String, dynamic>)).toList() ?? [],
      priorities: (json['priorities'] as List<dynamic>?)?.map((e) => TaskPriorityItemModel.fromJson(e as Map<String, dynamic>)).toList() ?? [],
    );
  }
}

class TaskSubtaskModel extends TaskSubtaskEntity {
  const TaskSubtaskModel({required super.id, required super.title, required super.status, required super.taskId, super.dueDate, super.priority, required super.createdAt});
  factory TaskSubtaskModel.fromJson(Map<String, dynamic> json) {
    return TaskSubtaskModel(
      id: json['id'] as String,
      title: json['title'] as String,
      status: TaskStatusItemModel.fromJson(json['status'] as Map<String, dynamic>),
      taskId: json['taskId'] as String,
      dueDate: json['dueDate'] != null ? DateTime.tryParse(json['dueDate'] as String) : null,
      priority: json['priority'] != null ? TaskPriorityItemModel.fromJson(json['priority'] as Map<String, dynamic>) : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

class TaskWorkLogModel extends TaskWorkLogEntity {
  const TaskWorkLogModel({required super.id, required super.user, required super.notes, required super.status, required super.endedAt, super.isManual, required super.createdAt, required super.startedAt, required super.totalSeconds});
  factory TaskWorkLogModel.fromJson(Map<String, dynamic> json) {
    return TaskWorkLogModel(
      id: json['id'] as String,
      user: TaskUserItemModel.fromJson(json['user'] as Map<String, dynamic>),
      notes: json['notes'] as String? ?? '',
      status: json['status'] as String,
      endedAt: DateTime.parse(json['endedAt'] as String),
      isManual: json['isManual'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      startedAt: DateTime.parse(json['startedAt'] as String),
      totalSeconds: json['totalSeconds'] as int? ?? 0,
    );
  }
}

class TaskAttachmentModel extends TaskAttachmentEntity {
  const TaskAttachmentModel({required super.id, required super.url, required super.fileName, required super.mimeType, required super.sizeBytes, required super.uploadedBy, required super.createdAt});
  factory TaskAttachmentModel.fromJson(Map<String, dynamic> json) {
    return TaskAttachmentModel(
      id: json['id'] as String,
      url: json['url'] as String,
      fileName: json['fileName'] as String? ?? 'Attachment',
      mimeType: json['mimeType'] as String? ?? 'application/octet-stream',
      sizeBytes: json['sizeBytes'] as int? ?? 0,
      uploadedBy: TaskUserItemModel.fromJson(json['uploadedBy'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

class TaskLinkedNoteModel extends TaskLinkedNoteEntity {
  const TaskLinkedNoteModel({required super.id, required super.title, super.pinned, super.updatedAt});
  factory TaskLinkedNoteModel.fromJson(Map<String, dynamic> json) {
    return TaskLinkedNoteModel(
      id: json['id'] as String,
      title: json['title'] as String,
      pinned: json['pinned'] as bool? ?? false,
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt'] as String) : null,
    );
  }
}
