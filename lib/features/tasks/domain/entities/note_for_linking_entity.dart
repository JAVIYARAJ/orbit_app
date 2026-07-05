import 'package:equatable/equatable.dart';

class NoteForLinkingEntity extends Equatable {
  const NoteForLinkingEntity({
    required this.id,
    required this.title,
    required this.pinned,
    this.updatedAt,
    this.folderId,
    this.folderName,
  });

  final String id;
  final String title;
  final bool pinned;
  final DateTime? updatedAt;
  final String? folderId;
  final String? folderName;

  @override
  List<Object?> get props => [id, title, pinned, updatedAt, folderId, folderName];
}
