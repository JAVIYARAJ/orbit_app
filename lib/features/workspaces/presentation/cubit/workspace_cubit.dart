import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:orbit_app/features/workspaces/domain/entities/workstation_entity.dart';
import 'package:orbit_app/features/workspaces/domain/usecases/create_workspace_use_case.dart';
import 'package:orbit_app/features/workspaces/domain/usecases/get_my_context_use_case.dart';
import 'package:orbit_app/features/workspaces/domain/usecases/switch_workspace_use_case.dart';
import 'package:orbit_app/features/workspaces/presentation/cubit/workspace_state.dart';

class WorkspaceCubit extends Cubit<WorkspaceState> {
  WorkspaceCubit({
    required GetMyContextUseCase getMyContext,
    required CreateWorkspaceUseCase createWorkspace,
    required SwitchWorkspaceUseCase switchWorkspace,
  })  : _getMyContext = getMyContext,
        _createWorkspace = createWorkspace,
        _switchWorkspace = switchWorkspace,
        super(const WorkspaceState());

  final GetMyContextUseCase _getMyContext;
  final CreateWorkspaceUseCase _createWorkspace;
  final SwitchWorkspaceUseCase _switchWorkspace;

  Future<void> fetchContext() async {
    emit(state.copyWith(status: WorkspaceStatus.loading));
    final result = await _getMyContext();
    result.match(
      (failure) => emit(state.copyWith(
        status: WorkspaceStatus.error,
        errorMessage: failure.message,
      )),
      (contextEntity) {
        WorkstationEntity? selected;
        if (contextEntity.activeWorkstationId != null) {
          try {
            selected = contextEntity.workstations.firstWhere(
                (w) => w.id == contextEntity.activeWorkstationId);
          } catch (_) {}
        }
        emit(state.copyWith(
          status: WorkspaceStatus.loaded,
          contextEntity: contextEntity,
          selectedWorkstation: selected,
        ));
      },
    );
  }

  void selectWorkstation(WorkstationEntity workstation) {
    emit(state.copyWith(selectedWorkstation: workstation));
    // Fire and forget the switch RPC so the backend tracks the current workspace.
    _switchWorkspace(workstation.id);
  }

  Future<void> createWorkstation(String name, String color) async {
    final previousWorkstations = state.contextEntity?.workstations.map((w) => w.id).toSet() ?? {};
    
    emit(state.copyWith(status: WorkspaceStatus.loading));
    final result = await _createWorkspace(name, color);
    
    result.fold(
      (failure) => emit(state.copyWith(
        status: WorkspaceStatus.error,
        errorMessage: failure.message,
      )),
      (_) {
        // Fetch context again to get the newly created workspace in the list
        fetchContext().then((_) {
          final newWorkstations = state.contextEntity?.workstations ?? [];
          try {
            final newWs = newWorkstations.firstWhere((w) => !previousWorkstations.contains(w.id));
            selectWorkstation(newWs);
          } catch (_) {}
        });
      },
    );
  }
}
