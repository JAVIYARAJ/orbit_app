import 'package:orbit_app/core/utils/typedefs.dart';
import 'package:orbit_app/features/tasks/domain/entities/tasks_data_entity.dart';

abstract interface class TaskRepository {
  ResultFuture<TasksDataEntity> getWorkstationTasks(String workstationId);
}
