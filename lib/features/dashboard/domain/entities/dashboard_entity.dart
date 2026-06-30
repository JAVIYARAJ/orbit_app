import 'package:equatable/equatable.dart';

class DashboardEntity extends Equatable {
  const DashboardEntity({
    required this.user,
    required this.notes,
    required this.projects,
    required this.templates,
    required this.workspace,
    required this.quickStats,
    required this.sprintRadar,
    required this.timeTracker,
  });

  final DashboardUser user;
  final List<DashboardNote> notes;
  final List<DashboardProject> projects;
  final List<DashboardTemplate> templates;
  final DashboardWorkspace workspace;
  final DashboardQuickStats quickStats;
  final DashboardSprintRadar sprintRadar;
  final DashboardTimeTracker timeTracker;

  @override
  List<Object?> get props => [
        user,
        notes,
        projects,
        templates,
        workspace,
        quickStats,
        sprintRadar,
        timeTracker,
      ];
}

class DashboardUser extends Equatable {
  const DashboardUser({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    required this.notificationCount,
  });

  final String id;
  final String name;
  final String email;
  final String? avatarUrl;
  final int notificationCount;

  @override
  List<Object?> get props => [id, name, email, avatarUrl, notificationCount];
}

class DashboardNote extends Equatable {
  const DashboardNote({
    required this.id,
    required this.title,
    required this.pinned,
    this.folderId,
    this.updatedAt,
    this.folderName,
  });

  final String id;
  final String title;
  final bool pinned;
  final String? folderId;
  final String? updatedAt;
  final String? folderName;

  @override
  List<Object?> get props => [id, title, pinned, folderId, updatedAt, folderName];
}

class DashboardProject extends Equatable {
  const DashboardProject({
    required this.id,
    required this.name,
    required this.client,
    required this.status,
    required this.shortId,
    required this.progress,
    required this.openTasks,
    required this.totalTasks,
    required this.hoursLogged,
    this.projectType,
    required this.completedTasks,
    required this.hoursEstimated,
  });

  final String id;
  final String name;
  final String client;
  final String status;
  final String shortId;
  final double progress;
  final int openTasks;
  final int totalTasks;
  final double hoursLogged;
  final DashboardProjectType? projectType;
  final int completedTasks;
  final double hoursEstimated;

  @override
  List<Object?> get props => [
        id,
        name,
        client,
        status,
        shortId,
        progress,
        openTasks,
        totalTasks,
        hoursLogged,
        projectType,
        completedTasks,
        hoursEstimated,
      ];
}

class DashboardProjectType extends Equatable {
  const DashboardProjectType({
    required this.id,
    required this.label,
  });

  final String id;
  final String label;

  @override
  List<Object?> get props => [id, label];
}

class DashboardTemplate extends Equatable {
  const DashboardTemplate({
    required this.id,
    required this.name,
    required this.category,
    this.updatedAt,
  });

  final String id;
  final String name;
  final String category;
  final String? updatedAt;

  @override
  List<Object?> get props => [id, name, category, updatedAt];
}

class DashboardWorkspace extends Equatable {
  const DashboardWorkspace({
    required this.id,
    required this.name,
    required this.color,
    required this.memberCount,
  });

  final String id;
  final String name;
  final String color;
  final int memberCount;

  @override
  List<Object?> get props => [id, name, color, memberCount];
}

class DashboardQuickStats extends Equatable {
  const DashboardQuickStats({
    required this.devStreak,
    required this.backlogTasks,
    required this.personalBest,
    required this.activeProjects,
    required this.hoursLoggedToday,
    required this.hoursLoggedLastWeek,
    required this.hoursLoggedThisWeek,
    required this.weekDifferenceMinutes,
  });

  final int devStreak;
  final int backlogTasks;
  final int personalBest;
  final int activeProjects;
  final double hoursLoggedToday;
  final double hoursLoggedLastWeek;
  final double hoursLoggedThisWeek;
  final int weekDifferenceMinutes;

  @override
  List<Object?> get props => [
        devStreak,
        backlogTasks,
        personalBest,
        activeProjects,
        hoursLoggedToday,
        hoursLoggedLastWeek,
        hoursLoggedThisWeek,
        weekDifferenceMinutes,
      ];
}

class DashboardSprintRadar extends Equatable {
  const DashboardSprintRadar({
    required this.count,
    required this.tasks,
  });

  final int count;
  final List<DashboardSprintTask> tasks;

  @override
  List<Object?> get props => [count, tasks];
}

class DashboardSprintTask extends Equatable {
  const DashboardSprintTask({
    required this.id,
    required this.title,
    required this.status,
    required this.taskId,
    this.dueDate,
    this.project,
    this.priority,
  });

  final String id;
  final String title;
  final DashboardTaskStatus status;
  final String taskId;
  final String? dueDate;
  final DashboardTaskProject? project;
  final DashboardTaskPriority? priority;

  @override
  List<Object?> get props => [
        id,
        title,
        status,
        taskId,
        dueDate,
        project,
        priority,
      ];
}

class DashboardTaskStatus extends Equatable {
  const DashboardTaskStatus({
    required this.id,
    required this.color,
    required this.label,
    required this.isDone,
  });

  final String id;
  final String color;
  final String label;
  final bool isDone;

  @override
  List<Object?> get props => [id, color, label, isDone];
}

class DashboardTaskProject extends Equatable {
  const DashboardTaskProject({
    required this.shortId,
  });

  final String shortId;

  @override
  List<Object?> get props => [shortId];
}

class DashboardTaskPriority extends Equatable {
  const DashboardTaskPriority({
    required this.id,
    required this.color,
    required this.label,
  });

  final String id;
  final String color;
  final String label;

  @override
  List<Object?> get props => [id, color, label];
}

class DashboardTimeTracker extends Equatable {
  const DashboardTimeTracker({
    required this.status,
    this.taskId,
    this.entryId,
    required this.running,
    this.projectId,
    this.startedAt,
    this.taskTitle,
    this.projectName,
    required this.elapsedSeconds,
  });

  final String status;
  final String? taskId;
  final String? entryId;
  final bool running;
  final String? projectId;
  final String? startedAt;
  final String? taskTitle;
  final String? projectName;
  final int elapsedSeconds;

  @override
  List<Object?> get props => [
        status,
        taskId,
        entryId,
        running,
        projectId,
        startedAt,
        taskTitle,
        projectName,
        elapsedSeconds,
      ];
}
