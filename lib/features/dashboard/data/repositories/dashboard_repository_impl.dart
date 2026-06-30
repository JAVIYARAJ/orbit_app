import 'package:fpdart/fpdart.dart';
import 'package:orbit_app/core/errors/failures.dart';
import 'package:orbit_app/core/utils/typedefs.dart';
import 'package:orbit_app/features/dashboard/data/datasource/dashboard_remote_data_source.dart';
import 'package:orbit_app/features/dashboard/domain/entities/dashboard_entity.dart';
import 'package:orbit_app/features/dashboard/domain/repositories/dashboard_repository.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  const DashboardRepositoryImpl({required this.remoteDataSource});

  final DashboardRemoteDataSource remoteDataSource;

  @override
  ResultFuture<DashboardEntity> getMobileDashboard(String workstationId) async {
    try {
      final dashboard = await remoteDataSource.getMobileDashboard(workstationId);
      return right(dashboard);
    } catch (e) {
      return left(ServerFailure(message: e.toString()));
    }
  }
}
