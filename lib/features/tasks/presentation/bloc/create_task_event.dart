import 'package:equatable/equatable.dart';
import 'package:orbit_app/features/tasks/domain/entities/task_entity.dart';
import 'package:orbit_app/features/tasks/presentation/bloc/create_task_state.dart';

abstract class CreateTaskEvent extends Equatable {
  const CreateTaskEvent();
  @override
  List<Object?> get props => [];
}

class FetchMetadataEvent extends CreateTaskEvent {
  final String workstationId;
  const FetchMetadataEvent(this.workstationId);
  @override
  List<Object?> get props => [workstationId];
}

class UpdateFieldEvent extends CreateTaskEvent {
  final String? title;
  final String? description;
  final String? projectId;
  final String? statusId;
  final String? priorityId;
  final String? assigneeId;
  final List<String>? selectedTagIds;
  final int? estHours;
  final int? estMinutes;
  final DateTime? dueDate;
  final BranchMode? branchMode;
  final String? branchName;
  final String? existingBranch;

  const UpdateFieldEvent({
    this.title,
    this.description,
    this.projectId,
    this.statusId,
    this.priorityId,
    this.assigneeId,
    this.selectedTagIds,
    this.estHours,
    this.estMinutes,
    this.dueDate,
    this.branchMode,
    this.branchName,
    this.existingBranch,
  });

  @override
  List<Object?> get props => [
        title,
        description,
        projectId,
        statusId,
        priorityId,
        assigneeId,
        selectedTagIds,
        estHours,
        estMinutes,
        dueDate,
        branchMode,
        branchName,
        existingBranch,
      ];
}

class SubmitTaskEvent extends CreateTaskEvent {
  final String workstationId;
  final List<TaskEntity> existingTasks;
  const SubmitTaskEvent({required this.workstationId, required this.existingTasks});
  @override
  List<Object?> get props => [workstationId, existingTasks];
}
