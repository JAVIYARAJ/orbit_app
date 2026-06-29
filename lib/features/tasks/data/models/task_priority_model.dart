import 'package:orbit_app/features/tasks/domain/entities/task_priority_entity.dart';

class TaskPriorityModel extends TaskPriorityEntity {
  const TaskPriorityModel({
    required super.id,
    required super.color,
    required super.label,
    required super.sortOrder,
  });

  factory TaskPriorityModel.fromJson(Map<String, dynamic> json) {
    return TaskPriorityModel(
      id: json['id'] as String,
      color: json['color'] as String,
      label: json['label'] as String,
      sortOrder: json['sort_order'] as int,
    );
  }
}
