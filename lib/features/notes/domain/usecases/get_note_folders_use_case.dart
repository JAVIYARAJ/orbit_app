import 'package:orbit_app/core/utils/typedefs.dart';
import 'package:orbit_app/core/utils/use_case.dart';
import 'package:orbit_app/features/notes/domain/entities/note_folder_entity.dart';
import 'package:orbit_app/features/notes/domain/repositories/note_repository.dart';

class GetNoteFoldersUseCase extends UseCaseWithParams<List<NoteFolderEntity>, String> {
  const GetNoteFoldersUseCase(this._repository);

  final NoteRepository _repository;

  @override
  ResultFuture<List<NoteFolderEntity>> call(String params) => _repository.getNoteFolders(params);
}
