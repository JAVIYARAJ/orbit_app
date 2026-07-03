import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:orbit_app/core/errors/exceptions.dart';

class TaskMetadataService {
  TaskMetadataService(this._client);
  final SupabaseClient _client;

  // Cache by repoFullName
  final Map<String, List<dynamic>> _branchesCache = {};
  final Map<String, DateTime> _branchesExpiry = {};
  final Duration cacheDuration = const Duration(minutes: 5);

  Map<String, dynamic>? _taskMetadataCache;
  DateTime? _taskMetadataExpiry;

  Future<Map<String, dynamic>> getTaskMetadata(String workstationId) async {
    if (_taskMetadataCache != null &&
        _taskMetadataExpiry != null &&
        DateTime.now().isBefore(_taskMetadataExpiry!)) {
      return _taskMetadataCache!;
    }

    try {
      final data = await _client.rpc<Map<String, dynamic>>(
        'get_task_metadata',
        params: {'p_workstation_id': workstationId},
      );
      
      _taskMetadataCache = data;
      _taskMetadataExpiry = DateTime.now().add(cacheDuration);
      return data;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  void clearTaskMetadataCache() {
    _taskMetadataCache = null;
    _taskMetadataExpiry = null;
  }

  Future<List<dynamic>> getGithubBranches(String workstationId, String repoFullName) async {
    if (_branchesCache.containsKey(repoFullName) && 
        _branchesExpiry.containsKey(repoFullName) && 
        DateTime.now().isBefore(_branchesExpiry[repoFullName]!)) {
      return _branchesCache[repoFullName]!;
    }

    try {
      final response = await _client.functions.invoke(
        'github-proxy',
        body: {
          'path': '/repos/$repoFullName/branches',
          'params': {
            'per_page': 100,
          },
          'method': 'GET',
          'workstation_id': workstationId,
        },
      );

      if (response.data is Map<String, dynamic> && response.data['data'] is List) {
        final branches = response.data['data'] as List<dynamic>;
        _branchesCache[repoFullName] = branches;
        _branchesExpiry[repoFullName] = DateTime.now().add(cacheDuration);
        return branches;
      }
      return [];
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  Future<void> createGithubBranch(String workstationId, String repoFullName, String branchName) async {
    try {
      String? sha;
      
      // Try to get main branch SHA
      try {
        final mainRef = await _client.functions.invoke(
          'github-proxy',
          body: {
            'path': '/repos/$repoFullName/git/ref/heads/main',
            'params': <String, dynamic>{},
            'method': 'GET',
            'workstation_id': workstationId,
          },
        );
        if (mainRef.data != null && mainRef.data['data'] != null) {
          sha = mainRef.data['data']['object']['sha'] as String?;
        }
      } catch (_) {}

      // If main not found, try master
      if (sha == null) {
        final masterRef = await _client.functions.invoke(
          'github-proxy',
          body: {
            'path': '/repos/$repoFullName/git/ref/heads/master',
            'params': <String, dynamic>{},
            'method': 'GET',
            'workstation_id': workstationId,
          },
        );
        if (masterRef.data != null && masterRef.data['data'] != null) {
          sha = masterRef.data['data']['object']['sha'] as String?;
        }
      }

      if (sha == null) {
        throw const ServerException(message: 'Could not find main or master branch to branch off of.');
      }

      final response = await _client.functions.invoke(
        'github-proxy',
        body: {
          'path': '/repos/$repoFullName/git/refs',
          'params': <String, dynamic>{},
          'method': 'POST',
          'body': {
            'ref': 'refs/heads/$branchName',
            'sha': sha,
          },
          'workstation_id': workstationId,
        },
      );

      final data = response.data as Map<String, dynamic>?;
      if (data != null) {
        final ghStatus = data['status'] as int?;
        if (ghStatus == 422) {
          throw ServerException(message: 'Branch "$branchName" already exists in $repoFullName.');
        }
        if (ghStatus != null && ghStatus >= 400) {
          final errorData = data['data'];
          String errorMessage = 'GitHub error $ghStatus';
          if (errorData is Map && errorData['message'] != null) {
            errorMessage = errorData['message'].toString();
          }
          throw ServerException(message: errorMessage);
        }
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: e.toString());
    }
  }

  void clearCache() {
    _branchesCache.clear();
    _branchesExpiry.clear();
  }
}
