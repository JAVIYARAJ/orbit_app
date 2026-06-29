import 'package:equatable/equatable.dart';

class ProjectEntity extends Equatable {
  const ProjectEntity({
    required this.id,
    required this.name,
    this.repo,
    this.stack = const [],
    this.budget,
    this.client,
    required this.status,
    required this.userId,
    this.endDate,
    this.progress = 0,
    required this.shortId,
    this.hoursEst,
    this.createdAt,
    this.createdBy,
    this.deletedAt,
    this.deletedBy,
    this.openTasks = 0,
    this.startDate,
    this.updatedAt,
    this.updatedBy,
    this.description,
    this.tasksCount = 0,
    this.hoursLogged = 0.0,
    required this.workstationId,
    this.projectTypeId,
  });

  final String id;
  final String name;
  final String? repo;
  final List<String> stack;
  final String? budget;
  final String? client;
  final String status;
  final String userId;
  final DateTime? endDate;
  final num progress;
  final String shortId;
  final num? hoursEst;
  final DateTime? createdAt;
  final String? createdBy;
  final DateTime? deletedAt;
  final String? deletedBy;
  final int openTasks;
  final DateTime? startDate;
  final DateTime? updatedAt;
  final String? updatedBy;
  final String? description;
  final int tasksCount;
  final num hoursLogged;
  final String workstationId;
  final String? projectTypeId;

  @override
  List<Object?> get props => [
        id,
        name,
        repo,
        stack,
        budget,
        client,
        status,
        userId,
        endDate,
        progress,
        shortId,
        hoursEst,
        createdAt,
        createdBy,
        deletedAt,
        deletedBy,
        openTasks,
        startDate,
        updatedAt,
        updatedBy,
        description,
        tasksCount,
        hoursLogged,
        workstationId,
        projectTypeId,
      ];
}
