import 'package:equatable/equatable.dart';
import 'package:orbit_app/features/notes/domain/entities/note_folder_entity.dart';

enum NoteFoldersStatus { initial, loading, success, failure }

class NoteFoldersState extends Equatable {
  const NoteFoldersState({
    this.status = NoteFoldersStatus.initial,
    this.folders = const [],
    this.errorMessage,
    this.searchQuery = '',
  });

  final NoteFoldersStatus status;
  final List<NoteFolderEntity> folders;
  final String? errorMessage;
  final String searchQuery;

  NoteFoldersState copyWith({
    NoteFoldersStatus? status,
    List<NoteFolderEntity>? folders,
    String? errorMessage,
    String? searchQuery,
  }) {
    return NoteFoldersState(
      status: status ?? this.status,
      folders: folders ?? this.folders,
      errorMessage: errorMessage,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [status, folders, errorMessage, searchQuery];
}
