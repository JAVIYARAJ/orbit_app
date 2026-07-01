import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:orbit_app/features/notes/domain/usecases/get_note_folders_use_case.dart';
import 'package:orbit_app/features/notes/presentation/cubit/note_folders_state.dart';

class NoteFoldersCubit extends Cubit<NoteFoldersState> {
  NoteFoldersCubit(this._getNoteFolders) : super(const NoteFoldersState());

  final GetNoteFoldersUseCase _getNoteFolders;

  Future<void> fetchNoteFolders(String workstationId) async {
    emit(state.copyWith(status: NoteFoldersStatus.loading));
    final result = await _getNoteFolders(workstationId);
    result.fold(
      (failure) => emit(state.copyWith(
        status: NoteFoldersStatus.failure,
        errorMessage: failure.message,
      )),
      (folders) {
        final sorted = List.of(folders)..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
        emit(state.copyWith(
          status: NoteFoldersStatus.success,
          folders: sorted,
        ));
      },
    );
  }

  void searchFolders(String query) {
    emit(state.copyWith(searchQuery: query));
  }
}
