import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:orbit_app/core/errors/exceptions.dart';

class ProjectMetadataService {

  ProjectMetadataService(this._client);
  final SupabaseClient _client;

  Map<String, dynamic>? _metadataCache;
  DateTime? _metadataExpiry;

  List<dynamic>? _githubReposCache;
  DateTime? _githubReposExpiry;

  final Duration cacheDuration = const Duration(minutes: 5);

  Future<Map<String, dynamic>> getProjectMetadata(String workstationId) async {
    if (_metadataCache != null && _metadataExpiry != null && DateTime.now().isBefore(_metadataExpiry!)) {
      return _metadataCache!;
    }

    try {
      final data = await _client.rpc<Map<String, dynamic>>(
        'get_project_metadata',
        params: {'p_workstation_id': workstationId},
      );
      
      final result = data;
      _metadataCache = result;
      _metadataExpiry = DateTime.now().add(cacheDuration);
      return result;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  Future<List<dynamic>> getGithubRepos(String workstationId) async {
    if (_githubReposCache != null && _githubReposExpiry != null && DateTime.now().isBefore(_githubReposExpiry!)) {
      return _githubReposCache!;
    }

    try {
      final response = await _client.functions.invoke(
        'github-proxy',
        body: {
          'path': '/user/repos',
          'params': {
            'sort': 'updated',
            'direction': 'desc',
            'per_page': 100,
            'page': 1,
            'affiliation': 'owner,collaborator,organization_member'
          },
          'method': 'GET',
          'body': null,
          'workstation_id': workstationId,
        },
      );

      if (response.data is Map<String, dynamic> && response.data['data'] is List) {
        final repos = response.data['data'] as List<dynamic>;
        _githubReposCache = repos;
        _githubReposExpiry = DateTime.now().add(cacheDuration);
        return repos;
      }
      return [];
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  Future<Map<String, dynamic>> createGithubRepo({
    required String workstationId,
    required String name,
    required bool isPrivate,
    required String description,
  }) async {
    try {
      final response = await _client.functions.invoke(
        'github-proxy',
        body: {
          'path': '/user/repos',
          'params': <Map<dynamic, dynamic>>{},
          'method': 'POST',
          'body': {
            'name': name,
            'description': description,
            'private': isPrivate,
            'auto_init': true,
          },
          'workstation_id': workstationId,
        },
      );

      if (response.status >= 400) {
        throw ServerException(message: 'GitHub error ${response.status}');
      }

      final data = response.data;
      if (data != null && data['data'] != null) {
        return data['data'] as Map<String, dynamic>;
      }
      return {};
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  void clearCache() {
    _metadataCache = null;
    _metadataExpiry = null;
    _githubReposCache = null;
    _githubReposExpiry = null;
  }
}
