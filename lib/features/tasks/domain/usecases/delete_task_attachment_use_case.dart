import 'package:orbit_app/core/utils/typedefs.dart';
import 'package:orbit_app/core/utils/use_case.dart';
import 'package:orbit_app/features/tasks/domain/repositories/task_repository.dart';

class DeleteTaskAttachmentUseCase implements UseCaseWithParams<void, DeleteTaskAttachmentParams> {
  const DeleteTaskAttachmentUseCase(this._repository);

  final TaskRepository _repository;

  @override
  ResultFuture<void> call(DeleteTaskAttachmentParams params) {
    return _repository.deleteTaskAttachment(
      attachmentId: params.attachmentId,
    );
  }
}

class DeleteTaskAttachmentParams {
  const DeleteTaskAttachmentParams({
    required this.attachmentId,
  });

  final String attachmentId;
}
