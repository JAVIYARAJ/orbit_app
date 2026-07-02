import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:orbit_app/features/tasks/data/models/task_detail_model.dart';
import 'package:orbit_app/core/errors/exceptions.dart';
import 'package:orbit_app/features/tasks/data/models/task_model.dart';
import 'package:orbit_app/features/tasks/data/models/task_status_model.dart';
import 'package:orbit_app/features/tasks/data/models/task_priority_model.dart';
import 'package:orbit_app/features/tasks/domain/entities/tasks_data_entity.dart';
import 'package:orbit_app/features/workspaces/data/models/workspace_member_model.dart';

abstract interface class TaskRemoteDataSource {
  Future<TasksDataEntity> getWorkstationTasks(String workstationId);
  Future<TaskDetailModel> getTaskDetail(String workstationId, String taskId);
  Future<TaskDetailModel> updateTask(String taskId, Map<String, dynamic> data);
  Future<void> addTaskComment(String taskId, String body, List<String> mentionedUserIds, String? parentId);
  Future<void> deleteTaskComment(String commentId);
}

class TaskRemoteDataSourceImpl implements TaskRemoteDataSource {
  TaskRemoteDataSourceImpl(this._client);

  final SupabaseClient _client;

  @override
  Future<TasksDataEntity> getWorkstationTasks(String workstationId) async {
    try {
      final futureData = _client.rpc<Map<String, dynamic>>(
        'load_workstation_tasks',
        params: {'p_workstation_id': workstationId},
      );
      final futureMembers = _client.rpc<List<dynamic>>(
        'list_workspace_members',
        params: {'p_workstation_id': workstationId},
      );

      final results = await Future.wait([futureData, futureMembers]);
      final data = results[0] as Map<String, dynamic>;
      final membersData = results[1] as List<dynamic>;
      
      final tasksList = data['tasks'] as List<dynamic>? ?? [];
      final statusesList = data['statuses'] as List<dynamic>? ?? [];
      final prioritiesList = data['task_priorities'] as List<dynamic>? ?? [];
      
      return TasksDataEntity(
        tasks: tasksList.map((p) => TaskModel.fromJson(p as Map<String, dynamic>)).toList(),
        statuses: statusesList.map((p) => TaskStatusModel.fromJson(p as Map<String, dynamic>)).toList(),
        members: membersData.map((p) => WorkspaceMemberModel.fromJson(p as Map<String, dynamic>)).toList(),
        priorities: prioritiesList.map((p) => TaskPriorityModel.fromJson(p as Map<String, dynamic>)).toList(),
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<TaskDetailModel> getTaskDetail(String workstationId, String taskId) async {
    try {
      final data = await _client.rpc<Map<String, dynamic>>(
        'get_task_detail',
        params: {
          'p_workstation_id': workstationId,
          'p_task_id': taskId,
        },
      );
      return TaskDetailModel.fromJson(data);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<TaskDetailModel> updateTask(String taskId, Map<String, dynamic> data) async {
    try {
      final res = await _client.rpc<Map<String, dynamic>>(
        'update_task_v2',
        params: {
          'p_task_id': taskId,
          'p_data': data,
        },
      );
      return TaskDetailModel.fromJson(res);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> addTaskComment(String taskId, String body, List<String> mentionedUserIds, String? parentId) async {
    try {
      await _client.rpc<void>(
        'add_task_comment',
        params: {
          'p_task_id': taskId,
          'p_body': body,
          'p_mentions': mentionedUserIds,
          'p_parent_id': parentId,
        },
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> deleteTaskComment(String commentId) async {
    try {
      await _client.rpc<void>(
        'delete_task_comment',
        params: {
          'p_comment_id': commentId,
        },
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
