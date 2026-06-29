import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:orbit_app/core/errors/exceptions.dart';
import 'package:orbit_app/features/authentication/data/models/user_model.dart';
import 'package:orbit_app/features/workspaces/data/models/workstation_model.dart';
import 'package:orbit_app/features/workspaces/domain/entities/workspace_context_entity.dart';

abstract interface class WorkspaceRemoteDataSource {
  Future<WorkspaceContextEntity> getMyContext();
}

class WorkspaceRemoteDataSourceImpl implements WorkspaceRemoteDataSource {
  WorkspaceRemoteDataSourceImpl(this._client);

  final SupabaseClient _client;

  @override
  Future<WorkspaceContextEntity> getMyContext() async {
    try {
      final data = await _client.rpc<Map<String, dynamic>>('get_my_context');

      final userMap = data['user'] as Map<String, dynamic>;
      final user = UserModel(
        id: userMap['id'] as String,
        email: userMap['email'] as String,
        name: userMap['name'] as String?,
        avatarUrl: userMap['avatar_url'] as String?,
      );

      final workstationsList = data['workstations'] as List<dynamic>;
      final workstations = workstationsList
          .map((w) => WorkstationModel.fromJson(w as Map<String, dynamic>))
          .toList();

      return WorkspaceContextEntity(
        user: user,
        workstations: workstations,
        activeWorkstationId: data['active_workstation_id'] as String?,
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
