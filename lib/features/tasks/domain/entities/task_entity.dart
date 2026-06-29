import 'package:equatable/equatable.dart';

class TaskEntity extends Equatable {
  const TaskEntity({
    required this.id,
    required this.title,
    this.tagIds = const [],
    required this.taskId,
    required this.userId,
    this.dueDate,
    this.ghBranch,
    required this.statusId,
    this.subsDone = 0,
    this.createdAt,
    this.createdBy,
    this.deletedAt,
    this.deletedBy,
    this.subsTotal = 0,
    this.updatedAt,
    this.updatedBy,
    this.assigneeId,
    this.description,
    this.estMinutes = 0,
    this.priorityId,
    required this.reporterId,
    this.loggedMinutes = 0,
    this.parentTaskId,
    required this.workstationId,
    this.projectShortId,
  });

  final String id;
  final String title;
  final List<String> tagIds;
  final String taskId;
  final String userId;
  final DateTime? dueDate;
  final String? ghBranch;
  final String statusId;
  final int subsDone;
  final DateTime? createdAt;
  final String? createdBy;
  final DateTime? deletedAt;
  final String? deletedBy;
  final int subsTotal;
  final DateTime? updatedAt;
  final String? updatedBy;
  final String? assigneeId;
  final String? description;
  final int estMinutes;
  final String? priorityId;
  final String reporterId;
  final int loggedMinutes;
  final String? parentTaskId;
  final String workstationId;
  final String? projectShortId;

  @override
  List<Object?> get props => [
        id,
        title,
        tagIds,
        taskId,
        userId,
        dueDate,
        ghBranch,
        statusId,
        subsDone,
        createdAt,
        createdBy,
        deletedAt,
        deletedBy,
        subsTotal,
        updatedAt,
        updatedBy,
        assigneeId,
        description,
        estMinutes,
        priorityId,
        reporterId,
        loggedMinutes,
        parentTaskId,
        workstationId,
        projectShortId,
      ];
}
