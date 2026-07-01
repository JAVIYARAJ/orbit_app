import 'package:orbit_app/core/errors/exceptions.dart';
import 'package:orbit_app/features/notes/data/models/note_folder_model.dart';
import 'package:orbit_app/features/notes/data/models/note_model.dart';
import 'package:orbit_app/features/notes/domain/entities/note_folder_entity.dart';
import 'package:orbit_app/features/notes/domain/entities/note_entity.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class NoteRemoteDataSource {
  Future<List<NoteFolderEntity>> getNoteFolders(String workstationId);
  Future<List<NoteEntity>> getFolderNotes(String workstationId, String folderId);
}

class NoteRemoteDataSourceImpl implements NoteRemoteDataSource {
  const NoteRemoteDataSourceImpl(this._client);

  final SupabaseClient _client;

  @override
  Future<List<NoteFolderEntity>> getNoteFolders(String workstationId) async {
    try {
      final response = await _client.rpc<dynamic>(
        'get_note_folders',
        params: {'p_workstation_id': workstationId},
      );
      
      // Response might contain a map with a 'folders' key or list directly
      final List<dynamic> foldersList;
      if (response is Map && response.containsKey('folders')) {
        foldersList = response['folders'] as List<dynamic>;
      } else if (response is List) {
        foldersList = response;
      } else {
        foldersList = [];
      }
      
      return foldersList.map((f) => NoteFolderModel.fromJson(f as Map<String, dynamic>)).toList();
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<NoteEntity>> getFolderNotes(String workstationId, String folderId) async {
    try {
      final response = await _client.rpc<dynamic>(
        'get_folder_notes',
        params: {
          'p_workstation_id': workstationId,
          'p_folder_id': folderId,
        },
      );
      
      final List<dynamic> notesList;
      if (response is Map && response.containsKey('notes')) {
        notesList = response['notes'] as List<dynamic>;
      } else {
        notesList = [];
      }
      
      return notesList.map((n) => NoteModel.fromJson(n as Map<String, dynamic>)).toList();
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
