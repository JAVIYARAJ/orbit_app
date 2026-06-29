import 'package:equatable/equatable.dart';
import 'package:orbit_app/features/authentication/domain/entities/user_entity.dart';
import 'package:orbit_app/features/workspaces/domain/entities/workstation_entity.dart';

class WorkspaceContextEntity extends Equatable {
  const WorkspaceContextEntity({
    required this.user,
    required this.workstations,
    this.activeWorkstationId,
  });

  final UserEntity user;
  final List<WorkstationEntity> workstations;
  final String? activeWorkstationId;

  @override
  List<Object?> get props => [user, workstations, activeWorkstationId];
}
