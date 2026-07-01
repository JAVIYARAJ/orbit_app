import 'package:equatable/equatable.dart';

class NoteFolderEntity extends Equatable {
  const NoteFolderEntity({
    required this.id,
    required this.name,
    required this.sortOrder,
    required this.notesCount,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String name;
  final int sortOrder;
  final int notesCount;
  final String? createdAt;
  final String? updatedAt;

  @override
  List<Object?> get props => [id, name, sortOrder, notesCount, createdAt, updatedAt];
}
