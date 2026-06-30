import 'package:orbit_app/features/projects/domain/entities/project_entity.dart';

class ProjectModel extends ProjectEntity {
  const ProjectModel({
    required super.id,
    required super.name,
    super.repo,
    super.stack = const [],
    super.budget,
    super.client,
    required super.status,
    required super.userId,
    super.endDate,
    super.progress = 0,
    required super.shortId,
    super.hoursEst,
    super.createdAt,
    super.createdBy,
    super.deletedAt,
    super.deletedBy,
    super.openTasks = 0,
    super.startDate,
    super.updatedAt,
    super.updatedBy,
    super.description,
    super.tasksCount = 0,
    super.hoursLogged = 0.0,
    required super.workstationId,
    super.projectTypeId,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      id: json['id'] as String,
      name: json['name'] as String,
      repo: json['repo'] as String?,
      stack: (json['stack'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      budget: json['budget']?.toString(),
      client: json['client'] as String?,
      status: json['status'] as String,
      userId: (json['user_id'] ?? json['userId'] ?? '') as String,
      endDate: json['end_date'] != null || json['endDate'] != null
          ? DateTime.tryParse((json['end_date'] ?? json['endDate']) as String)
          : null,
      progress: json['progress'] as num? ?? 0,
      shortId: (json['short_id'] ?? json['shortId'] ?? '') as String,
      hoursEst: (json['hours_est'] ?? json['hoursEstimated'] ?? json['hoursEst']) as num?,
      createdAt: json['created_at'] != null || json['createdAt'] != null
          ? DateTime.tryParse((json['created_at'] ?? json['createdAt']) as String)
          : null,
      createdBy: (json['created_by'] ?? json['createdBy']) as String?,
      deletedAt: json['deleted_at'] != null || json['deletedAt'] != null
          ? DateTime.tryParse((json['deleted_at'] ?? json['deletedAt']) as String)
          : null,
      deletedBy: (json['deleted_by'] ?? json['deletedBy']) as String?,
      openTasks: (json['open_tasks'] ?? json['openTasks']) as int? ?? 0,
      startDate: json['start_date'] != null || json['startDate'] != null
          ? DateTime.tryParse((json['start_date'] ?? json['startDate']) as String)
          : null,
      updatedAt: json['updated_at'] != null || json['updatedAt'] != null
          ? DateTime.tryParse((json['updated_at'] ?? json['updatedAt']) as String)
          : null,
      updatedBy: (json['updated_by'] ?? json['updatedBy']) as String?,
      description: json['description'] as String?,
      tasksCount: (json['tasks_count'] ?? json['totalTasks'] ?? json['tasksCount']) as int? ?? 0,
      hoursLogged: (json['hours_logged'] ?? json['hoursLogged']) as num? ?? 0.0,
      workstationId: (json['workstation_id'] ?? json['workstationId'] ?? '') as String,
      projectTypeId: (json['project_type_id'] ?? json['projectTypeId']) as String?,
    );
  }
}
