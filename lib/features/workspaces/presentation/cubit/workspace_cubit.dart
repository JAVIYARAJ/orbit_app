import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:orbit_app/features/workspaces/domain/entities/workstation_entity.dart';
import 'package:orbit_app/features/workspaces/domain/usecases/get_my_context_use_case.dart';
import 'package:orbit_app/features/workspaces/presentation/cubit/workspace_state.dart';

class WorkspaceCubit extends Cubit<WorkspaceState> {
  WorkspaceCubit({
    required GetMyContextUseCase getMyContext,
  })  : _getMyContext = getMyContext,
        super(const WorkspaceState());

  final GetMyContextUseCase _getMyContext;

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
    // Usually we would also call an API to save this preference,
    // but for now local state is sufficient.
  }
}
