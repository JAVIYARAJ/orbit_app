import 'package:orbit_app/core/utils/use_case.dart';
import 'package:orbit_app/core/utils/typedefs.dart';
import 'package:orbit_app/features/tasks/domain/repositories/task_repository.dart';

class DeleteTaskUseCase extends UseCaseWithParams<void, String> {
  const DeleteTaskUseCase(this._repository);

  final TaskRepository _repository;

  @override
  ResultFuture<void> call(String params) => _repository.deleteTask(params);
}
