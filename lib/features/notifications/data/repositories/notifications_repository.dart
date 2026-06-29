import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:orbit_app/features/notifications/domain/entities/notification_entity.dart';

class NotificationsRepository {
  const NotificationsRepository(this._client);
  final SupabaseClient _client;

  Future<List<NotificationEntity>> getNotifications({int limit = 30, int offset = 0}) async {
    final response = await _client.rpc('get_notifications_pagination', params: {
      'p_limit': limit,
      'p_offset': offset,
    });
    final List<dynamic> data = response as List<dynamic>;
    return data.map((json) => NotificationEntity.fromJson(json as Map<String, dynamic>)).toList();
  }
}
