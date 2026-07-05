import 'package:orbit_app/core/utils/typedefs.dart';
import 'package:orbit_app/core/utils/use_case.dart';
import 'package:orbit_app/features/tasks/domain/repositories/task_repository.dart';

class UploadTaskAttachmentUseCase implements UseCaseWithParams<void, UploadTaskAttachmentParams> {
  const UploadTaskAttachmentUseCase(this._repository);

  final TaskRepository _repository;

  @override
  ResultFuture<void> call(UploadTaskAttachmentParams params) {
    return _repository.uploadTaskAttachment(
      workstationId: params.workstationId,
      taskId: params.taskId,
      fileBytes: params.fileBytes,
      fileName: params.fileName,
      mimeType: params.mimeType,
    );
  }
}

class UploadTaskAttachmentParams {
  const UploadTaskAttachmentParams({
    required this.workstationId,
    required this.taskId,
    required this.fileBytes,
    required this.fileName,
    required this.mimeType,
  });

  final String workstationId;
  final String taskId;
  final List<int> fileBytes;
  final String fileName;
  final String? mimeType;
}
