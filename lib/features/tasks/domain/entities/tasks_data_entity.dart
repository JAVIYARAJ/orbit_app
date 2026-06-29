import 'package:equatable/equatable.dart';
import 'package:orbit_app/features/tasks/domain/entities/task_entity.dart';
import 'package:orbit_app/features/tasks/domain/entities/task_status_entity.dart';

import 'package:orbit_app/features/workspaces/domain/entities/workspace_member_entity.dart';
import 'package:orbit_app/features/tasks/domain/entities/task_priority_entity.dart';

class TasksDataEntity extends Equatable {
  const TasksDataEntity({
    required this.tasks,
    required this.statuses,
    required this.members,
    required this.priorities,
  });

  final List<TaskEntity> tasks;
  final List<TaskStatusEntity> statuses;
  final List<WorkspaceMemberEntity> members;
  final List<TaskPriorityEntity> priorities;

  @override
  List<Object?> get props => [tasks, statuses, members, priorities];
}
