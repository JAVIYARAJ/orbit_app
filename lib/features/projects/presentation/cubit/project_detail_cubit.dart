import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:orbit_app/features/projects/domain/repositories/project_repository.dart';
import 'package:orbit_app/features/projects/presentation/cubit/project_detail_state.dart';

class ProjectDetailCubit extends Cubit<ProjectDetailState> {
  ProjectDetailCubit({required ProjectRepository repository})
      : _repository = repository,
        super(const ProjectDetailState());

  final ProjectRepository _repository;

  Future<void> fetchProjectDetail(String workstationId, String projectId) async {
    emit(state.copyWith(status: ProjectDetailStatus.loading));

    final result = await _repository.getProjectDetail(workstationId, projectId);
    
    result.fold(
      (failure) => emit(state.copyWith(
        status: ProjectDetailStatus.failure,
        errorMessage: failure.message,
      )),
      (project) async {
        emit(state.copyWith(
          status: ProjectDetailStatus.success,
          project: project,
        ));
        
        // Also fetch Github data if a repo is present
        if (project.repo != null && project.repo!.isNotEmpty) {
          _fetchGithubData(workstationId, project.repo!);
        }
      },
    );
  }
  
  Future<void> _fetchGithubData(String workstationId, String repoUrl) async {
    try {
      emit(state.copyWith(isGithubLoading: true));
      // Parse owner and repo from URL (e.g. https://github.com/JAVIYARAJ/orbit)
      final uri = Uri.parse(repoUrl);
      final pathSegments = uri.pathSegments;
      if (pathSegments.length >= 2) {
        final owner = pathSegments[0];
        final repo = pathSegments[1];
        
        final userResult = await _repository.getGithubUser(workstationId);
        final commitsResult = await _repository.getGithubCommits(workstationId, owner, repo);
        
        Map<String, dynamic>? user;
        List<dynamic> commits = [];
        
        userResult.fold((l) => null, (r) => user = r);
        commitsResult.fold((l) => null, (r) => commits = r);
        
        emit(state.copyWith(
          githubUser: user,
          githubCommits: commits,
          isGithubLoading: false,
        ));
      } else {
        emit(state.copyWith(isGithubLoading: false));
      }
    } catch (e) {
      print('Github fetch error: $e');
      emit(state.copyWith(isGithubLoading: false));
    }
  }
}
