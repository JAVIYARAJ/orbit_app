import 'package:equatable/equatable.dart';
import 'package:orbit_app/core/utils/typedefs.dart';
import 'package:orbit_app/core/utils/use_case.dart';
import 'package:orbit_app/features/notes/domain/entities/note_entity.dart';
import 'package:orbit_app/features/notes/domain/repositories/note_repository.dart';

class GetFolderNotesParams extends Equatable {
  const GetFolderNotesParams({required this.workstationId, required this.folderId});
  
  final String workstationId;
  final String folderId;

  @override
  List<Object?> get props => [workstationId, folderId];
}

class GetFolderNotesUseCase extends UseCaseWithParams<List<NoteEntity>, GetFolderNotesParams> {
  const GetFolderNotesUseCase(this._repository);

  final NoteRepository _repository;

  @override
  ResultFuture<List<NoteEntity>> call(GetFolderNotesParams params) => 
      _repository.getFolderNotes(params.workstationId, params.folderId);
}
