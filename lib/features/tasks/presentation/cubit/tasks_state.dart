import 'package:equatable/equatable.dart';
import 'package:orbit_app/features/tasks/domain/entities/task_entity.dart';
import 'package:orbit_app/features/tasks/domain/entities/task_status_entity.dart';
import 'package:orbit_app/features/tasks/domain/entities/task_priority_entity.dart';
import 'package:orbit_app/features/workspaces/domain/entities/workspace_member_entity.dart';

enum TasksStatus { initial, loading, loaded, error }

class TasksState extends Equatable {
  const TasksState({
    this.status = TasksStatus.initial,
    this.tasks = const [],
    this.statuses = const [],
    this.members = const [],
    this.priorities = const [],
    this.showSubtasks = false,
    this.expandAllSignal = 0,
    this.collapseAllSignal = 0,
    this.errorMessage,
    this.searchQuery = '',
    this.selectedAssigneeId,
    this.selectedPriorityId,
    this.selectedProjectId,
  });

  final TasksStatus status;
  final List<TaskEntity> tasks;
  final List<TaskStatusEntity> statuses;
  final List<WorkspaceMemberEntity> members;
  final List<TaskPriorityEntity> priorities;
  final bool showSubtasks;
  final int expandAllSignal;
  final int collapseAllSignal;
  final String? errorMessage;
  final String searchQuery;
  final String? selectedAssigneeId;
  final String? selectedPriorityId;
  final String? selectedProjectId;

  TasksState copyWith({
    TasksStatus? status,
    List<TaskEntity>? tasks,
    List<TaskStatusEntity>? statuses,
    List<WorkspaceMemberEntity>? members,
    List<TaskPriorityEntity>? priorities,
    bool? showSubtasks,
    int? expandAllSignal,
    int? collapseAllSignal,
    String? errorMessage,
    String? searchQuery,
    String? selectedAssigneeId,
    bool clearAssignee = false,
    String? selectedPriorityId,
    bool clearPriority = false,
    String? selectedProjectId,
    bool clearProject = false,
  }) {
    return TasksState(
      status: status ?? this.status,
      tasks: tasks ?? this.tasks,
      statuses: statuses ?? this.statuses,
      members: members ?? this.members,
      priorities: priorities ?? this.priorities,
      showSubtasks: showSubtasks ?? this.showSubtasks,
      expandAllSignal: expandAllSignal ?? this.expandAllSignal,
      collapseAllSignal: collapseAllSignal ?? this.collapseAllSignal,
      errorMessage: errorMessage ?? this.errorMessage,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedAssigneeId: clearAssignee ? null : (selectedAssigneeId ?? this.selectedAssigneeId),
      selectedPriorityId: clearPriority ? null : (selectedPriorityId ?? this.selectedPriorityId),
      selectedProjectId: clearProject ? null : (selectedProjectId ?? this.selectedProjectId),
    );
  }

  @override
  List<Object?> get props => [
    status, tasks, statuses, members, priorities, showSubtasks, 
    expandAllSignal, collapseAllSignal, errorMessage, searchQuery, 
    selectedAssigneeId, selectedPriorityId, selectedProjectId
  ];
}


