import 'package:orbit_app/core/utils/typedefs.dart';
import 'package:orbit_app/core/utils/use_case.dart';
import 'package:orbit_app/features/tasks/domain/repositories/task_repository.dart';

class AddTaskCommentUseCase extends UseCaseWithParams<void, AddTaskCommentParams> {
  const AddTaskCommentUseCase(this._repository);

  final TaskRepository _repository;

  @override
  ResultFuture<void> call(AddTaskCommentParams params) {
    return _repository.addTaskComment(
      params.taskId,
      params.body,
      params.mentionedUserIds,
      params.parentId,
    );
  }
}

class AddTaskCommentParams {
  const AddTaskCommentParams({
    required this.taskId,
    required this.body,
    required this.mentionedUserIds,
    this.parentId,
  });

  final String taskId;
  final String body;
  final List<String> mentionedUserIds;
  final String? parentId;
}
