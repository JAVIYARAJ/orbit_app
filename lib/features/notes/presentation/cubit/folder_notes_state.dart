import 'package:equatable/equatable.dart';
import 'package:orbit_app/features/notes/domain/entities/note_entity.dart';

enum FolderNotesStatus { initial, loading, success, failure }

class FolderNotesState extends Equatable {
  const FolderNotesState({
    this.status = FolderNotesStatus.initial,
    this.notes = const [],
    this.errorMessage,
    this.searchQuery = '',
  });

  final FolderNotesStatus status;
  final List<NoteEntity> notes;
  final String? errorMessage;
  final String searchQuery;

  FolderNotesState copyWith({
    FolderNotesStatus? status,
    List<NoteEntity>? notes,
    String? errorMessage,
    String? searchQuery,
  }) {
    return FolderNotesState(
      status: status ?? this.status,
      notes: notes ?? this.notes,
      errorMessage: errorMessage,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [status, notes, errorMessage, searchQuery];
}
