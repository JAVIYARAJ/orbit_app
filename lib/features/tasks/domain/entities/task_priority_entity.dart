import 'package:equatable/equatable.dart';

class TaskPriorityEntity extends Equatable {
  const TaskPriorityEntity({
    required this.id,
    required this.color,
    required this.label,
    required this.sortOrder,
  });

  final String id;
  final String color;
  final String label;
  final int sortOrder;

  @override
  List<Object?> get props => [id, color, label, sortOrder];
}
