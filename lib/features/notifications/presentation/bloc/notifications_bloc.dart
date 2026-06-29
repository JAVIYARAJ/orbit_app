import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:orbit_app/features/notifications/data/repositories/notifications_repository.dart';
import 'package:orbit_app/features/notifications/presentation/bloc/notifications_event.dart';
import 'package:orbit_app/features/notifications/presentation/bloc/notifications_state.dart';

class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  NotificationsBloc(this._repository) : super(const NotificationsState()) {
    on<FetchNotificationsEvent>(_onFetchNotifications);
    on<LoadMoreNotificationsEvent>(_onLoadMoreNotifications);
  }

  final NotificationsRepository _repository;

  Future<void> _onFetchNotifications(
    FetchNotificationsEvent event,
    Emitter<NotificationsState> emit,
  ) async {
    emit(state.copyWith(status: NotificationsStatus.loading));
    
    try {
      final notifications = await _repository.getNotifications(limit: event.limit, offset: 0);
      emit(state.copyWith(
        status: NotificationsStatus.success,
        notifications: notifications,
        hasReachedMax: notifications.length < event.limit,
        errorMessage: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: NotificationsStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onLoadMoreNotifications(
    LoadMoreNotificationsEvent event,
    Emitter<NotificationsState> emit,
  ) async {
    if (state.hasReachedMax) return;
    
    try {
      final offset = state.notifications.length;
      final notifications = await _repository.getNotifications(limit: event.limit, offset: offset);
      emit(state.copyWith(
        status: NotificationsStatus.success,
        notifications: List.of(state.notifications)..addAll(notifications),
        hasReachedMax: notifications.length < event.limit,
        errorMessage: null,
      ));
    } catch (e) {
      // Typically, on load more failure, we either emit failure or just ignore.
      emit(state.copyWith(
        status: NotificationsStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }
}
