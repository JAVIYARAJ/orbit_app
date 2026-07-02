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
