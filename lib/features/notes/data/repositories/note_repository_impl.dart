import 'package:fpdart/fpdart.dart';
import 'package:orbit_app/core/errors/exceptions.dart';
import 'package:orbit_app/core/errors/failures.dart';
import 'package:orbit_app/core/utils/typedefs.dart';
import 'package:orbit_app/features/notes/data/datasource/note_remote_data_source.dart';
import 'package:orbit_app/features/notes/domain/entities/note_entity.dart';
import 'package:orbit_app/features/notes/domain/entities/note_folder_entity.dart';
import 'package:orbit_app/features/notes/domain/repositories/note_repository.dart';

class NoteRepositoryImpl implements NoteRepository {
  const NoteRepositoryImpl(this._remoteDataSource);

  final NoteRemoteDataSource _remoteDataSource;

  @override
  ResultFuture<List<NoteFolderEntity>> getNoteFolders(String workstationId) async {
    try {
      final folders = await _remoteDataSource.getNoteFolders(workstationId);
      return Right(folders);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  ResultFuture<List<NoteEntity>> getFolderNotes(String workstationId, String folderId) async {
    try {
      final notes = await _remoteDataSource.getFolderNotes(workstationId, folderId);
      return Right(notes);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
