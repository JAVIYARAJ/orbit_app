import 'package:orbit_app/features/notes/domain/entities/note_folder_entity.dart';

class NoteFolderModel extends NoteFolderEntity {
  const NoteFolderModel({
    required super.id,
    required super.name,
    required super.sortOrder,
    required super.notesCount,
    super.createdAt,
    super.updatedAt,
  });

  factory NoteFolderModel.fromJson(Map<String, dynamic> json) {
    return NoteFolderModel(
      id: json['id'] as String? ?? json['folder_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      sortOrder: ((json['sortOrder'] ?? json['sort_order']) as num?)?.toInt() ?? 0,
      notesCount: ((json['notesCount'] ?? json['notes_count']) as num?)?.toInt() ?? 0,
      createdAt: json['createdAt'] as String? ?? json['created_at'] as String?,
      updatedAt: json['updatedAt'] as String? ?? json['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'sortOrder': sortOrder,
      'notesCount': notesCount,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
