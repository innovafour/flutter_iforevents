import 'package:example/screens/iforevents_1.dart';
import 'package:example/screens/iforevents_2.dart';
import 'package:flutter/material.dart';
import 'package:iforevents/iforevents.dart';
import 'package:iforevents/models/iforevents_api_config.dart';
import 'package:iforevents/utils/navigator_observer.dart';
import 'package:iforevents_amplitude/iforevents_amplitude.dart';
import 'package:iforevents_mixpanel/iforevents_mixpanel.dart';

import 'screens/amplitude_demo_screen.dart';
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

  // Amplitude integration instance - replace with your actual API key
  final AmplitudeIntegration amplitudeIntegration = const AmplitudeIntegration(
    apiKey: '<YOUR_AMPLITUDE_API_KEY>',
    flushQueueSize: 30,
    flushIntervalMillis: 30000,
    optOut: false,
    useBatch: false,
  );

  @override
  void initState() {
    super.initState();
    _initializeAnalytics();
  }

  Future<void> _initializeAnalytics() async {
    final config = IForeventsAPIConfig(
      projectKey: '<YOUR_PROJECT_KEY>',
      projectSecret: '<YOUR_PROJECT_SECRET>',
      baseUrl: 'http://192.168.1.13:8000',
      batchSize: 2,
      batchIntervalMs: 3000,
      enableLogging: true,
      throwOnError: false,
    );

    await iforevents.init(
      integrations: [
        // Firebase Integration (uncomment when Firebase is configured)
        // const FirebaseIntegration(),

        // Amplitude Integration
        amplitudeIntegration,

        // Mixpanel Integration (replace with your actual token)
        const MixpanelIntegration(token: '<YOUR_MIXPANEL_TOKEN>'),

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
        '/amplitude': (context) => AmplitudeDemoScreen(
          iforevents: iforevents,
          amplitudeIntegration: amplitudeIntegration,
        ),
        '/iforevents': (context) => IForeventsAPIExamplePage(),
        '/iforevents/2': (context) => IForeventsExample(),
      },
    );
  }
}
