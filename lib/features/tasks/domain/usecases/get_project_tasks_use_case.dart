import 'package:orbit_app/core/utils/typedefs.dart';
import 'package:orbit_app/core/utils/use_case.dart';
import 'package:orbit_app/features/tasks/domain/entities/task_entity.dart';
import 'package:orbit_app/features/tasks/domain/repositories/task_repository.dart';

class GetProjectTasksUseCase implements UseCaseWithParams<List<TaskEntity>, GetProjectTasksParams> {
  const GetProjectTasksUseCase(this._repository);

  final TaskRepository _repository;

  @override
  ResultFuture<List<TaskEntity>> call(GetProjectTasksParams params) {
    return _repository.getProjectTasks(
      workstationId: params.workstationId,
      projectShortId: params.projectShortId,
    );
  }
}

class GetProjectTasksParams {
  const GetProjectTasksParams({
    required this.workstationId,
    required this.projectShortId,
  });

  final String workstationId;
  final String projectShortId;
}
