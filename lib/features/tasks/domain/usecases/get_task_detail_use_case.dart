import 'package:orbit_app/core/utils/typedefs.dart';
import 'package:orbit_app/core/utils/use_case.dart';
import 'package:orbit_app/features/tasks/domain/entities/task_detail_entity.dart';
import 'package:orbit_app/features/tasks/domain/repositories/task_repository.dart';

class GetTaskDetailUseCase extends UseCaseWithParams<TaskDetailEntity, GetTaskDetailParams> {
  const GetTaskDetailUseCase(this._repository);

  final TaskRepository _repository;

  @override
  ResultFuture<TaskDetailEntity> call(GetTaskDetailParams params) {
    return _repository.getTaskDetail(params.workstationId, params.taskId);
  }
}

class GetTaskDetailParams {
  const GetTaskDetailParams({required this.workstationId, required this.taskId});
  final String workstationId;
  final String taskId;
}
