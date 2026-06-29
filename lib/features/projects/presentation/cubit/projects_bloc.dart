import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:orbit_app/features/projects/domain/usecases/get_workstation_projects_use_case.dart';
import 'package:orbit_app/features/projects/presentation/cubit/projects_state.dart';
import 'package:orbit_app/features/projects/presentation/cubit/projects_event.dart';

class ProjectsBloc extends Bloc<ProjectsEvent, ProjectsState> {
  ProjectsBloc(this._getWorkstationProjects) : super(const ProjectsState()) {
    on<FetchProjectsEvent>(_onFetchProjects);
    on<SearchProjectsEvent>(_onSearchProjects);
  }

  final GetWorkstationProjectsUseCase _getWorkstationProjects;

  Future<void> _onFetchProjects(FetchProjectsEvent event, Emitter<ProjectsState> emit) async {
    emit(state.copyWith(status: ProjectsStatus.loading));
    final result = await _getWorkstationProjects(event.workstationId);
    result.match(
      (failure) => emit(state.copyWith(
        status: ProjectsStatus.error,
        errorMessage: failure.message,
      )),
      (projects) => emit(state.copyWith(
        status: ProjectsStatus.loaded,
        projects: projects,
      )),
    );
  }

  void _onSearchProjects(SearchProjectsEvent event, Emitter<ProjectsState> emit) {
    emit(state.copyWith(searchQuery: event.query));
  }
}
