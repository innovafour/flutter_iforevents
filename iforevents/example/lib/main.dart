import 'package:example/screens/iforevents_1.dart';
import 'package:example/screens/iforevents_2.dart';
import 'package:flutter/material.dart';
import 'package:iforevents/iforevents.dart';
import 'package:iforevents/models/iforevents_api_config.dart';
import 'package:iforevents/utils/navigator_observer.dart';
import 'package:iforevents_mixpanel/iforevents_mixpanel.dart';

import 'screens/home_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/analytics_demo_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase (uncomment when you have Firebase configured)
  // await Firebase.initializeApp();

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final Iforevents iforevents = const Iforevents();

  @override
  void initState() {
    super.initState();
    _initializeAnalytics();
  }

  Future<void> _initializeAnalytics() async {
    final config = IForeventsAPIConfig(
      projectKey: '155d3a6765fac771841c4129e68f50a0',
      projectSecret:
          'ec73ec62620f275de58fe25e3d526e0c378d6fa77145e19ba8489b2b812a2572',
      baseUrl: 'http://192.168.1.13:8000',
      batchSize: 2,
      batchIntervalMs: 3000,
      enableLogging: true,
      throwOnError: false,
      requireIdentifyBeforeTrack: true,
    );

    await iforevents.init(
      integrations: [
        // Firebase Integration (uncomment when Firebase is configured)
        // const FirebaseIntegration(),

        // Mixpanel Integration (replace with your actual token)
        const MixpanelIntegration(token: 'cb927e5b08c08e5ae725bb1d9e0bb432'),

        IForeventsAPIIntegration(config: config),
      ],
    );

    // Identify a test user
    await iforevents.identify(
      event: IdentifyEvent(
        customID: 'demo_user_123',
        properties: {
          'email': 'demo@example.com',
          'name': 'Demo User',
          'plan': 'free',
          'signup_date': DateTime.now().toIso8601String(),
        },
      ),
    );

    // Track app launch
    iforevents.track(
      event: TrackEvent(
        eventName: 'app_launched',
        properties: {
          'launch_time': DateTime.now().toIso8601String(),
          'version': '1.0.0',
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IforEvents Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      navigatorObservers: [IforeventsRouteObserver(iforevents: iforevents)],
      initialRoute: '/',
      routes: {
        '/': (context) => HomeScreen(iforevents: iforevents),
        '/profile': (context) => ProfileScreen(iforevents: iforevents),
        '/settings': (context) => SettingsScreen(iforevents: iforevents),
        '/analytics': (context) => AnalyticsDemoScreen(iforevents: iforevents),
        '/iforevents': (context) => IForeventsAPIExamplePage(),
        '/iforevents/2': (context) => IForeventsExample(),
      },
    );
  }
}
