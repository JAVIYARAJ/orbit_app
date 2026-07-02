import 'package:orbit_app/core/utils/use_case.dart';
import 'package:orbit_app/core/utils/typedefs.dart';
import 'package:orbit_app/features/projects/domain/entities/project_entity.dart';
import 'package:orbit_app/features/projects/domain/repositories/project_repository.dart';

class UpdateProjectParams {
  const UpdateProjectParams({
    required this.shortId,
    required this.projectData,
  });
  final String shortId;
  final Map<String, dynamic> projectData;
}

class UpdateProjectUseCase implements UseCaseWithParams<ProjectEntity, UpdateProjectParams> {
  const UpdateProjectUseCase(this._repository);
  final ProjectRepository _repository;

  @override
  ResultFuture<ProjectEntity> call(UpdateProjectParams params) =>
      _repository.updateProject(params.shortId, params.projectData);
}
