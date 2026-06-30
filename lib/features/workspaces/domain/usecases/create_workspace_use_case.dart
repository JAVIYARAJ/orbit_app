import 'package:orbit_app/core/utils/typedefs.dart';
import 'package:orbit_app/features/workspaces/domain/repositories/workspace_repository.dart';

class CreateWorkspaceUseCase {
  const CreateWorkspaceUseCase(this._repository);

  final WorkspaceRepository _repository;

  ResultFuture<void> call(String name, String color) =>
      _repository.createWorkstation(name, color);
}
