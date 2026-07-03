import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:orbit_app/core/services/task_metadata_service.dart';
import 'package:orbit_app/features/tasks/domain/usecases/create_task_usecase.dart';
import 'package:orbit_app/features/tasks/domain/entities/task_entity.dart';
import 'create_task_event.dart';
import 'create_task_state.dart';

class CreateTaskBloc extends Bloc<CreateTaskEvent, CreateTaskState> {
  final TaskMetadataService _taskMetadataService;
  final CreateTaskUseCase _createTaskUseCase;

  CreateTaskBloc({
    required TaskMetadataService taskMetadataService,
    required CreateTaskUseCase createTaskUseCase,
  })  : _taskMetadataService = taskMetadataService,
        _createTaskUseCase = createTaskUseCase,
        super(const CreateTaskState()) {
    on<FetchMetadataEvent>(_onFetchMetadata);
    on<UpdateFieldEvent>(_onUpdateField);
    on<SubmitTaskEvent>(_onSubmitTask);
  }

  Future<void> _onFetchMetadata(FetchMetadataEvent event, Emitter<CreateTaskState> emit) async {
    emit(state.copyWith(status: CreateTaskStatus.loading));
    try {
      final metadata = await _taskMetadataService.getTaskMetadata(event.workstationId);
      
      String? defaultStatusId;
      final statuses = metadata['statuses'] as List<dynamic>? ?? [];
      if (statuses.isNotEmpty) {
        defaultStatusId = statuses.first['id'] as String;
      }

      String? defaultPriorityId;
      final priorities = metadata['priorities'] as List<dynamic>? ?? [];
      if (priorities.isNotEmpty) {
        final normal = priorities.firstWhere(
          (p) => (p['label'] as String).toLowerCase() == 'normal',
          orElse: () => priorities.first,
        );
        defaultPriorityId = normal['id'] as String;
      }

      String? defaultProjectId;
      final projects = metadata['projects'] as List<dynamic>? ?? [];
      if (projects.isNotEmpty) {
        defaultProjectId = projects.first['shortId'] as String;
      }

      emit(state.copyWith(
        status: CreateTaskStatus.loaded,
        metadata: metadata,
        selectedStatusId: defaultStatusId,
        selectedPriorityId: defaultPriorityId,
        selectedProjectId: defaultProjectId,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: CreateTaskStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  void _onUpdateField(UpdateFieldEvent event, Emitter<CreateTaskState> emit) {
    emit(state.copyWith(
      title: event.title,
      description: event.description,
      selectedProjectId: event.projectId,
      selectedStatusId: event.statusId,
      selectedPriorityId: event.priorityId,
      selectedAssigneeId: event.assigneeId,
      selectedTagIds: event.selectedTagIds,
      estHours: event.estHours,
      estMinutes: event.estMinutes,
      dueDate: event.dueDate,
      branchMode: event.branchMode,
      branchName: event.branchName,
      existingBranch: event.existingBranch,
    ));
  }

  String _getTaskPrefix(String projectName) {
    final clean = projectName.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');
    return clean.isEmpty ? 'TSK' : clean.substring(0, clean.length > 3 ? 3 : clean.length);
  }

  int _getNextTaskNum(String projectShortId, String prefix, List<TaskEntity> existingTasks) {
    final re = RegExp('^$prefix-(\\d+)\$');
    int maxNum = 0;
    
    for (final task in existingTasks) {
      if (task.projectShortId == projectShortId) {
        final m = re.firstMatch(task.taskId);
        if (m != null) {
          final num = int.tryParse(m.group(1)!) ?? 0;
          if (num > maxNum) maxNum = num;
        }
      }
    }
    return maxNum + 1;
  }

  Future<void> _onSubmitTask(SubmitTaskEvent event, Emitter<CreateTaskState> emit) async {
    if (state.title.isEmpty) {
      emit(state.copyWith(status: CreateTaskStatus.error, errorMessage: 'Title is required'));
      emit(state.copyWith(status: CreateTaskStatus.loaded, errorMessage: null));
      return;
    }

    if (state.selectedProjectId == null) {
      emit(state.copyWith(status: CreateTaskStatus.error, errorMessage: 'Project is required'));
      emit(state.copyWith(status: CreateTaskStatus.loaded, errorMessage: null));
      return;
    }

    emit(state.copyWith(status: CreateTaskStatus.creating));

    final projects = state.metadata['projects'] as List<dynamic>? ?? [];
    final project = projects.firstWhere((p) => p['shortId'] == state.selectedProjectId, orElse: () => null);
    final projectName = project != null ? project['name'] as String : '';
    
    final prefix = _getTaskPrefix(projectName);
    final num = _getNextTaskNum(state.selectedProjectId!, prefix, event.existingTasks);
    final newTaskId = '$prefix-$num';

    final data = <String, dynamic>{
      'task_id': newTaskId,
      'project_short_id': state.selectedProjectId,
      'status_id': state.selectedStatusId,
      'priority_id': state.selectedPriorityId,
      'title': state.title,
      'description': state.description,
      if (state.dueDate != null) 'due_date': state.dueDate!.toIso8601String().split('T').first,
      'tag_ids': state.selectedTagIds,
      'est_minutes': (state.estHours * 60) + state.estMinutes,
      if (state.selectedAssigneeId != null) 'assignee_id': state.selectedAssigneeId,
      if (state.branchMode == BranchMode.create && state.branchName.isNotEmpty) 'gh_branch': state.branchName,
      if (state.branchMode == BranchMode.existing && state.existingBranch.isNotEmpty) 'gh_branch': state.existingBranch,
    };

    final result = await _createTaskUseCase(CreateTaskParams(
      workstationId: event.workstationId,
      data: data,
    ));

    result.match(
      (failure) {
        emit(state.copyWith(
          status: CreateTaskStatus.error,
          errorMessage: failure.message,
        ));
      },
      (task) {
        emit(state.copyWith(status: CreateTaskStatus.success, createdTask: task));
      },
    );
  }
}
