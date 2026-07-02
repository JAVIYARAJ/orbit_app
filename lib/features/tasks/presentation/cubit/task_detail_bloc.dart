import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:orbit_app/features/tasks/domain/usecases/get_task_detail_use_case.dart';
import 'package:orbit_app/features/tasks/domain/usecases/update_task_use_case.dart';
import 'package:orbit_app/features/tasks/domain/usecases/add_task_comment_use_case.dart';
import 'package:orbit_app/features/tasks/domain/usecases/delete_task_comment_use_case.dart';
import 'package:orbit_app/features/tasks/domain/entities/task_detail_entity.dart';
import 'package:orbit_app/features/tasks/presentation/cubit/task_detail_event.dart';
import 'package:orbit_app/features/tasks/presentation/cubit/task_detail_state.dart';

class TaskDetailBloc extends Bloc<TaskDetailEvent, TaskDetailState> {
  TaskDetailBloc({
    required GetTaskDetailUseCase getTaskDetailUseCase,
    required UpdateTaskUseCase updateTaskUseCase,
    required AddTaskCommentUseCase addTaskCommentUseCase,
    required DeleteTaskCommentUseCase deleteTaskCommentUseCase,
  })  : _getTaskDetailUseCase = getTaskDetailUseCase,
        _updateTaskUseCase = updateTaskUseCase,
        _addTaskCommentUseCase = addTaskCommentUseCase,
        _deleteTaskCommentUseCase = deleteTaskCommentUseCase,
        super(const TaskDetailState()) {
    on<FetchTaskDetailEvent>(_onFetchTaskDetail);
    on<UpdateTaskStatusEvent>((e, emit) => _performUpdate(e.workstationId, e.taskId, {'status_id': e.statusId}, emit));
    on<UpdateTaskPriorityEvent>((e, emit) => _performUpdate(e.workstationId, e.taskId, {'priority_id': e.priorityId}, emit));
    on<UpdateTaskDueDateEvent>((e, emit) => _performUpdate(e.workstationId, e.taskId, {'due_date': e.dueDate?.toIso8601String() ?? ''}, emit));
    on<UpdateTaskAssigneeEvent>((e, emit) => _performUpdate(e.workstationId, e.taskId, {'assignee_id': e.assigneeId}, emit));
    on<UpdateTaskReporterEvent>((e, emit) => _performUpdate(e.workstationId, e.taskId, {'reporter_id': e.reporterId}, emit));
    on<UpdateTaskTagsEvent>((e, emit) => _performUpdate(e.workstationId, e.taskId, {'tags_entities': e.tags}, emit));
    on<UpdateTaskTitleEvent>((e, emit) => _performUpdate(e.workstationId, e.taskId, {'title': e.title}, emit));
    on<UpdateTaskDescriptionEvent>((e, emit) => _performUpdate(e.workstationId, e.taskId, {'description': e.description}, emit));
    on<AddTaskCommentEvent>(_onAddTaskComment);
    on<DeleteTaskCommentEvent>(_onDeleteTaskComment);
  }

  final GetTaskDetailUseCase _getTaskDetailUseCase;
  final UpdateTaskUseCase _updateTaskUseCase;
  final AddTaskCommentUseCase _addTaskCommentUseCase;
  final DeleteTaskCommentUseCase _deleteTaskCommentUseCase;

  Future<void> _onFetchTaskDetail(
    FetchTaskDetailEvent event,
    Emitter<TaskDetailState> emit,
  ) async {
    emit(state.copyWith(status: TaskDetailStatus.loading));

    final result = await _getTaskDetailUseCase(GetTaskDetailParams(
      workstationId: event.workstationId,
      taskId: event.taskId,
    ));

    result.fold(
      (failure) => emit(state.copyWith(
        status: TaskDetailStatus.failure,
        errorMessage: failure.message,
      )),
      (data) => emit(state.copyWith(
        status: TaskDetailStatus.success,
        taskDetail: data,
      )),
    );
  }

