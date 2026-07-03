import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:orbit_app/app/app.dart';
import 'package:orbit_app/app/di/injection.dart';
import 'package:orbit_app/app/theme/app_colors.dart';
import 'package:orbit_app/core/network/app_config.dart';
import 'package:orbit_app/firebase_options.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Force dark status bar icons to complement the dark splash.
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: AppColors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  // Load secrets from .env, then bring up Supabase and the service locator.
  await AppConfig.load();
  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    publishableKey: AppConfig.supabaseAnonKey,
  );
  await configureDependencies();

  // 1. Initialize Firebase First
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const OrbitApp());
}
