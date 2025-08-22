import 'package:flutter/material.dart';
import 'package:iforevents/iforevents.dart';
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
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeAnalytics();
  }

  Future<void> _initializeAnalytics() async {
    try {
      await iforevents.init(
        integrations: [
          // Firebase Integration (uncomment when Firebase is configured)
          // const FirebaseIntegration(),

          // Mixpanel Integration (replace with your actual token)
          const MixpanelIntegration(token: 'YOUR_MIXPANEL_TOKEN_HERE'),
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

      setState(() {
        _isInitialized = true;
      });

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
    } catch (e) {
      setState(() {
        _isInitialized = true; // Continue even if analytics fails
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Initializing IforEvents...'),
              ],
            ),
          ),
        ),
      );
    }

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
      },
    );
  }
}
