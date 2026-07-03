import 'package:equatable/equatable.dart';

enum CreateTaskStatus { initial, loading, loaded, creating, success, error }
enum BranchMode { none, create, existing }

class CreateTaskState extends Equatable {
  const CreateTaskState({
    this.status = CreateTaskStatus.initial,
    this.metadata = const {},
    this.selectedProjectId,
    this.selectedStatusId,
    this.selectedPriorityId,
    this.selectedAssigneeId,
    this.selectedTagIds = const [],
    this.title = '',
    this.description = '',
    this.estHours = 0,
    this.estMinutes = 0,
    this.dueDate,
    this.branchMode = BranchMode.none,
    this.branchName = '',
    this.existingBranch = '',
    this.errorMessage,
    this.createdTask,
  });

  final CreateTaskStatus status;
  final Map<String, dynamic> metadata;
  
  final String? selectedProjectId;
  final String? selectedStatusId;
  final String? selectedPriorityId;
  final String? selectedAssigneeId;
  final List<String> selectedTagIds;
  
  final String title;
  final String description;
  final int estHours;
  final int estMinutes;
  final DateTime? dueDate;

  final BranchMode branchMode;
  final String branchName;
  final String existingBranch;

  final String? errorMessage;
  final dynamic createdTask;

  CreateTaskState copyWith({
    CreateTaskStatus? status,
    Map<String, dynamic>? metadata,
    String? selectedProjectId,
    String? selectedStatusId,
    String? selectedPriorityId,
    String? selectedAssigneeId,
    List<String>? selectedTagIds,
    String? title,
    String? description,
    int? estHours,
    int? estMinutes,
    DateTime? dueDate,
    BranchMode? branchMode,
    String? branchName,
    String? existingBranch,
    String? errorMessage,
    dynamic createdTask,
  }) {
    return CreateTaskState(
      status: status ?? this.status,
      metadata: metadata ?? this.metadata,
      selectedProjectId: selectedProjectId ?? this.selectedProjectId,
      selectedStatusId: selectedStatusId ?? this.selectedStatusId,
      selectedPriorityId: selectedPriorityId ?? this.selectedPriorityId,
      selectedAssigneeId: selectedAssigneeId ?? this.selectedAssigneeId,
      selectedTagIds: selectedTagIds ?? this.selectedTagIds,
      title: title ?? this.title,
      description: description ?? this.description,
      estHours: estHours ?? this.estHours,
      estMinutes: estMinutes ?? this.estMinutes,
      dueDate: dueDate ?? this.dueDate,
      branchMode: branchMode ?? this.branchMode,
      branchName: branchName ?? this.branchName,
      existingBranch: existingBranch ?? this.existingBranch,
      errorMessage: errorMessage ?? this.errorMessage,
      createdTask: createdTask ?? this.createdTask,
    );
  }

  @override
  List<Object?> get props => [
        status,
        metadata,
        selectedProjectId,
        selectedStatusId,
        selectedPriorityId,
        selectedAssigneeId,
        selectedTagIds,
        title,
        description,
        estHours,
        estMinutes,
        dueDate,
        branchMode,
        branchName,
        existingBranch,
        errorMessage,
        createdTask,
      ];
}
