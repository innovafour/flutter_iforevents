// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:iforevents/iforevents.dart';
import 'package:iforevents/models/iforevents_api_config.dart';

/// Ejemplo completo de uso de la integración IForevents API
///
/// Este ejemplo muestra cómo:
/// 1. Configurar la integración con diferentes opciones
/// 2. Inicializar IForevents con la integración API
/// 3. Identificar usuarios
/// 4. Enviar eventos individuales y por lotes
/// 5. Manejar el estado de la cola
/// 6. Configurar diferentes modos de operación
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IForevents API Example',
      home: IForeventsExample(),
    );
  }
}

class IForeventsExample extends StatefulWidget {
  const IForeventsExample({super.key});

  @override
  State<IForeventsExample> createState() => _IForeventsExampleState();
}

class _IForeventsExampleState extends State<IForeventsExample> {
  late IForeventsAPIIntegration apiIntegration;
  late Iforevents iforevents;

  IForeventsQueueStatus? queueStatus;
  bool isInitialized = false;

  @override
  void initState() {
    super.initState();
    _setupIForevents();
  }

  /// Configuración de IForevents con diferentes ejemplos de configuración
  Future<void> _setupIForevents() async {
    // Ejemplo 1: Configuración para desarrollo/debug
    final debugConfig = IForeventsAPIConfig(
      projectKey: 'your-project-key',
      projectSecret: 'your-project-secret',
      baseUrl: 'https://your-api-domain.com',
      batchSize: 5, // Lotes más pequeños para testing
      batchIntervalMs: 3000, // Revisar cada 3 segundos
      enableLogging: true, // Activar logs detallados
      throwOnError: true, // Lanzar excepciones para debugging
      enableRetry: true,
      maxRetries: 2,
    );

    // Ejemplo 2: Configuración básica (recomendada para producción)
    final basicConfig = IForeventsAPIConfig(
      projectKey: 'your-project-key',
      projectSecret: 'your-project-secret',
      baseUrl: 'https://your-api-domain.com',
      batchSize: 10, // Enviar en lotes de 10 eventos
      enableLogging: false, // Desactivar logs en producción
    );

    // Ejemplo 3: Configuración para envío inmediato (sin batching)
    final immediateConfig = IForeventsAPIConfig(
      projectKey: 'your-project-key',
      projectSecret: 'your-project-secret',
      baseUrl: 'https://your-api-domain.com',
      batchSize: 1, // Envío inmediato
      enableLogging: true,
      requireIdentifyBeforeTrack: false, // Permitir tracking sin identificar
    );

    // Ejemplo 4: Configuración de alta frecuencia
    final highVolumeConfig = IForeventsAPIConfig(
      projectKey: 'your-project-key',
      projectSecret: 'your-project-secret',
      baseUrl: 'https://your-api-domain.com',
      batchSize: 50, // Lotes grandes
      batchIntervalMs: 10000, // Revisar cada 10 segundos
      connectTimeoutMs: 15000, // Timeout más largo
      receiveTimeoutMs: 15000,
      requeueFailedEvents: true, // Reintentizar eventos fallidos
    );

    // Usar configuración debug para este ejemplo
    apiIntegration = IForeventsAPIIntegration(config: debugConfig);

    iforevents = const Iforevents();

    // Inicializar IForevents con la integración API
    await iforevents.init(integrations: [apiIntegration]);

    setState(() {
      isInitialized = true;
    });
  }

  /// Ejemplo de identificación de usuario
  Future<void> _identifyUser() async {
    try {
      await iforevents.identify(
        event: IdentifyEvent(
          customID: 'user_123',
          properties: {
            'email': 'user@example.com',
            'name': 'Juan Pérez',
            'phone_number': '+34612345678',
            'age': 30,
            'plan': 'premium',
            'signup_date': '2024-01-15',
            'country': 'ES',
            'preferred_language': 'es',
          },
        ),
      );

      _updateQueueStatus();
      _showSnackBar('Usuario identificado correctamente');
    } catch (e) {
      _showSnackBar('Error al identificar usuario: $e');
    }
  }

