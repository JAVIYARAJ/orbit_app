import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:orbit_app/core/errors/exceptions.dart';
import 'package:orbit_app/features/tasks/data/models/task_model.dart';
import 'package:orbit_app/features/tasks/data/models/task_status_model.dart';
import 'package:orbit_app/features/tasks/data/models/task_priority_model.dart';
import 'package:orbit_app/features/tasks/domain/entities/tasks_data_entity.dart';
import 'package:orbit_app/features/workspaces/data/models/workspace_member_model.dart';

abstract interface class TaskRemoteDataSource {
  Future<TasksDataEntity> getWorkstationTasks(String workstationId);
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
}
