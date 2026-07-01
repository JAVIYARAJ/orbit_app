import 'package:orbit_app/core/utils/typedefs.dart';
import 'package:orbit_app/features/notes/domain/entities/note_folder_entity.dart';
import 'package:orbit_app/features/notes/domain/entities/note_entity.dart';

abstract interface class NoteRepository {
  ResultFuture<List<NoteFolderEntity>> getNoteFolders(String workstationId);
  ResultFuture<List<NoteEntity>> getFolderNotes(String workstationId, String folderId);
}
