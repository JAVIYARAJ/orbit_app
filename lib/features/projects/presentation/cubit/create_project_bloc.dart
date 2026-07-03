import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:orbit_app/core/services/project_metadata_service.dart';
import 'package:orbit_app/features/projects/domain/usecases/create_project_use_case.dart';
import 'package:orbit_app/features/projects/domain/usecases/update_project_use_case.dart';
import 'package:orbit_app/features/projects/presentation/cubit/create_project_event.dart';
import 'package:orbit_app/features/projects/presentation/cubit/create_project_state.dart';
import 'package:orbit_app/core/services/analytics_service.dart';

class CreateProjectBloc extends Bloc<CreateProjectEvent, CreateProjectState> {
  CreateProjectBloc({
    required ProjectMetadataService metadataService,
    required CreateProjectUseCase createProjectUseCase,
    required UpdateProjectUseCase updateProjectUseCase,
    required AnalyticsService analyticsService,
  })  : _metadataService = metadataService,
        _createProjectUseCase = createProjectUseCase,
        _updateProjectUseCase = updateProjectUseCase,
        _analyticsService = analyticsService,
        super(const CreateProjectState()) {
    on<FetchMetadataEvent>(_onFetchMetadata);
    on<InitEditProjectEvent>(_onInitEditProject);
    on<UpdateFieldEvent>(_onUpdateField);
    on<ClearErrorEvent>(_onClearError);
    on<SubmitProjectEvent>(_onSubmitProject);
  }

  final ProjectMetadataService _metadataService;
  final CreateProjectUseCase _createProjectUseCase;
  final UpdateProjectUseCase _updateProjectUseCase;
  final AnalyticsService _analyticsService;

