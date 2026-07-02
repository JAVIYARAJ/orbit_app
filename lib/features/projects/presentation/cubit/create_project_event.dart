import 'package:equatable/equatable.dart';
import 'package:orbit_app/features/projects/domain/entities/project_entity.dart';

abstract class CreateProjectEvent extends Equatable {
  const CreateProjectEvent();

  @override
  List<Object?> get props => [];
}

class FetchMetadataEvent extends CreateProjectEvent {
  const FetchMetadataEvent(this.workstationId);
  final String workstationId;

  @override
  List<Object?> get props => [workstationId];
}

class InitEditProjectEvent extends CreateProjectEvent {
  const InitEditProjectEvent(this.initialProject);
  final ProjectEntity initialProject;

  @override
  List<Object?> get props => [initialProject];
}

class UpdateFieldEvent extends CreateProjectEvent {
  const UpdateFieldEvent({
    this.name,
    this.description,
    this.client,
    this.stack,
    this.budget,
    this.hours,
    this.status,
    this.typeId,
    this.repoUrl,
    this.isCreatingNewRepo,
    this.newRepoName,
    this.isPrivateRepo,
    this.startDate,
    this.endDate,
  });

  final String? name;
  final String? description;
  final String? client;
  final String? stack;
  final String? budget;
  final String? hours;
  final String? status;
  final String? typeId;
  final String? repoUrl;
  final bool? isCreatingNewRepo;
  final String? newRepoName;
  final bool? isPrivateRepo;
  final DateTime? startDate;
  final DateTime? endDate;

  @override
  List<Object?> get props => [
        name,
        description,
        client,
        stack,
        budget,
        hours,
        status,
        typeId,
        repoUrl,
        isCreatingNewRepo,
        newRepoName,
        isPrivateRepo,
        startDate,
        endDate,
      ];
}

class ClearErrorEvent extends CreateProjectEvent {}

class SubmitProjectEvent extends CreateProjectEvent {
  const SubmitProjectEvent(this.workstationId);
  final String workstationId;

  @override
  List<Object?> get props => [workstationId];
}
