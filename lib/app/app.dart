import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:orbit_app/app/di/injection.dart';
import 'package:orbit_app/app/router/app_router.dart';
import 'package:orbit_app/app/theme/app_colors.dart';
import 'package:orbit_app/core/widgets/orbit_icon.dart';
import 'package:orbit_app/features/authentication/presentation/cubit/auth_cubit.dart';

class OrbitApp extends StatefulWidget {
  const OrbitApp({super.key});

  @override
  State<OrbitApp> createState() => _OrbitAppState();
}

class _OrbitAppState extends State<OrbitApp> {
  late final AuthCubit _authCubit = sl<AuthCubit>();
  late final GoRouter _router = buildAppRouter(_authCubit);

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _authCubit,
      child: MaterialApp.router(
        title: 'Orbit',
        debugShowCheckedModeBanner: false,
        routerConfig: _router,
        theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: const ColorScheme.dark(
          primary: kOrbitIndigo,
          surface: AppColors.background,
        ),
      ),
      // Dismiss the keyboard / drop focus whenever the user taps outside any
      // focused (input) area — applied globally to every routed screen.
      builder: (context, child) => GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          final focus = FocusManager.instance.primaryFocus;
          if (focus != null && focus.hasFocus) {
            focus.unfocus();
          }
        },
          child: child,
        ),
      ),
    );
  }
}
