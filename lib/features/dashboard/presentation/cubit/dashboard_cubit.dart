import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:orbit_app/features/dashboard/domain/usecases/get_mobile_dashboard_use_case.dart';
import 'package:orbit_app/features/dashboard/presentation/cubit/dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit({
    required this.getMobileDashboardUseCase,
  }) : super(const DashboardInitial());

  final GetMobileDashboardUseCase getMobileDashboardUseCase;

  Future<void> fetchDashboard(String workstationId) async {
    if (workstationId.isEmpty) return;
    
    emit(const DashboardLoading());

    final result = await getMobileDashboardUseCase(workstationId);

    result.fold(
      (failure) => emit(DashboardError(failure.message)),
      (dashboard) => emit(DashboardLoaded(dashboard)),
    );
  }
}
