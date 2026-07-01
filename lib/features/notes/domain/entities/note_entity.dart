import 'package:equatable/equatable.dart';

class NoteEntity extends Equatable {
  const NoteEntity({
    required this.id,
    this.folderId,
    required this.title,
    required this.body,
    required this.color,
    required this.pinned,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String? folderId;
  final String title;
  final String body;
  final String color;
  final bool pinned;
  final String? createdAt;
  final String? updatedAt;

  @override
  List<Object?> get props => [
        id,
        folderId,
        title,
        body,
        color,
        pinned,
        createdAt,
        updatedAt,
      ];
}
