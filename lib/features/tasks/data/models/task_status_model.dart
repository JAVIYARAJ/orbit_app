import 'package:orbit_app/features/tasks/domain/entities/task_status_entity.dart';

class TaskStatusModel extends TaskStatusEntity {
  const TaskStatusModel({
    required super.id,
    required super.key,
    required super.color,
    required super.label,
    required super.isDone,
    required super.sortOrder,
  });

  factory TaskStatusModel.fromJson(Map<String, dynamic> json) {
    return TaskStatusModel(
      id: json['id'] as String,
      key: json['key'] as String,
      color: json['color'] as String,
      label: json['label'] as String,
      isDone: json['is_done'] as bool,
      sortOrder: json['sort_order'] as int,
    );
  }
}
