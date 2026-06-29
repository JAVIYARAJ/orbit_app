import 'package:equatable/equatable.dart';
import 'package:orbit_app/features/projects/domain/entities/project_entity.dart';

enum ProjectsStatus { initial, loading, loaded, error }

class ProjectsState extends Equatable {
  const ProjectsState({
    this.status = ProjectsStatus.initial,
    this.projects = const [],
    this.errorMessage,
    this.searchQuery = '',
  });

  final ProjectsStatus status;
  final List<ProjectEntity> projects;
  final String? errorMessage;
  final String searchQuery;

  ProjectsState copyWith({
    ProjectsStatus? status,
    List<ProjectEntity>? projects,
    String? errorMessage,
    String? searchQuery,
  }) {
    return ProjectsState(
      status: status ?? this.status,
      projects: projects ?? this.projects,
      errorMessage: errorMessage ?? this.errorMessage,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [status, projects, errorMessage, searchQuery];
}
