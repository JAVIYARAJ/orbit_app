import 'package:feature_gate_pro/feature_gate_pro.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
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

  // May be in release mode we need this code to enable or override default firebase caching

  // 1. Tell Firebase to only cache data for 1 minute
  /*await FirebaseRemoteConfig.instance.setConfigSettings(RemoteConfigSettings(
    fetchTimeout: const Duration(seconds: 10),
    minimumFetchInterval: const Duration(minutes: kDebugMode ? 0 : 1),
  ));*/

  // configure flag flow for handle dynamic feature flags
  await FlagFlow.initialize(
    userContext: UserContext(
      id: 'guest',
      customAttributes: {
        "auth_provider":
            sl<SupabaseClient>().auth.currentUser?.appMetadata["provider"],
        'is_premium_subscription': false,
      },
    ),
    refreshInterval: const Duration(minutes: 15),
    providers: [
      LocalJsonProvider(assetPath: "assets/flags/feature_flag.json"),
      FirebaseAdapterProvider(
        onFetchAndActivate: () async =>
            await FirebaseRemoteConfig.instance.fetchAndActivate(),
        // Correct: This passes a function that the SDK can call later
        onGetAll: () => FirebaseRemoteConfig.instance.getAll(),
      ),
    ],
    /* analytics: FirebaseAnalyticsAdapter(
        sampleRate: 1.0, //  1.0 forces it to send 100% of the time for testing!
        logEvent: (name, params) async {
          // 1. Send it to Firebase
          await FirebaseAnalytics.instance.logEvent(name: name, parameters: params);
          // 2. Print it to your console so you can instantly verify it works!
          print("🚀 Analytics Sent: $name | $params");
        },
      ),*/
    cache: SharedPreferencesCacheProvider(cacheTTL: const Duration(hours: 24)),
  );

  FlagFlow.enableDebugLogging = true;

  runApp(const OrbitApp());
}
