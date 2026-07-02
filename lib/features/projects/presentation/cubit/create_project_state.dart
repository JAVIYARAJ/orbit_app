import 'package:equatable/equatable.dart';

class CreateProjectState extends Equatable {
  const CreateProjectState({
    this.name = '',
    this.description = '',
    this.client = '',
    this.stack = '',
    this.budget = '',
    this.hours = '',
    this.status = 'planning',
    this.typeId,
    this.repoUrl = '',
    this.isCreatingNewRepo = false,
    this.newRepoName = '',
    this.isPrivateRepo = false,
    this.startDate,
    this.endDate,
    this.types = const [],
    this.githubRepos = const [],
    this.isLoading = false,
    this.isSubmitting = false,
    this.error,
    this.isSuccess = false,
    this.isEdit = false,
    this.editProjectId,
    this.tasksCount = 0,
    this.openTasks = 0,
    this.hoursLogged = 0,
    this.progress = 0,
  });

  final String name;
  final String description;
  final String client;
  final String stack;
  final String budget;
  final String hours;
  final String status;
  final String? typeId;
  final String repoUrl;
  final bool isCreatingNewRepo;
  final String newRepoName;
  final bool isPrivateRepo;
  final DateTime? startDate;
  final DateTime? endDate;
  final List<dynamic> types;
  final List<dynamic> githubRepos;
  final bool isLoading;
  final bool isSubmitting;
  final String? error;
  final bool isSuccess;
  final bool isEdit;
  final String? editProjectId;
  final int tasksCount;
  final int openTasks;
  final num hoursLogged;
  final num progress;

  CreateProjectState copyWith({
    String? name,
    String? description,
    String? client,
    String? stack,
    String? budget,
    String? hours,
    String? status,
    String? typeId,
    String? repoUrl,
    bool? isCreatingNewRepo,
    String? newRepoName,
    bool? isPrivateRepo,
    DateTime? startDate,
    DateTime? endDate,
    List<dynamic>? types,
    List<dynamic>? githubRepos,
    bool? isLoading,
    bool? isSubmitting,
    String? error,
    bool? isSuccess,
    bool? isEdit,
    String? editProjectId,
    int? tasksCount,
    int? openTasks,
    num? hoursLogged,
    num? progress,
  }) {
    return CreateProjectState(
      name: name ?? this.name,
      description: description ?? this.description,
      client: client ?? this.client,
      stack: stack ?? this.stack,
      budget: budget ?? this.budget,
      hours: hours ?? this.hours,
      status: status ?? this.status,
      typeId: typeId ?? this.typeId,
      repoUrl: repoUrl ?? this.repoUrl,
      isCreatingNewRepo: isCreatingNewRepo ?? this.isCreatingNewRepo,
      newRepoName: newRepoName ?? this.newRepoName,
      isPrivateRepo: isPrivateRepo ?? this.isPrivateRepo,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      types: types ?? this.types,
      githubRepos: githubRepos ?? this.githubRepos,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: error ?? this.error,
      isSuccess: isSuccess ?? this.isSuccess,
      isEdit: isEdit ?? this.isEdit,
      editProjectId: editProjectId ?? this.editProjectId,
      tasksCount: tasksCount ?? this.tasksCount,
      openTasks: openTasks ?? this.openTasks,
      hoursLogged: hoursLogged ?? this.hoursLogged,
      progress: progress ?? this.progress,
    );
  }

  CreateProjectState clearError() {
    return CreateProjectState(
      name: name,
      description: description,
      client: client,
      stack: stack,
      budget: budget,
      hours: hours,
      status: status,
      typeId: typeId,
      repoUrl: repoUrl,
      isCreatingNewRepo: isCreatingNewRepo,
      newRepoName: newRepoName,
      isPrivateRepo: isPrivateRepo,
      startDate: startDate,
      endDate: endDate,
      types: types,
      githubRepos: githubRepos,
      isLoading: isLoading,
      isSubmitting: isSubmitting,
      error: null,
      isSuccess: isSuccess,
      isEdit: isEdit,
      editProjectId: editProjectId,
      tasksCount: tasksCount,
      openTasks: openTasks,
      hoursLogged: hoursLogged,
      progress: progress,
    );
  }

  @override
  List<Object?> get props => [
        name,
        description,
        client,
        stack,
        budget,
        hours,
        status,
        typeId,
        repoUrl,
        isCreatingNewRepo,
        newRepoName,
        isPrivateRepo,
        startDate,
        endDate,
        types,
        githubRepos,
        isLoading,
        isSubmitting,
        error,
        isSuccess,
        isEdit,
        editProjectId,
        tasksCount,
        openTasks,
        hoursLogged,
        progress,
      ];
}
