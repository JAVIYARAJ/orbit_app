import 'package:orbit_app/core/utils/typedefs.dart';
import 'package:orbit_app/features/workspaces/domain/repositories/workspace_repository.dart';

class SwitchWorkspaceUseCase {
  const SwitchWorkspaceUseCase(this._repository);

  final WorkspaceRepository _repository;

  ResultFuture<void> call(String params) => _repository.switchActiveWorkstation(params);
}
