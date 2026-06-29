import 'package:equatable/equatable.dart';
import 'package:orbit_app/features/notifications/domain/entities/notification_entity.dart';

enum NotificationsStatus { initial, loading, success, failure }

class NotificationsState extends Equatable {
  const NotificationsState({
    this.status = NotificationsStatus.initial,
    this.notifications = const [],
    this.hasReachedMax = false,
    this.errorMessage,
  });

  final NotificationsStatus status;
  final List<NotificationEntity> notifications;
  final bool hasReachedMax;
  final String? errorMessage;

  NotificationsState copyWith({
    NotificationsStatus? status,
    List<NotificationEntity>? notifications,
    bool? hasReachedMax,
    String? errorMessage,
  }) {
    return NotificationsState(
      status: status ?? this.status,
      notifications: notifications ?? this.notifications,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, notifications, hasReachedMax, errorMessage];
}
