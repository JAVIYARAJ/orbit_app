import 'package:equatable/equatable.dart';

class TaskStatusEntity extends Equatable {
  const TaskStatusEntity({
    required this.id,
    required this.key,
    required this.color,
    required this.label,
    required this.isDone,
    required this.sortOrder,
  });

  final String id;
  final String key;
  final String color;
  final String label;
  final bool isDone;
  final int sortOrder;

  @override
  List<Object?> get props => [id, key, color, label, isDone, sortOrder];
}
