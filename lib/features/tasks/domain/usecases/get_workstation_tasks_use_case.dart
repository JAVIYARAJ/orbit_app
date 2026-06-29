import 'package:orbit_app/core/utils/typedefs.dart';
import 'package:orbit_app/core/utils/use_case.dart';
import 'package:orbit_app/features/tasks/domain/entities/tasks_data_entity.dart';
import 'package:orbit_app/features/tasks/domain/repositories/task_repository.dart';

class GetWorkstationTasksUseCase extends UseCaseWithParams<TasksDataEntity, String> {
  const GetWorkstationTasksUseCase(this._repository);

  final TaskRepository _repository;

  @override
  ResultFuture<TasksDataEntity> call(String params) => _repository.getWorkstationTasks(params);
}