  Future<void> _onFetchMetadata(FetchMetadataEvent event, Emitter<CreateProjectState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      final meta = await _metadataService.getProjectMetadata(event.workstationId);
      final types = (meta['projectTypes'] as List?) ?? [];
      String? typeId;
      if (types.isNotEmpty) {
        typeId = types.first['id'] as String;
      }

      final repos = await _metadataService.getGithubRepos(event.workstationId);

      emit(state.copyWith(
        isLoading: false,
        types: types,
        typeId: state.typeId ?? typeId,
        githubRepos: repos,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Failed to load metadata',
      ));
    }
  }

  void _onInitEditProject(InitEditProjectEvent event, Emitter<CreateProjectState> emit) {
    final project = event.initialProject;
    
    // Sanitize typeId: if it's not a valid UUID, don't use it.
    final uuidRegExp = RegExp(r'^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$', caseSensitive: false);
    String? validTypeId = project.projectTypeId;
    if (validTypeId != null && !uuidRegExp.hasMatch(validTypeId)) {
      validTypeId = null;
    }

    emit(state.copyWith(
      isEdit: true,
      editProjectId: project.shortId, // MUST be shortId as per RPC
      name: project.name,
      description: project.description ?? '',
      client: project.client ?? '',
      stack: project.stack.join(', '),
      budget: project.budget ?? '',
      hours: project.hoursEst?.toString() ?? '',
      status: project.status,
      typeId: validTypeId ?? state.typeId,
      repoUrl: project.repo ?? '',
      startDate: project.startDate,
      endDate: project.endDate,
      tasksCount: project.tasksCount,
      openTasks: project.openTasks,
      hoursLogged: project.hoursLogged,
      progress: project.progress,
    ));
  }

  void _onUpdateField(UpdateFieldEvent event, Emitter<CreateProjectState> emit) {
    emit(state.copyWith(
      name: event.name,
      description: event.description,
      client: event.client,
      stack: event.stack,
      budget: event.budget,
      hours: event.hours,
      status: event.status,
      typeId: event.typeId,
      repoUrl: event.repoUrl,
      isCreatingNewRepo: event.isCreatingNewRepo,
      newRepoName: event.newRepoName,
      isPrivateRepo: event.isPrivateRepo,
      startDate: event.startDate,
      endDate: event.endDate,
    ));
  }

  void _onClearError(ClearErrorEvent event, Emitter<CreateProjectState> emit) {
    emit(state.clearError());
  }

  Future<void> _onSubmitProject(SubmitProjectEvent event, Emitter<CreateProjectState> emit) async {
    final name = state.name.trim();
    if (name.isEmpty) {
      emit(state.copyWith(error: 'Project name is required.'));
      return;
    }

    if (state.startDate != null && state.endDate != null) {
      if (state.endDate!.isBefore(state.startDate!)) {
        emit(state.copyWith(error: 'End date cannot be before start date.'));
        return;
      }
    }

    if (state.isCreatingNewRepo && state.newRepoName.trim().isEmpty) {
      emit(state.copyWith(error: 'Repository name is required when creating a new repo.'));
      return;
    }

    if (!state.isCreatingNewRepo && state.repoUrl.trim().isNotEmpty) {
      final repoRegex = RegExp(r'^https?:\/\/(www\.)?github\.com\/[a-zA-Z0-9_.-]+\/[a-zA-Z0-9_.-]+\/?$');
      if (!repoRegex.hasMatch(state.repoUrl.trim())) {
        emit(state.copyWith(error: 'Repository must be a valid GitHub URL (e.g. https://github.com/user/repo).'));
        return;
      }
    }

    emit(state.copyWith(isSubmitting: true).clearError());

    try {
      final randomStr = DateTime.now().millisecondsSinceEpoch.toString();
      final shortId = name.toLowerCase().replaceAll(' ', '-').substring(0, name.length > 5 ? 5 : name.length) + '-' + randomStr.substring(randomStr.length - 4);

      String repoUrl = state.isCreatingNewRepo ? state.newRepoName.trim() : state.repoUrl;
      
      if (state.isCreatingNewRepo && state.newRepoName.trim().isNotEmpty) {
        try {
          final createdRepo = await _metadataService.createGithubRepo(
            workstationId: event.workstationId,
            name: state.newRepoName.trim(),
            isPrivate: state.isPrivateRepo,
            description: state.description.trim(),
          );
          if (createdRepo.containsKey('html_url')) {
            repoUrl = createdRepo['html_url'] as String;
          }
        } catch (e) {
          emit(state.copyWith(error: 'Failed to create GitHub repository', isSubmitting: false));
          return;
        }
      }

      final uuidRegExp = RegExp(r'^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$', caseSensitive: false);
      final safeTypeId = (state.typeId != null && uuidRegExp.hasMatch(state.typeId!)) ? state.typeId : null;

      final projectData = {
        if (!state.isEdit) 'short_id': shortId,
        'name': name,
        'client': state.client.trim().isEmpty ? 'Self' : state.client.trim(),
        'description': state.description.trim(),
        'project_type_id': safeTypeId,
        'start_date': state.startDate != null ? state.startDate!.toIso8601String().substring(0, 10) : DateTime.now().toIso8601String().substring(0, 10),
        'end_date': state.endDate != null ? state.endDate!.toIso8601String().substring(0, 10) : null,
        'status': state.status,
        'stack': state.stack.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
        'hours_est': int.tryParse(state.hours) ?? 0,
        'repo': repoUrl,
        'budget': state.budget.trim().isEmpty ? '—' : state.budget.trim(),
        'tasks_count': state.tasksCount,
        'open_tasks': state.openTasks,
        'hours_logged': state.hoursLogged,
        'progress': state.progress,
      };

      final result = state.isEdit && state.editProjectId != null
          ? await _updateProjectUseCase(UpdateProjectParams(
              shortId: state.editProjectId!,
              projectData: projectData,
            ))
          : await _createProjectUseCase(CreateProjectParams(
              workstationId: event.workstationId,
              projectData: projectData,
            ));

      result.fold(
        (l) => emit(state.copyWith(error: l.message, isSubmitting: false)),
        (r) {
          emit(state.copyWith(isSuccess: true, isSubmitting: false));
          if (state.isEdit && state.editProjectId != null) {
            _analyticsService.logUpdateProject(projectId: state.editProjectId!);
          } else {
            _analyticsService.logCreateProject(projectId: shortId, projectName: name);
          }
        },
      );
    } catch (e) {
      emit(state.copyWith(error: 'Failed to ${state.isEdit ? 'update' : 'create'} project', isSubmitting: false));
    }
  }
}
