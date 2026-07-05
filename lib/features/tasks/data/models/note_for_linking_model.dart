import 'package:orbit_app/features/tasks/domain/entities/note_for_linking_entity.dart';

class NoteForLinkingModel extends NoteForLinkingEntity {
  const NoteForLinkingModel({
    required super.id,
    required super.title,
    required super.pinned,
    super.updatedAt,
    super.folderId,
    super.folderName,
  });

  factory NoteForLinkingModel.fromJson(Map<String, dynamic> json) {
    final folderMap = json['folder'] as Map<String, dynamic>?;
    return NoteForLinkingModel(
      id: json['id'] as String,
      title: json['title'] as String,
      pinned: json['pinned'] as bool? ?? false,
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt'] as String) : null,
      folderId: folderMap?['id'] as String?,
      folderName: folderMap?['name'] as String?,
    );
  }
}
