import 'package:orbit_app/core/utils/use_case.dart';
import 'package:orbit_app/core/utils/typedefs.dart';
import 'package:orbit_app/features/tasks/domain/entities/task_entity.dart';
import 'package:orbit_app/features/tasks/domain/repositories/task_repository.dart';
import 'package:equatable/equatable.dart';

class CreateTaskUseCase extends UseCaseWithParams<TaskEntity, CreateTaskParams> {
  CreateTaskUseCase(this._repository);
  final TaskRepository _repository;

  @override
  ResultFuture<TaskEntity> call(CreateTaskParams params) {
    return _repository.createTask(params.workstationId, params.data);
  }
}

class CreateTaskParams extends Equatable {
  const CreateTaskParams({
    required this.workstationId,
    required this.data,
  });

  final String workstationId;
  final Map<String, dynamic> data;

  @override
  List<Object?> get props => [workstationId, data];
}
