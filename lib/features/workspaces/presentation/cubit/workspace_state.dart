import 'package:equatable/equatable.dart';
import 'package:orbit_app/features/workspaces/domain/entities/workspace_context_entity.dart';
import 'package:orbit_app/features/workspaces/domain/entities/workstation_entity.dart';

enum WorkspaceStatus { initial, loading, loaded, error }

class WorkspaceState extends Equatable {
  const WorkspaceState({
    this.status = WorkspaceStatus.initial,
    this.contextEntity,
    this.selectedWorkstation,
    this.errorMessage,
  });

  final WorkspaceStatus status;
  final WorkspaceContextEntity? contextEntity;
  final WorkstationEntity? selectedWorkstation;
  final String? errorMessage;

  WorkspaceState copyWith({
    WorkspaceStatus? status,
    WorkspaceContextEntity? contextEntity,
    WorkstationEntity? selectedWorkstation,
    String? errorMessage,
  }) {
    return WorkspaceState(
      status: status ?? this.status,
      contextEntity: contextEntity ?? this.contextEntity,
      selectedWorkstation: selectedWorkstation ?? this.selectedWorkstation,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props =>
      [status, contextEntity, selectedWorkstation, errorMessage];
}
