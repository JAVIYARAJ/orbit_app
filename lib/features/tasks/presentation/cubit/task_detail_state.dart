import 'package:equatable/equatable.dart';
import 'package:orbit_app/features/tasks/domain/entities/task_detail_entity.dart';
import 'package:orbit_app/features/tasks/domain/entities/task_entity.dart';
import 'package:orbit_app/features/tasks/domain/entities/note_for_linking_entity.dart';

enum TaskDetailStatus { initial, loading, success, failure }

class TaskDetailState extends Equatable {
  const TaskDetailState({
    this.status = TaskDetailStatus.initial,
    this.taskDetail,
    this.errorMessage,
    this.isSaving = false,
    this.isDeleted = false,
    this.projectTasks = const [],
    this.notesForLinking = const [],
    this.isAttachmentUploading = false,
  });

  final TaskDetailStatus status;
  final TaskDetailEntity? taskDetail;
  final String? errorMessage;
  final bool isSaving;
  final bool isDeleted;
  final List<TaskEntity> projectTasks;
  final List<NoteForLinkingEntity> notesForLinking;
  final bool isAttachmentUploading;

  TaskDetailState copyWith({
    TaskDetailStatus? status,
    TaskDetailEntity? taskDetail,
    String? errorMessage,
    bool? isSaving,
    bool? isDeleted,
    List<TaskEntity>? projectTasks,
    List<NoteForLinkingEntity>? notesForLinking,
    bool? isAttachmentUploading,
  }) {
    return TaskDetailState(
      status: status ?? this.status,
      taskDetail: taskDetail ?? this.taskDetail,
      errorMessage: errorMessage ?? this.errorMessage,
      isSaving: isSaving ?? this.isSaving,
      isDeleted: isDeleted ?? this.isDeleted,
      projectTasks: projectTasks ?? this.projectTasks,
      notesForLinking: notesForLinking ?? this.notesForLinking,
      isAttachmentUploading: isAttachmentUploading ?? this.isAttachmentUploading,
    );
  }

  @override
  List<Object?> get props => [status, taskDetail, errorMessage, isSaving, isDeleted, projectTasks, notesForLinking, isAttachmentUploading];
}
