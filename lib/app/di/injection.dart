import 'package:get_it/get_it.dart';
import 'package:orbit_app/core/network/app_config.dart';
import 'package:orbit_app/features/authentication/data/datasource/auth_remote_data_source.dart';
import 'package:orbit_app/features/authentication/data/repositories/auth_repository_impl.dart';
import 'package:orbit_app/features/authentication/domain/repositories/auth_repository.dart';
import 'package:orbit_app/features/authentication/domain/usecases/get_current_user_use_case.dart';
import 'package:orbit_app/features/authentication/domain/usecases/login_use_case.dart';
import 'package:orbit_app/features/authentication/domain/usecases/login_with_google_use_case.dart';
import 'package:orbit_app/features/authentication/domain/usecases/logout_use_case.dart';
import 'package:orbit_app/features/authentication/presentation/cubit/auth_cubit.dart';
import 'package:orbit_app/features/workspaces/data/datasource/workspace_remote_data_source.dart';
import 'package:orbit_app/features/workspaces/data/repositories/workspace_repository_impl.dart';
import 'package:orbit_app/features/workspaces/domain/repositories/workspace_repository.dart';
import 'package:orbit_app/features/workspaces/domain/usecases/get_my_context_use_case.dart';
import 'package:orbit_app/features/workspaces/domain/usecases/create_workspace_use_case.dart';
import 'package:orbit_app/features/workspaces/domain/usecases/switch_workspace_use_case.dart';
import 'package:orbit_app/features/workspaces/presentation/cubit/workspace_cubit.dart';
import 'package:orbit_app/features/projects/data/datasource/project_remote_data_source.dart';
import 'package:orbit_app/features/projects/data/repositories/project_repository_impl.dart';
import 'package:orbit_app/features/projects/domain/repositories/project_repository.dart';
import 'package:orbit_app/features/projects/domain/usecases/get_workstation_projects_use_case.dart';
import 'package:orbit_app/features/projects/presentation/cubit/projects_bloc.dart';
import 'package:orbit_app/features/projects/presentation/cubit/project_detail_cubit.dart';
import 'package:orbit_app/features/tasks/data/datasource/task_remote_data_source.dart';
import 'package:orbit_app/features/tasks/data/repositories/task_repository_impl.dart';
import 'package:orbit_app/features/tasks/domain/repositories/task_repository.dart';
import 'package:orbit_app/features/tasks/domain/usecases/get_workstation_tasks_use_case.dart';
import 'package:orbit_app/features/tasks/presentation/cubit/tasks_bloc.dart';
import 'package:orbit_app/features/notifications/data/repositories/notifications_repository.dart';
import 'package:orbit_app/features/notifications/presentation/bloc/notifications_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:orbit_app/features/dashboard/data/datasource/dashboard_remote_data_source.dart';
import 'package:orbit_app/features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:orbit_app/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:orbit_app/features/dashboard/domain/usecases/get_mobile_dashboard_use_case.dart';
import 'package:orbit_app/features/dashboard/presentation/cubit/dashboard_cubit.dart';
/// Global service locator.
final GetIt sl = GetIt.instance;

/// Registers every dependency. Call once at startup, after Supabase is
/// initialised (see `main.dart`).
Future<void> configureDependencies() async {
  sl
    // ── External ──────────────────────────────────────────────────────────
    ..registerLazySingleton<SupabaseClient>(() => Supabase.instance.client)
    // ── Authentication: data ──────────────────────────────────────────────
    ..registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(
        sl(),
        googleWebClientId: AppConfig.googleWebClientId,
        googleIosClientId: AppConfig.googleIosClientId,
      ),
    )
    ..registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(remoteDataSource: sl()),
    )
    // ── Authentication: domain (use cases) ────────────────────────────────
    ..registerLazySingleton(() => LoginUseCase(sl()))
    ..registerLazySingleton(() => LoginWithGoogleUseCase(sl()))
    ..registerLazySingleton(() => LogoutUseCase(sl()))
    ..registerLazySingleton(() => GetCurrentUserUseCase(sl()))
    // ── Authentication: presentation ──────────────────────────────────────
    // Single shared cubit so route guards and the UI observe the same state.
    ..registerLazySingleton(
      () => AuthCubit(
        login: sl(),
        loginWithGoogle: sl(),
        logout: sl(),
        getCurrentUser: sl(),
        repository: sl(),
      ),
    )
    // ── Workspaces ─────────────────────────────────────────────────────────
    ..registerLazySingleton<WorkspaceRemoteDataSource>(
      () => WorkspaceRemoteDataSourceImpl(sl()),
    )
    ..registerLazySingleton<WorkspaceRepository>(
      () => WorkspaceRepositoryImpl(remoteDataSource: sl()),
    )
    ..registerLazySingleton(() => GetMyContextUseCase(sl()))
    ..registerLazySingleton(() => CreateWorkspaceUseCase(sl()))
    ..registerLazySingleton(() => SwitchWorkspaceUseCase(sl()))
    ..registerLazySingleton(
      () => WorkspaceCubit(
        getMyContext: sl(),
        createWorkspace: sl(),
        switchWorkspace: sl(),
      ),
    )
    // ── Projects ───────────────────────────────────────────────────────────
    ..registerFactory<ProjectRemoteDataSource>(
      () => ProjectRemoteDataSourceImpl(sl()),
    )
    ..registerFactory<ProjectRepository>(
      () => ProjectRepositoryImpl(remoteDataSource: sl()),
    )
    ..registerFactory(() => GetWorkstationProjectsUseCase(sl()))
    ..registerFactory(() => ProjectsBloc(sl()))
    ..registerFactory(() => ProjectDetailCubit(repository: sl()))
    // ── Tasks ──────────────────────────────────────────────────────────────
    ..registerFactory<TaskRemoteDataSource>(
      () => TaskRemoteDataSourceImpl(sl()),
    )
    ..registerFactory<TaskRepository>(
      () => TaskRepositoryImpl(remoteDataSource: sl()),
    )
    ..registerFactory(() => GetWorkstationTasksUseCase(sl()))
    ..registerFactory(() => TasksBloc(sl()))
    // ── Notifications ──────────────────────────────────────────────────────
    ..registerFactory(() => NotificationsRepository(sl()))
    ..registerFactory(() => NotificationsBloc(sl()))
    // ── Dashboard ──────────────────────────────────────────────────────────
    ..registerFactory<DashboardRemoteDataSource>(
      () => DashboardRemoteDataSourceImpl(sl()),
    )
    ..registerFactory<DashboardRepository>(
      () => DashboardRepositoryImpl(remoteDataSource: sl()),
    )
    ..registerFactory(() => GetMobileDashboardUseCase(sl()))
    ..registerFactory(() => DashboardCubit(getMobileDashboardUseCase: sl()));
}
