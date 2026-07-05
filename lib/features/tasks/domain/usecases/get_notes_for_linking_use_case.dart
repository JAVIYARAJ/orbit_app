import 'package:orbit_app/core/utils/typedefs.dart';
import 'package:orbit_app/core/utils/use_case.dart';
import 'package:orbit_app/features/tasks/domain/entities/note_for_linking_entity.dart';
import 'package:orbit_app/features/tasks/domain/repositories/task_repository.dart';

class GetNotesForLinkingUseCase implements UseCaseWithParams<List<NoteForLinkingEntity>, String> {
  const GetNotesForLinkingUseCase(this._repository);

  final TaskRepository _repository;

  @override
  ResultFuture<List<NoteForLinkingEntity>> call(String workstationId) {
    return _repository.getNotesForLinking(
      workstationId: workstationId,
    );
  }
}
