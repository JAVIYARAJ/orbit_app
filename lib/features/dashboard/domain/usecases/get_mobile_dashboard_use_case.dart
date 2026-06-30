import 'package:orbit_app/core/utils/typedefs.dart';
import 'package:orbit_app/core/utils/use_case.dart';
import 'package:orbit_app/features/dashboard/domain/entities/dashboard_entity.dart';
import 'package:orbit_app/features/dashboard/domain/repositories/dashboard_repository.dart';

class GetMobileDashboardUseCase implements UseCaseWithParams<DashboardEntity, String> {
  const GetMobileDashboardUseCase(this.repository);

  final DashboardRepository repository;

  @override
  ResultFuture<DashboardEntity> call(String params) async {
    return repository.getMobileDashboard(params);
  }
}