  Future<void> _performUpdate(
    String workstationId,
    String taskId,
    Map<String, dynamic> data,
    Emitter<TaskDetailState> emit,
  ) async {
    // Optimistic update
    if (state.taskDetail != null) {
      final currentTask = state.taskDetail!.task;
      final metadata = state.taskDetail!.metadata;
      
      TaskDetailDataEntity updatedTask = currentTask;
      if (data.containsKey('status_id')) {
        final newStatus = metadata.statuses.cast<TaskStatusItemEntity>().firstWhere((s) => s.id == data['status_id'], orElse: () => currentTask.status);
        updatedTask = updatedTask.copyWith(status: newStatus);
      }
      if (data.containsKey('priority_id')) {
        final newPriority = metadata.priorities.cast<TaskPriorityItemEntity>().firstWhere((p) => p.id == data['priority_id'], orElse: () => currentTask.priority!);
        updatedTask = updatedTask.copyWith(priority: newPriority);
      }
      if (data.containsKey('assignee_id')) {
        final newAssignee = metadata.members.cast<TaskUserItemEntity>().firstWhere((m) => m.id == data['assignee_id'], orElse: () => currentTask.assignee!);
        updatedTask = updatedTask.copyWith(assignee: newAssignee);
      }
      if (data.containsKey('reporter_id')) {
        final newReporter = metadata.members.cast<TaskUserItemEntity>().firstWhere((m) => m.id == data['reporter_id'], orElse: () => currentTask.reporter!);
        updatedTask = updatedTask.copyWith(reporter: newReporter);
      }
      if (data.containsKey('title')) {
        updatedTask = updatedTask.copyWith(title: data['title'].toString());
      }
      if (data.containsKey('description')) {
        updatedTask = updatedTask.copyWith(description: data['description'].toString());
      }
      if (data.containsKey('due_date')) {
        final dateStr = data['due_date'] as String?;
        if (dateStr == null || dateStr.isEmpty) {
          updatedTask = updatedTask.copyWith(clearDueDate: true);
        } else {
          updatedTask = updatedTask.copyWith(dueDate: DateTime.tryParse(dateStr));
        }
      }
      if (data.containsKey('tags_entities')) {
        final tagsList = data['tags_entities'] as List<TaskTagItemEntity>;
        
        // Optimistically update the UI with exactly the tags selected (including temp ones)
        updatedTask = updatedTask.copyWith(tags: tagsList);
        
        // Prepare the payload for the RPC
        final payloadTags = <Map<String, dynamic>>[];
        
        for (final t in tagsList) {
          if (t.id.isNotEmpty && !t.id.startsWith('temp_')) {
            payloadTags.add({'id': t.id});
          } else {
            payloadTags.add({'name': t.name, 'color': t.color});
          }
        }
        
        data['tags'] = payloadTags;
        data.remove('tags_entities');
      }

      emit(state.copyWith(
        isSaving: true,
        taskDetail: state.taskDetail!.copyWith(task: updatedTask),
      ));
    } else {
      emit(state.copyWith(isSaving: true));
    }

    final result = await _updateTaskUseCase(UpdateTaskParams(
      taskId: taskId,
      data: data,
    ));

    await result.fold(
      (failure) async {
        emit(state.copyWith(
          isSaving: false,
          errorMessage: failure.message,
        ));
      },
      (updateData) async {
        // Fetch fresh task details
        final fetchResult = await _getTaskDetailUseCase(GetTaskDetailParams(
          workstationId: workstationId,
          taskId: taskId,
        ));
        fetchResult.fold(
          (failure) => emit(state.copyWith(
            isSaving: false,
            errorMessage: failure.message,
          )),
          (freshData) => emit(state.copyWith(
            isSaving: false,
            taskDetail: freshData,
          )),
        );
      },
    );
  }

  Future<void> _onAddTaskComment(
    AddTaskCommentEvent event,
    Emitter<TaskDetailState> emit,
  ) async {
    emit(state.copyWith(isSaving: true));

    final result = await _addTaskCommentUseCase(AddTaskCommentParams(
      taskId: event.taskId,
      body: event.body,
      mentionedUserIds: event.mentionedUserIds,
      parentId: event.parentId,
    ));

    await result.fold(
      (failure) async {
        emit(state.copyWith(
          isSaving: false,
          errorMessage: failure.message,
        ));
      },
      (_) async {
        // Fetch fresh task details
        final fetchResult = await _getTaskDetailUseCase(GetTaskDetailParams(
          workstationId: event.workstationId,
          taskId: event.taskId,
        ));
        fetchResult.fold(
          (failure) => emit(state.copyWith(
            isSaving: false,
            errorMessage: failure.message,
          )),
          (freshData) => emit(state.copyWith(
            isSaving: false,
            taskDetail: freshData,
          )),
        );
      },
    );
  }

  Future<void> _onDeleteTaskComment(
    DeleteTaskCommentEvent event,
    Emitter<TaskDetailState> emit,
  ) async {
    emit(state.copyWith(isSaving: true));

    final result = await _deleteTaskCommentUseCase(event.commentId);

    await result.fold(
      (failure) async {
        emit(state.copyWith(
          isSaving: false,
          errorMessage: failure.message,
        ));
      },
      (_) async {
        // Fetch fresh task details
        final fetchResult = await _getTaskDetailUseCase(GetTaskDetailParams(
          workstationId: event.workstationId,
          taskId: event.taskId,
        ));
        fetchResult.fold(
          (failure) => emit(state.copyWith(
            isSaving: false,
            errorMessage: failure.message,
          )),
          (freshData) => emit(state.copyWith(
            isSaving: false,
            taskDetail: freshData,
          )),
        );
      },
    );
  }
}
