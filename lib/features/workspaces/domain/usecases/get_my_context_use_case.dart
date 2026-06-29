import 'package:orbit_app/core/utils/typedefs.dart';
import 'package:orbit_app/core/utils/use_case.dart';
import 'package:orbit_app/features/workspaces/domain/entities/workspace_context_entity.dart';
import 'package:orbit_app/features/workspaces/domain/repositories/workspace_repository.dart';

class GetMyContextUseCase extends UseCaseWithoutParams<WorkspaceContextEntity> {
  const GetMyContextUseCase(this._repository);

  final WorkspaceRepository _repository;

  @override
  ResultFuture<WorkspaceContextEntity> call() => _repository.getMyContext();
}
