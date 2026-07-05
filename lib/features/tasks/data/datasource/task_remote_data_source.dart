import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:orbit_app/features/tasks/data/models/task_detail_model.dart';
import 'package:orbit_app/core/errors/exceptions.dart';
import 'package:orbit_app/features/tasks/data/models/task_model.dart';
import 'package:orbit_app/features/tasks/data/models/task_status_model.dart';
import 'package:orbit_app/features/tasks/data/models/task_priority_model.dart';
import 'package:orbit_app/features/tasks/data/models/note_for_linking_model.dart';
import 'package:orbit_app/features/tasks/domain/entities/tasks_data_entity.dart';
import 'package:orbit_app/features/workspaces/data/models/workspace_member_model.dart';

abstract interface class TaskRemoteDataSource {
  Future<TasksDataEntity> getWorkstationTasks(String workstationId);
  Future<TaskModel> createTask(String workstationId, Map<String, dynamic> data);
  Future<TaskDetailModel> getTaskDetail(String workstationId, String taskId);
  Future<TaskDetailModel> updateTask(String taskId, Map<String, dynamic> data);
  Future<void> addTaskComment(String taskId, String body, List<String> mentionedUserIds, String? parentId);
  Future<void> deleteTaskComment(String commentId);
  Future<void> deleteTask(String taskId);
  Future<void> logManualTime({
    required String workstationId,
    required String projectId,
    required String taskId,
    required int minutes,
    required String notes,
  });
  Future<Map<String, dynamic>> uploadCloudinaryFile({
    required String workstationId,
    required String taskId,
    required List<int> fileBytes,
    required String fileName,
    required String? mimeType,
  });
  Future<void> addTaskAttachment({
    required String taskId,
    required String? commentId,
    required Map<String, dynamic> data,
  });
  Future<void> deleteTaskAttachment(String attachmentId);
  Future<List<TaskModel>> getProjectTasks({
    required String workstationId,
    required String projectShortId,
  });
  Future<List<NoteForLinkingModel>> getNotesForLinking({
    required String workstationId,
  });
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
  Future<TaskModel> createTask(String workstationId, Map<String, dynamic> data) async {
    try {
      final res = await _client.rpc<Map<String, dynamic>>(
        'create_task',
        params: {
          'p_workstation_id': workstationId,
          'p_data': data,
        },
      );
      return TaskModel.fromJson(res);
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
      final workstationId = res['workstation_id'] as String?;
      if (workstationId != null) {
        return await getTaskDetail(workstationId, taskId);
      }
      throw const ServerException(message: 'Could not fetch workstation ID for updated task');
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

  @override
  Future<void> deleteTask(String taskId) async {
    try {
      await _client.rpc<void>(
        'soft_delete_task',
        params: {
          'p_task_id': taskId,
        },
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> logManualTime({
    required String workstationId,
    required String projectId,
    required String taskId,
    required int minutes,
    required String notes,
  }) async {
    try {
      await _client.rpc<void>(
        'log_manual_time',
        params: {
          'p_workstation_id': workstationId,
          'p_project_id': projectId,
          'p_task_id': taskId,
          'p_minutes': minutes,
          'p_notes': notes,
        },
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<Map<String, dynamic>> uploadCloudinaryFile({
    required String workstationId,
    required String taskId,
    required List<int> fileBytes,
    required String fileName,
    required String? mimeType,
  }) async {
    try {
      final random = Random();
      final hexDigits = '0123456789abcdef';
      final charCodes = List<int>.generate(36, (index) {
        if (index == 8 || index == 13 || index == 18 || index == 23) {
          return 45; // '-'
        }
        final hexIndex = random.nextInt(16);
        return hexDigits.codeUnitAt(hexIndex);
      });
      final randomUuid = String.fromCharCodes(charCodes);

      final publicId = 'orbit/$workstationId/$taskId/$randomUuid';
      
      final response = await _client.functions.invoke(
        'cloudinary',
        body: {
          'action': 'sign',
          'workstation_id': workstationId,
          'public_id': publicId,
        },
      );

      final data = response.data;
      final payload = data is Map ? data : (data as Map<String, dynamic>);
      
      final edgeError = payload['error'];
      if (edgeError != null) {
        throw Exception(edgeError.toString());
      }
      
      final edgeData = payload['data'] is Map ? payload['data'] : payload;
      final signature = edgeData['signature'] as String;
      final timestamp = edgeData['timestamp'];
      final apiKey = edgeData['api_key'] as String;
      final cloudName = edgeData['cloud_name'] as String;
      final returnedPublicId = edgeData['public_id'] as String;

      final uri = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/auto/upload');
      final request = http.MultipartRequest('POST', uri);
      
      request.fields['api_key'] = apiKey;
      request.fields['timestamp'] = timestamp.toString();
      request.fields['signature'] = signature;
      request.fields['public_id'] = returnedPublicId;
      
      final multipartFile = http.MultipartFile.fromBytes(
        'file',
        fileBytes,
        filename: fileName,
        contentType: mimeType != null ? MediaType.parse(mimeType) : null,
      );
      request.files.add(multipartFile);
      
      final streamedResponse = await request.send();
      final httpResponse = await http.Response.fromStream(streamedResponse);
      
      if (httpResponse.statusCode != 200) {
        throw Exception('Cloudinary upload failed: ${httpResponse.body}');
      }
      
      final responseData = jsonDecode(httpResponse.body) as Map<String, dynamic>;
      
      return {
        'provider': 'cloudinary',
        'public_id': responseData['public_id'],
        'resource_type': responseData['resource_type'] ?? 'image',
        'secure_url': responseData['secure_url'],
        'file_name': fileName,
        'mime_type': mimeType,
        'format': responseData['format'],
        'size_bytes': responseData['bytes'] ?? fileBytes.length,
        'width': responseData['width'],
        'height': responseData['height'],
      };
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> addTaskAttachment({
    required String taskId,
    required String? commentId,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _client.rpc<dynamic>(
        'add_task_attachment',
        params: {
          'p_task_id': taskId,
          'p_comment_id': commentId,
          'p_data': data,
        },
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> deleteTaskAttachment(String attachmentId) async {
    try {
      await _client.functions.invoke(
        'cloudinary',
        body: {
          'action': 'destroy',
          'attachment_id': attachmentId,
        },
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<TaskModel>> getProjectTasks({
    required String workstationId,
    required String projectShortId,
  }) async {
    try {
      final res = await _client.rpc<List<dynamic>>(
        'get_project_tasks',
        params: {
          'p_workstation_id': workstationId,
          'p_project_short_id': projectShortId,
        },
      );
      return res.map((t) => TaskModel.fromJson(t as Map<String, dynamic>)).toList();
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<NoteForLinkingModel>> getNotesForLinking({
    required String workstationId,
  }) async {
    try {
      final res = await _client.rpc<Map<String, dynamic>>(
        'get_notes_for_linking',
        params: {
          'p_workstation_id': workstationId,
        },
      );
      final list = res['notes'] as List<dynamic>? ?? [];
      return list.map((n) => NoteForLinkingModel.fromJson(n as Map<String, dynamic>)).toList();
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