  /// Ejemplo de tracking de eventos individuales
  Future<void> _trackSingleEvent() async {
    try {
      iforevents.track(
        event: TrackEvent(
          eventName: 'button_click',
          properties: {
            'button_id': 'login_btn',
            'page': 'homepage',
            'timestamp': DateTime.now().toIso8601String(),
            'user_agent': 'flutter_app',
          },
        ),
      );

      _updateQueueStatus();
      _showSnackBar('Evento enviado');
    } catch (e) {
      _showSnackBar('Error al enviar evento: $e');
    }
  }

  /// Ejemplo de múltiples eventos para testing de batching
  Future<void> _trackMultipleEvents() async {
    try {
      // Simular múltiples eventos para probar el batching
      final events = [
        'page_view_home',
        'button_click_signup',
        'form_submit_contact',
        'video_play_intro',
        'download_app',
        'share_content',
        'search_performed',
        'filter_applied',
        'product_viewed',
        'add_to_cart',
      ];

      for (int i = 0; i < events.length; i++) {
        iforevents.track(
          event: TrackEvent(
            eventName: events[i],
            properties: {
              'event_index': i,
              'batch_test': true,
              'timestamp': DateTime.now().toIso8601String(),
              'category': i % 2 == 0 ? 'interaction' : 'navigation',
            },
          ),
        );

        // Pequeña pausa para simular eventos en tiempo real
        await Future.delayed(Duration(milliseconds: 100));
      }

      _updateQueueStatus();
      _showSnackBar('${events.length} eventos enviados');
    } catch (e) {
      _showSnackBar('Error al enviar eventos: $e');
    }
  }

  /// Ejemplo de page view tracking
  Future<void> _trackPageView() async {
    try {
      await iforevents.pageViewed(
        event: PageViewEvent(
          navigationType: 'push',
          toRoute: RouteSettings(name: '/dashboard'),
          previousRoute: RouteSettings(name: '/home'),
        ),
      );

      _updateQueueStatus();
      _showSnackBar('Page view tracked');
    } catch (e) {
      _showSnackBar('Error al trackear page view: $e');
    }
  }

  /// Ejemplo de flush manual de la cola
  Future<void> _flushQueue() async {
    try {
      await apiIntegration.flush();
      _updateQueueStatus();
      _showSnackBar('Cola vaciada manualmente');
    } catch (e) {
      _showSnackBar('Error al vaciar cola: $e');
    }
  }

  /// Ejemplo de reset de la integración
  Future<void> _resetIntegration() async {
    try {
      await iforevents.reset();
      _updateQueueStatus();
      _showSnackBar('Integración reseteada');
    } catch (e) {
      _showSnackBar('Error al resetear: $e');
    }
  }

  void _updateQueueStatus() {
    setState(() {
      queueStatus = apiIntegration.getQueueStatus();
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('IForevents API Integration'),
        backgroundColor: Colors.blue[700],
      ),
      body: !isInitialized
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Estado de la integración
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Estado de la Integración',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          SizedBox(height: 8),
                          if (queueStatus != null) ...[
                            _buildStatusRow(
                              'Inicializada',
                              queueStatus!.isInitialized,
                            ),
                            _buildStatusRow(
                              'Usuario identificado',
                              queueStatus!.isIdentified,
                            ),
                            _buildStatusRow(
                              'Eventos en cola',
                              queueStatus!.queuedEvents,
                            ),
                            _buildStatusRow(
                              'Tamaño de lote',
                              queueStatus!.batchSize,
                            ),
                            if (queueStatus!.sessionUUID != null)
                              _buildStatusRow(
                                'Session UUID',
                                queueStatus!.sessionUUID!,
                              ),
                            if (queueStatus!.userUUID != null)
                              _buildStatusRow(
                                'User UUID',
                                queueStatus!.userUUID!,
                              ),
                          ] else
                            Text('Actualizando estado...'),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 16),

                  // Botones de acción
                  Text(
                    'Acciones de Testing',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  SizedBox(height: 8),

                  ElevatedButton(
                    onPressed: _identifyUser,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: Text('1. Identificar Usuario'),
                  ),

                  SizedBox(height: 8),

                  ElevatedButton(
                    onPressed: _trackSingleEvent,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                    child: Text('2. Enviar Evento Individual'),
                  ),

                  SizedBox(height: 8),

                  ElevatedButton(
                    onPressed: _trackMultipleEvents,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                    ),
                    child: Text('3. Enviar Múltiples Eventos (Batch Test)'),
                  ),

                  SizedBox(height: 8),

                  ElevatedButton(
                    onPressed: _trackPageView,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                    ),
                    child: Text('4. Track Page View'),
                  ),

