import 'package:orbit_app/core/utils/typedefs.dart';
import 'package:orbit_app/core/utils/use_case.dart';
import 'package:orbit_app/features/tasks/domain/repositories/task_repository.dart';

class LogManualTimeUseCase implements UseCaseWithParams<void, LogManualTimeParams> {
  const LogManualTimeUseCase(this._repository);

  final TaskRepository _repository;

  @override
  ResultFuture<void> call(LogManualTimeParams params) {
    return _repository.logManualTime(
      workstationId: params.workstationId,
      projectId: params.projectId,
      taskId: params.taskId,
      minutes: params.minutes,
      notes: params.notes,
    );
  }
}

class LogManualTimeParams {
  const LogManualTimeParams({
    required this.workstationId,
    required this.projectId,
    required this.taskId,
    required this.minutes,
    required this.notes,
  });

  final String workstationId;
  final String projectId;
  final String taskId;
  final int minutes;
  final String notes;
}
