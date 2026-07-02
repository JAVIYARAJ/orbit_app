import 'package:equatable/equatable.dart';
import 'package:orbit_app/features/tasks/domain/entities/task_detail_entity.dart';

enum TaskDetailStatus { initial, loading, success, failure }

class TaskDetailState extends Equatable {
  const TaskDetailState({
    this.status = TaskDetailStatus.initial,
    this.taskDetail,
    this.errorMessage,
    this.isSaving = false,
  });

  final TaskDetailStatus status;
  final TaskDetailEntity? taskDetail;
  final String? errorMessage;
  final bool isSaving;

  TaskDetailState copyWith({
    TaskDetailStatus? status,
    TaskDetailEntity? taskDetail,
    String? errorMessage,
    bool? isSaving,
  }) {
    return TaskDetailState(
      status: status ?? this.status,
      taskDetail: taskDetail ?? this.taskDetail,
      errorMessage: errorMessage ?? this.errorMessage,
      isSaving: isSaving ?? this.isSaving,
    );
  }

  @override
  List<Object?> get props => [status, taskDetail, errorMessage, isSaving];
}