                  SizedBox(height: 16),

                  Text(
                    'Gestión de Cola',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  SizedBox(height: 8),

                  ElevatedButton(
                    onPressed: _flushQueue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                    ),
                    child: Text('Vaciar Cola Manualmente'),
                  ),

                  SizedBox(height: 8),

                  ElevatedButton(
                    onPressed: _resetIntegration,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: Text('Reset Integración'),
                  ),

                  SizedBox(height: 8),

                  ElevatedButton(
                    onPressed: _updateQueueStatus,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                    ),
                    child: Text('Actualizar Estado'),
                  ),

                  SizedBox(height: 32),

                  // Información adicional
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Información de Uso',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          SizedBox(height: 8),
                          Text(
                            '• La integración está configurada en modo debug con logs habilitados\n'
                            '• Los eventos se agrupan en lotes de 5 para testing\n'
                            '• Los lotes se procesan cada 3 segundos\n'
                            '• Los errores lanzan excepciones para debugging\n'
                            '• Los eventos fallidos se re-encolan automáticamente',
                            style: Theme.of(context).textTheme.bodyMedium,
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

  Widget _buildStatusRow(String label, dynamic value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.w500)),
          Text(
            value.toString(),
            style: TextStyle(
              color: value is bool ? (value ? Colors.green : Colors.red) : null,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // Limpiar recursos si es necesario
    apiIntegration.dispose();
    super.dispose();
  }
}

/// Ejemplos de configuraciones específicas para diferentes casos de uso

class IForeventsConfigExamples {
  /// Configuración para aplicaciones de producción
  static IForeventsAPIConfig production({
    required String projectKey,
    required String projectSecret,
    required String baseUrl,
  }) {
    return IForeventsAPIConfig(
      projectKey: projectKey,
      projectSecret: projectSecret,
      baseUrl: baseUrl,
      batchSize: 20, // Lotes más grandes para eficiencia
      batchIntervalMs: 10000, // Revisar cada 10 segundos
      enableLogging: false, // Sin logs en producción
      throwOnError: false, // No lanzar excepciones en producción
      enableRetry: true,
      maxRetries: 3,
      retryDelayMs: 2000,
      connectTimeoutMs: 15000,
      receiveTimeoutMs: 15000,
    );
  }

  /// Configuración para desarrollo y testing
  static IForeventsAPIConfig development({
    required String projectKey,
    required String projectSecret,
    required String baseUrl,
  }) {
    return IForeventsAPIConfig(
      projectKey: projectKey,
      projectSecret: projectSecret,
      baseUrl: baseUrl,
      batchSize: 5, // Lotes pequeños para testing
      batchIntervalMs: 3000, // Revisar frecuentemente
      enableLogging: true, // Logs detallados
      throwOnError: true, // Lanzar excepciones para debugging
      enableRetry: true,
      maxRetries: 2,
      retryDelayMs: 1000,
    );
  }

  /// Configuración para aplicaciones offline-first
  static IForeventsAPIConfig offlineFirst({
    required String projectKey,
    required String projectSecret,
    required String baseUrl,
  }) {
    return IForeventsAPIConfig(
      projectKey: projectKey,
      projectSecret: projectSecret,
      baseUrl: baseUrl,
      batchSize: 100, // Lotes muy grandes
      batchIntervalMs: 30000, // Revisar cada 30 segundos
      enableRetry: true,
      maxRetries: 5, // Más reintentos
      retryDelayMs: 3000,
      requeueFailedEvents: true, // Reencolar eventos fallidos
      connectTimeoutMs: 20000,
      receiveTimeoutMs: 20000,
    );
  }

  /// Configuración para envío en tiempo real (sin batching)
  static IForeventsAPIConfig realTime({
    required String projectKey,
    required String projectSecret,
    required String baseUrl,
  }) {
    return IForeventsAPIConfig(
      projectKey: projectKey,
      projectSecret: projectSecret,
      baseUrl: baseUrl,
      batchSize: 1, // Sin batching
      enableRetry: true,
      maxRetries: 2,
      retryDelayMs: 500,
      connectTimeoutMs: 5000,
      receiveTimeoutMs: 5000,
    );
  }
}
