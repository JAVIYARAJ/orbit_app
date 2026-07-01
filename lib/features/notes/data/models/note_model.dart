import 'package:orbit_app/features/notes/domain/entities/note_entity.dart';

class NoteModel extends NoteEntity {
  const NoteModel({
    required super.id,
    super.folderId,
    required super.title,
    required super.body,
    required super.color,
    required super.pinned,
    super.createdAt,
    super.updatedAt,
  });

  factory NoteModel.fromJson(Map<String, dynamic> json) {
    return NoteModel(
      id: json['note_id'] as String? ?? json['id'] as String? ?? '',
      folderId: json['folder_id'] as String? ?? json['folderId'] as String?,
      title: json['title'] as String? ?? '',
      body: json['note'] as String? ?? json['body'] as String? ?? '',
      color: json['color'] as String? ?? 'blue',
      pinned: json['pinned'] as bool? ?? false,
      createdAt: json['created_at'] as String? ?? json['createdAt'] as String?,
      updatedAt: json['updated_at'] as String? ?? json['updatedAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'note_id': id,
      'folder_id': folderId,
      'title': title,
      'note': body,
      'color': color,
      'pinned': pinned,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
