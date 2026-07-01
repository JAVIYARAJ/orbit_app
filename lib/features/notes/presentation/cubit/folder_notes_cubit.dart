import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:orbit_app/features/notes/domain/usecases/get_folder_notes_use_case.dart';
import 'package:orbit_app/features/notes/presentation/cubit/folder_notes_state.dart';

class FolderNotesCubit extends Cubit<FolderNotesState> {
  FolderNotesCubit(this._getFolderNotes) : super(const FolderNotesState());

  final GetFolderNotesUseCase _getFolderNotes;

  Future<void> fetchFolderNotes(String workstationId, String folderId) async {
    emit(state.copyWith(status: FolderNotesStatus.loading));
    final result = await _getFolderNotes(
      GetFolderNotesParams(workstationId: workstationId, folderId: folderId),
    );
    result.fold(
      (failure) => emit(state.copyWith(
        status: FolderNotesStatus.failure,
        errorMessage: failure.message,
      )),
      (notes) => emit(state.copyWith(
        status: FolderNotesStatus.success,
        notes: notes,
      )),
    );
  }

  void searchNotes(String query) {
    emit(state.copyWith(searchQuery: query));
  }
}
