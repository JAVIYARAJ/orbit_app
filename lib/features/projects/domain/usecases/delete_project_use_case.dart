import 'package:orbit_app/core/utils/typedefs.dart';
import 'package:orbit_app/core/utils/use_case.dart';
import 'package:orbit_app/features/projects/domain/repositories/project_repository.dart';

class DeleteProjectUseCase extends UseCaseWithParams<void, String> {
  const DeleteProjectUseCase(this._repository);

  final ProjectRepository _repository;

  @override
  ResultFuture<void> call(String params) => _repository.deleteProject(params);
}
