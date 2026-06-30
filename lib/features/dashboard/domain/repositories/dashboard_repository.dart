import 'package:orbit_app/core/utils/typedefs.dart';
import 'package:orbit_app/features/dashboard/domain/entities/dashboard_entity.dart';

abstract class DashboardRepository {
  ResultFuture<DashboardEntity> getMobileDashboard(String workstationId);
}
