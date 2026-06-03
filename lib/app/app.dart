import 'package:flutter/material.dart';
import 'package:orbit_app/app/theme/app_colors.dart';
import 'package:orbit_app/app/router/app_router.dart';
import 'package:orbit_app/core/widgets/orbit_icon.dart';

class OrbitApp extends StatelessWidget {
  const OrbitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Orbit',
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter,
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
    );
  }
}
