import 'package:orbit_app/core/utils/use_case.dart';
import 'package:orbit_app/core/utils/typedefs.dart';
import 'package:orbit_app/features/projects/domain/entities/project_entity.dart';
import 'package:orbit_app/features/projects/domain/repositories/project_repository.dart';

class CreateProjectParams {
  const CreateProjectParams({
    required this.workstationId,
    required this.projectData,
  });
  final String workstationId;
  final Map<String, dynamic> projectData;
}

class CreateProjectUseCase implements UseCaseWithParams<ProjectEntity, CreateProjectParams> {
  const CreateProjectUseCase(this._repository);
  final ProjectRepository _repository;

  @override
  ResultFuture<ProjectEntity> call(CreateProjectParams params) =>
      _repository.createProject(params.workstationId, params.projectData);
}
