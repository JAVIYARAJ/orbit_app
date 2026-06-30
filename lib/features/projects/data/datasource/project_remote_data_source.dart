import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:orbit_app/core/errors/exceptions.dart';
import 'package:orbit_app/features/projects/data/models/project_model.dart';
import 'package:orbit_app/features/projects/domain/entities/project_entity.dart';

abstract interface class ProjectRemoteDataSource {
  Future<List<ProjectEntity>> getWorkstationProjects(String workstationId);
  Future<ProjectEntity> getProjectDetail(String workstationId, String projectId);
  Future<Map<String, dynamic>> getGithubUser(String workstationId);
  Future<List<dynamic>> getGithubCommits(String workstationId, String owner, String repo);
}

class ProjectRemoteDataSourceImpl implements ProjectRemoteDataSource {
  ProjectRemoteDataSourceImpl(this._client);

  final SupabaseClient _client;

  @override
  Future<List<ProjectEntity>> getWorkstationProjects(String workstationId) async {
    try {
      final data = await _client.rpc<Map<String, dynamic>>(
        'load_workstation_projects',
        params: {'p_workstation_id': workstationId},
      );
      final projectsList = data['projects'] as List<dynamic>?;
      if (projectsList == null) return [];
      return projectsList.map((p) => ProjectModel.fromJson(p as Map<String, dynamic>)).toList();
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<ProjectEntity> getProjectDetail(String workstationId, String projectId) async {
    try {
      final data = await _client.rpc<Map<String, dynamic>>(
        'get_project_detail',
        params: {
          'p_workstation_id': workstationId,
          'p_project_id': projectId,
        },
      );
      return ProjectModel.fromJson(data['project'] as Map<String, dynamic>);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<Map<String, dynamic>> getGithubUser(String workstationId) async {
    try {
      final response = await _client.functions.invoke(
        'github-proxy',
        body: {
          'workstation_id': workstationId,
          'path': '/user',
          'params': <dynamic, dynamic>{},
        },
      );
      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        if (data.containsKey('data') && data['data'] is Map<String, dynamic>) {
          return data['data'] as Map<String, dynamic>;
        }
        return data;
      }
      return {};
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<dynamic>> getGithubCommits(String workstationId, String owner, String repo) async {
    try {
      final response = await _client.functions.invoke(
        'github-proxy',
        body: {
          'workstation_id': workstationId,
          'path': '/repos/$owner/$repo/commits',
          'params': {'per_page': 1},
          'method': 'GET',
          'body': null,
        },
      );
      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        if (data.containsKey('data') && data['data'] is List) {
          return data['data'] as List<dynamic>;
        }
      } else if (response.data is List) {
        return response.data as List<dynamic>;
      }
      return [];
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
