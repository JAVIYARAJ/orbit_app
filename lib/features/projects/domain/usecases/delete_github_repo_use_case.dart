import 'package:equatable/equatable.dart';
import 'package:orbit_app/core/utils/typedefs.dart';
import 'package:orbit_app/core/utils/use_case.dart';
import 'package:orbit_app/features/projects/domain/repositories/project_repository.dart';

class DeleteGithubRepoParams extends Equatable {
  const DeleteGithubRepoParams({required this.workstationId, required this.repoFullName});
  final String workstationId;
  final String repoFullName;

  @override
  List<Object?> get props => [workstationId, repoFullName];
}

class DeleteGithubRepoUseCase extends UseCaseWithParams<void, DeleteGithubRepoParams> {
  const DeleteGithubRepoUseCase(this._repository);

  final ProjectRepository _repository;

  @override
  ResultFuture<void> call(DeleteGithubRepoParams params) =>
      _repository.deleteGithubRepo(params.workstationId, params.repoFullName);
}
