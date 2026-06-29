import 'package:orbit_app/features/workspaces/domain/entities/workspace_member_entity.dart';

class WorkspaceMemberModel extends WorkspaceMemberEntity {
  const WorkspaceMemberModel({
    required super.name,
    required super.role,
    required super.email,
    required super.avatar,
    required super.userId,
    required super.joinedAt,
    super.avatarUrl,
  });

  factory WorkspaceMemberModel.fromJson(Map<String, dynamic> json) {
    return WorkspaceMemberModel(
      name: json['name'] as String? ?? 'Unknown',
      role: json['role'] as String? ?? 'member',
      email: json['email'] as String? ?? '',
      avatar: json['avatar'] as String? ?? 'U',
      userId: json['user_id'] as String? ?? '',
      joinedAt: json['joined_at'] != null
          ? DateTime.parse(json['joined_at'] as String)
          : DateTime.now(),
      avatarUrl: json['avatar_url'] as String?,
    );
  }
}
