import 'package:flutter/material.dart';
import 'package:orbit_app/app/theme/app_colors.dart';
import 'package:flutter/services.dart';
import 'package:orbit_app/app/app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Force dark status bar icons to complement the dark splash.
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: AppColors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const OrbitApp());
}
