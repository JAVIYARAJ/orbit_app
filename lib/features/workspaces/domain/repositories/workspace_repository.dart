import 'package:orbit_app/core/utils/typedefs.dart';
import 'package:orbit_app/features/workspaces/domain/entities/workspace_context_entity.dart';

abstract interface class WorkspaceRepository {
  ResultFuture<WorkspaceContextEntity> getMyContext();
  ResultFuture<void> createWorkstation(String name, String color);
  ResultFuture<void> switchActiveWorkstation(String workstationId);
}
