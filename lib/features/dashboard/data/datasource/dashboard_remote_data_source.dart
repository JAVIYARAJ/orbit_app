import 'package:orbit_app/features/dashboard/data/models/dashboard_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class DashboardRemoteDataSource {
  Future<DashboardModel> getMobileDashboard(String workstationId);
}

class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  const DashboardRemoteDataSourceImpl(this.client);

  final SupabaseClient client;

  @override
  Future<DashboardModel> getMobileDashboard(String workstationId) async {
    try {
      final response = await client.rpc('get_mobile_dashboard', params: {
        'p_workstation_id': workstationId,
      });
      return DashboardModel.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to load dashboard data: $e');
    }
  }
}
