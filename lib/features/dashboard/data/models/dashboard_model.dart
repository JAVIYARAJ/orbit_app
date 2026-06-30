import 'package:orbit_app/features/dashboard/domain/entities/dashboard_entity.dart';

class DashboardModel extends DashboardEntity {
  const DashboardModel({
    required super.user,
    required super.notes,
    required super.projects,
    required super.templates,
    required super.workspace,
    required super.quickStats,
    required super.sprintRadar,
    required super.timeTracker,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    return DashboardModel(
      user: DashboardUserModel.fromJson(json['user'] as Map<String, dynamic>),
      notes: (json['notes'] as List<dynamic>?)
              ?.map((e) => DashboardNoteModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      projects: (json['projects'] as List<dynamic>?)
              ?.map((e) => DashboardProjectModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      templates: (json['templates'] as List<dynamic>?)
              ?.map((e) => DashboardTemplateModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      workspace: DashboardWorkspaceModel.fromJson(json['workspace'] as Map<String, dynamic>),
      quickStats: DashboardQuickStatsModel.fromJson(json['quickStats'] as Map<String, dynamic>),
      sprintRadar: DashboardSprintRadarModel.fromJson(json['sprintRadar'] as Map<String, dynamic>),
      timeTracker: DashboardTimeTrackerModel.fromJson(json['timeTracker'] as Map<String, dynamic>),
    );
  }
}

class DashboardUserModel extends DashboardUser {
  const DashboardUserModel({
    required super.id,
    required super.name,
    required super.email,
    super.avatarUrl,
    required super.notificationCount,
  });

  factory DashboardUserModel.fromJson(Map<String, dynamic> json) {
    return DashboardUserModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      avatarUrl: json['avatarUrl'] as String?,
      notificationCount: (json['notificationCount'] as num?)?.toInt() ?? 0,
    );
  }
}

class DashboardNoteModel extends DashboardNote {
  const DashboardNoteModel({
    required super.id,
    required super.title,
    required super.pinned,
    super.folderId,
    super.updatedAt,
    super.folderName,
  });

  factory DashboardNoteModel.fromJson(Map<String, dynamic> json) {
    return DashboardNoteModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      pinned: json['pinned'] as bool? ?? false,
      folderId: json['folderId'] as String?,
      updatedAt: json['updatedAt'] as String?,
      folderName: json['folderName'] as String?,
    );
  }
}

class DashboardProjectModel extends DashboardProject {
  const DashboardProjectModel({
    required super.id,
    required super.name,
    required super.client,
    required super.status,
    required super.shortId,
    required super.progress,
    required super.openTasks,
    required super.totalTasks,
    required super.hoursLogged,
    super.projectType,
    required super.completedTasks,
    required super.hoursEstimated,
  });

  factory DashboardProjectModel.fromJson(Map<String, dynamic> json) {
    return DashboardProjectModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      client: json['client'] as String? ?? '',
      status: json['status'] as String? ?? '',
      shortId: json['shortId'] as String? ?? '',
      progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
      openTasks: (json['openTasks'] as num?)?.toInt() ?? 0,
      totalTasks: (json['totalTasks'] as num?)?.toInt() ?? 0,
      hoursLogged: (json['hoursLogged'] as num?)?.toDouble() ?? 0.0,
      projectType: json['projectType'] != null
          ? DashboardProjectTypeModel.fromJson(json['projectType'] as Map<String, dynamic>)
          : null,
      completedTasks: (json['completedTasks'] as num?)?.toInt() ?? 0,
      hoursEstimated: (json['hoursEstimated'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class DashboardProjectTypeModel extends DashboardProjectType {
  const DashboardProjectTypeModel({
    required super.id,
    required super.label,
  });

  factory DashboardProjectTypeModel.fromJson(Map<String, dynamic> json) {
    return DashboardProjectTypeModel(
      id: json['id'] as String? ?? '',
      label: json['label'] as String? ?? '',
    );
  }
}

class DashboardTemplateModel extends DashboardTemplate {
  const DashboardTemplateModel({
    required super.id,
    required super.name,
    required super.category,
    super.updatedAt,
  });

  factory DashboardTemplateModel.fromJson(Map<String, dynamic> json) {
    return DashboardTemplateModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      category: json['category'] as String? ?? '',
      updatedAt: json['updatedAt'] as String?,
    );
  }
}

class DashboardWorkspaceModel extends DashboardWorkspace {
  const DashboardWorkspaceModel({
    required super.id,
    required super.name,
    required super.color,
    required super.memberCount,
  });

  factory DashboardWorkspaceModel.fromJson(Map<String, dynamic> json) {
    return DashboardWorkspaceModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      color: json['color'] as String? ?? '',
      memberCount: (json['memberCount'] as num?)?.toInt() ?? 0,
    );
  }
}

class DashboardQuickStatsModel extends DashboardQuickStats {
  const DashboardQuickStatsModel({
    required super.devStreak,
    required super.backlogTasks,
    required super.personalBest,
    required super.activeProjects,
    required super.hoursLoggedToday,
    required super.hoursLoggedLastWeek,
    required super.hoursLoggedThisWeek,
    required super.weekDifferenceMinutes,
  });

  factory DashboardQuickStatsModel.fromJson(Map<String, dynamic> json) {
    return DashboardQuickStatsModel(
      devStreak: (json['devStreak'] as num?)?.toInt() ?? 0,
      backlogTasks: (json['backlogTasks'] as num?)?.toInt() ?? 0,
      personalBest: (json['personalBest'] as num?)?.toInt() ?? 0,
      activeProjects: (json['activeProjects'] as num?)?.toInt() ?? 0,
      hoursLoggedToday: (json['hoursLoggedToday'] as num?)?.toDouble() ?? 0.0,
      hoursLoggedLastWeek: (json['hoursLoggedLastWeek'] as num?)?.toDouble() ?? 0.0,
      hoursLoggedThisWeek: (json['hoursLoggedThisWeek'] as num?)?.toDouble() ?? 0.0,
      weekDifferenceMinutes: (json['weekDifferenceMinutes'] as num?)?.toInt() ?? 0,
    );
  }
}

class DashboardSprintRadarModel extends DashboardSprintRadar {
  const DashboardSprintRadarModel({
    required super.count,
    required super.tasks,
  });

  factory DashboardSprintRadarModel.fromJson(Map<String, dynamic> json) {
    return DashboardSprintRadarModel(
      count: (json['count'] as num?)?.toInt() ?? 0,
      tasks: (json['tasks'] as List<dynamic>?)
              ?.map((e) => DashboardSprintTaskModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class DashboardSprintTaskModel extends DashboardSprintTask {
  const DashboardSprintTaskModel({
    required super.id,
    required super.title,
    required super.status,
    required super.taskId,
    super.dueDate,
    super.project,
    super.priority,
  });

  factory DashboardSprintTaskModel.fromJson(Map<String, dynamic> json) {
    return DashboardSprintTaskModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      status: DashboardTaskStatusModel.fromJson(json['status'] as Map<String, dynamic>),
      taskId: json['taskId'] as String? ?? '',
      dueDate: json['dueDate'] as String?,
      project: json['project'] != null
          ? DashboardTaskProjectModel.fromJson(json['project'] as Map<String, dynamic>)
          : null,
      priority: json['priority'] != null
          ? DashboardTaskPriorityModel.fromJson(json['priority'] as Map<String, dynamic>)
          : null,
    );
  }
}

class DashboardTaskStatusModel extends DashboardTaskStatus {
  const DashboardTaskStatusModel({
    required super.id,
    required super.color,
    required super.label,
    required super.isDone,
  });

  factory DashboardTaskStatusModel.fromJson(Map<String, dynamic> json) {
    return DashboardTaskStatusModel(
      id: json['id'] as String? ?? '',
      color: json['color'] as String? ?? '',
      label: json['label'] as String? ?? '',
      isDone: json['isDone'] as bool? ?? false,
    );
  }
}

class DashboardTaskProjectModel extends DashboardTaskProject {
  const DashboardTaskProjectModel({
    required super.shortId,
  });

  factory DashboardTaskProjectModel.fromJson(Map<String, dynamic> json) {
    return DashboardTaskProjectModel(
      shortId: json['shortId'] as String? ?? '',
    );
  }
}

class DashboardTaskPriorityModel extends DashboardTaskPriority {
  const DashboardTaskPriorityModel({
    required super.id,
    required super.color,
    required super.label,
  });

  factory DashboardTaskPriorityModel.fromJson(Map<String, dynamic> json) {
    return DashboardTaskPriorityModel(
      id: json['id'] as String? ?? '',
      color: json['color'] as String? ?? '',
      label: json['label'] as String? ?? '',
    );
  }
}

class DashboardTimeTrackerModel extends DashboardTimeTracker {
  const DashboardTimeTrackerModel({
    required super.status,
    super.taskId,
    super.entryId,
    required super.running,
    super.projectId,
    super.startedAt,
    super.taskTitle,
    super.projectName,
    required super.elapsedSeconds,
  });

  factory DashboardTimeTrackerModel.fromJson(Map<String, dynamic> json) {
    return DashboardTimeTrackerModel(
      status: json['status'] as String? ?? '',
      taskId: json['taskId'] as String?,
      entryId: json['entryId'] as String?,
      running: json['running'] as bool? ?? false,
      projectId: json['projectId'] as String?,
      startedAt: json['startedAt'] as String?,
      taskTitle: json['taskTitle'] as String?,
      projectName: json['projectName'] as String?,
      elapsedSeconds: (json['elapsedSeconds'] as num?)?.toInt() ?? 0,
    );
  }
}
