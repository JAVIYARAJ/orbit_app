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
import 'package:supabase_flutter/supabase_flutter.dart';

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
    );
}
