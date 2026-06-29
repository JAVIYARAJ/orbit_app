import 'package:orbit_app/core/utils/typedefs.dart';
import 'package:orbit_app/core/utils/use_case.dart';
import 'package:orbit_app/features/projects/domain/entities/project_entity.dart';
import 'package:orbit_app/features/projects/domain/repositories/project_repository.dart';

class GetWorkstationProjectsUseCase extends UseCaseWithParams<List<ProjectEntity>, String> {
  const GetWorkstationProjectsUseCase(this._repository);

  final ProjectRepository _repository;

  @override
  ResultFuture<List<ProjectEntity>> call(String params) => _repository.getWorkstationProjects(params);
}
