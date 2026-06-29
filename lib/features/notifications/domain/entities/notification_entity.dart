import 'package:equatable/equatable.dart';

class NotificationEntity extends Equatable {

  factory NotificationEntity.fromJson(Map<String, dynamic> json) {
    return NotificationEntity(
      id: json['id'] as String? ?? '',
      type: json['type'] as String? ?? 'unknown',
      title: json['title'] as String? ?? 'Notification',
      preview: json['preview'] as String? ?? '',
      entityId: json['entityId'] as String?,
      entityType: json['entityType'] as String?,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now() : DateTime.now(),
      readAt: json['readAt'] != null ? DateTime.tryParse(json['readAt'].toString()) : null,
      actorAvatarUrl: json['actorAvatarUrl'] as String?,
      meta: json['meta'] as Map<String, dynamic>? ?? {},
    );
  }

  const NotificationEntity({
    required this.id,
    required this.type,
    required this.title,
    required this.preview,
    this.entityId,
    this.entityType,
    required this.createdAt,
    this.readAt,
    this.actorAvatarUrl,
    required this.meta,
  });
  final String id;
  final String type;
  final String title;
  final String preview;
  final String? entityId;
  final String? entityType;
  final DateTime createdAt;
  final DateTime? readAt;
  final String? actorAvatarUrl;
  final Map<String, dynamic> meta;

  bool get isRead => readAt != null;

  @override
  List<Object?> get props => [
        id,
        type,
        title,
        preview,
        entityId,
        entityType,
        createdAt,
        readAt,
        actorAvatarUrl,
        meta,
      ];
}
