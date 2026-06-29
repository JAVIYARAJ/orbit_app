import 'package:equatable/equatable.dart';

abstract class NotificationsEvent extends Equatable {
  const NotificationsEvent();

  @override
  List<Object?> get props => [];
}

class FetchNotificationsEvent extends NotificationsEvent {
  const FetchNotificationsEvent({this.limit = 30});

  final int limit;

  @override
  List<Object?> get props => [limit];
}

class LoadMoreNotificationsEvent extends NotificationsEvent {
  const LoadMoreNotificationsEvent({this.limit = 30});

  final int limit;

  @override
  List<Object?> get props => [limit];
}
