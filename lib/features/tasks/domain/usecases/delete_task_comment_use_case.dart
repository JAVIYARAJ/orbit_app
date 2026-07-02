import 'package:orbit_app/core/utils/typedefs.dart';
import 'package:orbit_app/core/utils/use_case.dart';
import 'package:orbit_app/features/tasks/domain/repositories/task_repository.dart';

class DeleteTaskCommentUseCase extends UseCaseWithParams<void, String> {
  const DeleteTaskCommentUseCase(this._repository);

  final TaskRepository _repository;

  @override
  ResultFuture<void> call(String params) {
    return _repository.deleteTaskComment(params);
  }
}
