import 'package:equatable/equatable.dart';

abstract class ProjectsEvent extends Equatable {
  const ProjectsEvent();

  @override
  List<Object?> get props => [];
}

class FetchProjectsEvent extends ProjectsEvent {
  const FetchProjectsEvent(this.workstationId);

  final String workstationId;

  @override
  List<Object?> get props => [workstationId];
}

class SearchProjectsEvent extends ProjectsEvent {
  const SearchProjectsEvent(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}
