import 'package:equatable/equatable.dart';

abstract class TasksEvent extends Equatable {
  const TasksEvent();

  @override
  List<Object?> get props => [];
}

class FetchTasksEvent extends TasksEvent {
  const FetchTasksEvent(this.workstationId);

  final String workstationId;

  @override
  List<Object?> get props => [workstationId];
}

class SearchTasksEvent extends TasksEvent {
  const SearchTasksEvent(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}

class SetAssigneeFilterEvent extends TasksEvent {
  const SetAssigneeFilterEvent(this.assigneeId);

  final String? assigneeId;

  @override
  List<Object?> get props => [assigneeId];
}

class SetPriorityFilterEvent extends TasksEvent {
  const SetPriorityFilterEvent(this.priorityId);

  final String? priorityId;

  @override
  List<Object?> get props => [priorityId];
}

class SetProjectFilterEvent extends TasksEvent {
  const SetProjectFilterEvent(this.projectId);

  final String? projectId;

  @override
  List<Object?> get props => [projectId];
}

class ToggleShowSubtasksEvent extends TasksEvent {
  const ToggleShowSubtasksEvent(this.showSubtasks);

  final bool showSubtasks;

  @override
  List<Object?> get props => [showSubtasks];
}

class TriggerExpandAllEvent extends TasksEvent {}

class TriggerCollapseAllEvent extends TasksEvent {}
