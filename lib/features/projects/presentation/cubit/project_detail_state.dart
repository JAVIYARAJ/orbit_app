import 'package:equatable/equatable.dart';
import 'package:orbit_app/features/projects/domain/entities/project_entity.dart';

enum ProjectDetailStatus { initial, loading, success, failure, deleting, deleted }

class ProjectDetailState extends Equatable {
  const ProjectDetailState({
    this.status = ProjectDetailStatus.initial,
    this.project,
    this.githubUser,
    this.githubCommits = const [],
    this.isGithubLoading = false,
    this.errorMessage,
  });

  final ProjectDetailStatus status;
  final ProjectEntity? project;
  final Map<String, dynamic>? githubUser;
  final List<dynamic> githubCommits;
  final bool isGithubLoading;
  final String? errorMessage;

  ProjectDetailState copyWith({
    ProjectDetailStatus? status,
    ProjectEntity? project,
    Map<String, dynamic>? githubUser,
    List<dynamic>? githubCommits,
    bool? isGithubLoading,
    String? errorMessage,
  }) {
    return ProjectDetailState(
      status: status ?? this.status,
      project: project ?? this.project,
      githubUser: githubUser ?? this.githubUser,
      githubCommits: githubCommits ?? this.githubCommits,
      isGithubLoading: isGithubLoading ?? this.isGithubLoading,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, project, githubUser, githubCommits, isGithubLoading, errorMessage];
}
