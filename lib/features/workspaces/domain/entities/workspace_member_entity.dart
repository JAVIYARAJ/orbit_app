import 'package:equatable/equatable.dart';

class WorkspaceMemberEntity extends Equatable {
  const WorkspaceMemberEntity({
    required this.name,
    required this.role,
    required this.email,
    required this.avatar,
    required this.userId,
    required this.joinedAt,
    this.avatarUrl,
  });

  final String name;
  final String role;
  final String email;
  final String avatar;
  final String userId;
  final DateTime joinedAt;
  final String? avatarUrl;

  @override
  List<Object?> get props => [
        name,
        role,
        email,
        avatar,
        userId,
        joinedAt,
        avatarUrl,
      ];
}
