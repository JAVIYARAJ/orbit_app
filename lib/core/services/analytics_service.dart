import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  // -- User Properties --

  Future<void> setUserId(String userId) async {
    await _analytics.setUserId(id: userId);
  }

  Future<void> setUserEmail(String email) async {
    await _analytics.setUserProperty(name: 'email', value: email);
  }

  Future<void> clearUser() async {
    await _analytics.setUserId(id: null);
    await _analytics.setUserProperty(name: 'email', value: null);
  }

  // -- Auth Events --

  Future<void> logLogin({String? loginMethod}) async {
    await _analytics.logLogin(loginMethod: loginMethod);
  }

  Future<void> logLogout() async {
    await _analytics.logEvent(name: 'logout');
    await clearUser();
  }

  // -- Project Events --

  Future<void> logCreateProject({required String projectId, required String projectName}) async {
    await _analytics.logEvent(
      name: 'create_project',
      parameters: {
        'project_id': projectId,
        'project_name': projectName,
      },
    );
  }

  Future<void> logUpdateProject({required String projectId}) async {
    await _analytics.logEvent(
      name: 'update_project',
      parameters: {
        'project_id': projectId,
      },
    );
  }

  Future<void> logDeleteProject({required String projectId}) async {
    await _analytics.logEvent(
      name: 'delete_project',
      parameters: {
        'project_id': projectId,
      },
    );
  }

  Future<void> logOpenProject({required String projectId}) async {
    await _analytics.logEvent(
      name: 'open_project',
      parameters: {
        'project_id': projectId,
      },
    );
  }

  // -- Task Events --

  Future<void> logOpenTask({required String taskId, required String projectId}) async {
    await _analytics.logEvent(
      name: 'open_task',
      parameters: {
        'task_id': taskId,
        'project_id': projectId,
      },
    );
  }

  Future<void> logCreateTask({required String taskId, required String projectId}) async {
    await _analytics.logEvent(
      name: 'create_task',
      parameters: {
        'task_id': taskId,
        'project_id': projectId,
      },
    );
  }

  Future<void> logUpdateTask({required String taskId}) async {
    await _analytics.logEvent(
      name: 'update_task',
      parameters: {
        'task_id': taskId,
      },
    );
  }

  Future<void> logDeleteTask({required String taskId}) async {
    await _analytics.logEvent(
      name: 'delete_task',
      parameters: {
        'task_id': taskId,
      },
    );
  }
}
