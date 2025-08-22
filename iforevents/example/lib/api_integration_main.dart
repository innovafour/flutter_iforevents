import 'package:flutter/material.dart';
import 'package:iforevents/iforevents.dart';
import 'package:iforevents/models/iforevents_api_config.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IForevents API Integration Example',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: IForeventsAPIExamplePage(),
    );
  }
}

class IForeventsAPIExamplePage extends StatefulWidget {
  const IForeventsAPIExamplePage({super.key});

  @override
  State<IForeventsAPIExamplePage> createState() =>
      _IForeventsAPIExamplePageState();
}

class _IForeventsAPIExamplePageState extends State<IForeventsAPIExamplePage> {
  late Iforevents iforevents;
  IForeventsAPIIntegration? apiIntegration;
  bool isInitialized = false;
  bool isIdentified = false;
  String statusMessage = 'Initializing...';

  @override
  void initState() {
    super.initState();
    _initializeIForevents();
  }

  Future<void> _initializeIForevents() async {
    try {
      // Configuración de la integración API de IForevents
      final config = IForeventsAPIConfig(
        projectKey: 'demo-project-key', // Reemplaza con tu project key
        projectSecret: 'demo-project-secret', // Reemplaza con tu project secret
        baseUrl: 'https://your-api-domain.com', // Reemplaza con tu base URL
        batchSize: 5, // Enviar eventos en lotes de 5
        batchIntervalMs: 3000, // Revisar cada 3 segundos
        enableLogging: true, // Habilitar logs para desarrollo
        throwOnError: false, // No lanzar excepciones
        requireIdentifyBeforeTrack: true, // Requiere identificar antes de track
      );

      // Crear la integración
      apiIntegration = IForeventsAPIIntegration(config: config);

      // Inicializar IForevents con la integración API
      iforevents = const Iforevents();
      await iforevents.init(integrations: [apiIntegration!]);

      setState(() {
        isInitialized = true;
        statusMessage = 'IForevents API integration initialized successfully!';
      });
    } catch (e) {
      setState(() {
        statusMessage = 'Error initializing IForevents: $e';
      });
    }
  }

  Future<void> _identifyUser() async {
    try {
      await iforevents.identify(
        event: IdentifyEvent(
          customID: 'demo_user_123',
          properties: {
            'email': 'demo@example.com',
            'name': 'Demo User',
            'phone_number': '+1234567890',
            'age': 25,
            'plan': 'premium',
            'signup_date': DateTime.now().toIso8601String(),
          },
        ),
      );

      setState(() {
        isIdentified = true;
        statusMessage = 'User identified successfully!';
      });
    } catch (e) {
      setState(() {
        statusMessage = 'Error identifying user: $e';
      });
    }
  }

  void _trackEvent() {
    try {
      iforevents.track(
        event: TrackEvent(
          eventName: 'button_clicked',
          properties: {
            'button_name': 'track_event_demo',
            'screen': 'api_integration_example',
            'timestamp': DateTime.now().toIso8601String(),
            'platform': 'flutter',
          },
        ),
      );

      setState(() {
        statusMessage = 'Event tracked successfully!';
      });
    } catch (e) {
      setState(() {
        statusMessage = 'Error tracking event: $e';
      });
    }
  }

  Future<void> _trackPageView() async {
    try {
      await iforevents.pageViewed(
        event: PageViewEvent(
          navigationType: 'demo_navigation',
          toRoute: RouteSettings(name: '/demo_page'),
          previousRoute: RouteSettings(name: '/main'),
        ),
      );

      setState(() {
        statusMessage = 'Page view tracked successfully!';
      });
    } catch (e) {
      setState(() {
        statusMessage = 'Error tracking page view: $e';
      });
    }
  }

  Future<void> _flushEvents() async {
    if (apiIntegration != null) {
      try {
        await apiIntegration!.flush();
        setState(() {
          statusMessage = 'Events flushed successfully!';
        });
      } catch (e) {
        setState(() {
          statusMessage = 'Error flushing events: $e';
        });
      }
    }
  }

  String _getQueueStatus() {
    if (apiIntegration != null) {
      final status = apiIntegration!.getQueueStatus();
      return 'Queue: ${status.queuedEvents}/${status.batchSize} events, '
          'Identified: ${status.isIdentified}, '
          'Session: ${status.sessionUUID ?? 'None'}';
    }
    return 'API Integration not available';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('IForevents API Integration Demo'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Estado
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Status',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    SizedBox(height: 8),
                    Text(statusMessage),
                    SizedBox(height: 8),
                    Text(_getQueueStatus()),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          isInitialized ? Icons.check_circle : Icons.pending,
                          color: isInitialized ? Colors.green : Colors.orange,
                        ),
                        SizedBox(width: 8),
                        Text('Initialized: $isInitialized'),
                      ],
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          isIdentified ? Icons.person : Icons.person_outline,
                          color: isIdentified ? Colors.green : Colors.grey,
                        ),
                        SizedBox(width: 8),
                        Text('User Identified: $isIdentified'),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 16),

            // Botones de acción
            Text('Actions', style: Theme.of(context).textTheme.headlineSmall),
            SizedBox(height: 8),

            ElevatedButton.icon(
              onPressed: isInitialized && !isIdentified ? _identifyUser : null,
              icon: Icon(Icons.person_add),
              label: Text('1. Identify User'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[600],
                foregroundColor: Colors.white,
              ),
            ),

            SizedBox(height: 8),

            ElevatedButton.icon(
              onPressed: isInitialized && isIdentified ? _trackEvent : null,
              icon: Icon(Icons.analytics),
              label: Text('2. Track Event'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[600],
                foregroundColor: Colors.white,
              ),
            ),

            SizedBox(height: 8),

            ElevatedButton.icon(
              onPressed: isInitialized && isIdentified ? _trackPageView : null,
              icon: Icon(Icons.pageview),
              label: Text('3. Track Page View'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple[600],
                foregroundColor: Colors.white,
              ),
            ),

            SizedBox(height: 16),

            ElevatedButton.icon(
              onPressed: isInitialized ? _flushEvents : null,
              icon: Icon(Icons.send),
              label: Text('Flush Events'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange[600],
                foregroundColor: Colors.white,
              ),
            ),

            SizedBox(height: 24),

            // Información
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Information',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    SizedBox(height: 8),
                    Text(
                      '• This demo shows the IForevents API integration\n'
                      '• Events are batched and sent automatically\n'
                      '• Configure your API credentials in the code\n'
                      '• Check the console for detailed logs\n'
                      '• The integration includes retry logic and error handling',
                      style: TextStyle(height: 1.5),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Cleanup: flush any remaining events
    if (apiIntegration != null) {
      apiIntegration!.dispose();
    }
    super.dispose();
  }
}
