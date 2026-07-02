import 'package:orbit_app/core/utils/typedefs.dart';
import 'package:orbit_app/core/utils/use_case.dart';
import 'package:orbit_app/features/tasks/domain/entities/task_detail_entity.dart';
import 'package:orbit_app/features/tasks/domain/repositories/task_repository.dart';

class UpdateTaskUseCase implements UseCaseWithParams<TaskDetailEntity, UpdateTaskParams> {
  UpdateTaskUseCase(this._repository);

  final TaskRepository _repository;

  @override
  ResultFuture<TaskDetailEntity> call(UpdateTaskParams params) {
    return _repository.updateTask(params.taskId, params.data);
  }
}

class UpdateTaskParams {
  const UpdateTaskParams({
    required this.taskId,
    required this.data,
  });

  final String taskId;
  final Map<String, dynamic> data;
}
