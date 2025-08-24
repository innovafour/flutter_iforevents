// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:iforevents/iforevents.dart';
import 'package:iforevents/models/iforevents_api_config.dart';

/// Complete example of using the IForevents API integration
///
/// This example shows how to:
/// 1. Configure the integration with different options
/// 2. Initialize IForevents with the API integration
/// 3. Identify users
/// 4. Send individual and batch events
/// 5. Manage queue status
/// 6. Configure different operation modes

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

  /// IForevents configuration with different example setups
  Future<void> _setupIForevents() async {
    // Example 1: Development/debug configuration
    final debugConfig = IForeventsAPIConfig(
      projectKey: 'your-project-key',
      projectSecret: 'your-project-secret',
      baseUrl: 'https://your-api-domain.com',
      batchSize: 5, // Smaller batches for testing
      batchIntervalMs: 3000, // Check every 3 seconds
      enableLogging: true, // Enable detailed logs
      throwOnError: true, // Throw exceptions for debugging
      enableRetry: true,
      maxRetries: 2,
    );

    // Example 2: Basic configuration (recommended for production)
    final basicConfig = IForeventsAPIConfig(
      projectKey: 'your-project-key',
      projectSecret: 'your-project-secret',
      baseUrl: 'https://your-api-domain.com',
      batchSize: 10, // Send in batches of 10 events
      enableLogging: false, // Disable logs in production
    );

    // Example 3: Immediate sending configuration (no batching)
    final immediateConfig = IForeventsAPIConfig(
      projectKey: 'your-project-key',
      projectSecret: 'your-project-secret',
      baseUrl: 'https://your-api-domain.com',
      batchSize: 1, // Immediate sending
      enableLogging: true,
    );

    // Example 4: High frequency configuration
    final highVolumeConfig = IForeventsAPIConfig(
      projectKey: 'your-project-key',
      projectSecret: 'your-project-secret',
      baseUrl: 'https://your-api-domain.com',
      batchSize: 50, // Large batches
      batchIntervalMs: 10000, // Check every 10 seconds
      connectTimeoutMs: 15000, // Longer timeout
      receiveTimeoutMs: 15000,
      requeueFailedEvents: true, // Retry failed events
    );

    // Use debug configuration for this example
    apiIntegration = IForeventsAPIIntegration(config: debugConfig);

    iforevents = const Iforevents();

    // Initialize IForevents with API integration
    await iforevents.init(integrations: [apiIntegration]);

    setState(() {
      isInitialized = true;
    });
  }

  /// Example of user identification
  Future<void> _identifyUser() async {
    try {
      await iforevents.identify(
        event: IdentifyEvent(
          customID: 'user_123',
          properties: {
            'email': 'john.smith@example.com',
            'name': 'John Smith',
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
      _showSnackBar('User identified successfully');
    } catch (e) {
      _showSnackBar('Error identifying user: $e');
    }
  }

  /// Example of tracking individual events
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
      _showSnackBar('Event sent');
    } catch (e) {
      _showSnackBar('Error sending event: $e');
    }
  }

  /// Example of multiple events for batch testing
  // Small pause to simulate real-time events
  Future<void> _trackMultipleEvents() async {
    try {
      // Simulate multiple events to test batching
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

        // Small pause to simulate real-time events
        await Future.delayed(Duration(milliseconds: 100));
      }

      _updateQueueStatus();
      _showSnackBar('${events.length} events sent');
    } catch (e) {
      _showSnackBar('Error sending events: $e');
    }
  }

  /// Example of page view tracking
  /// Example of page view tracking
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
      _showSnackBar('Error tracking page view: $e');
    }
  }

  /// Example of manual queue flush
  /// Example of manual queue flush
  Future<void> _flushQueue() async {
    try {
      await apiIntegration.flush();
      _updateQueueStatus();
      _showSnackBar('Queue flushed manually');
    } catch (e) {
      _showSnackBar('Error flushing queue: $e');
    }
  }

  /// Example of integration reset
  /// Example of integration reset
  Future<void> _resetIntegration() async {
    try {
      await iforevents.reset();
      _updateQueueStatus();
      _showSnackBar('Integration reset');
    } catch (e) {
      _showSnackBar('Error resetting: $e');
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
                  // Integration status
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Integration Status',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          SizedBox(height: 8),
                          if (queueStatus != null) ...[
                            _StatusRow(
                              label: 'Initialized',
                              value: queueStatus!.isInitialized,
                            ),
                            _StatusRow(
                              label: 'User Identified',
                              value: queueStatus!.isIdentified,
                            ),
                            _StatusRow(
                              label: 'Queued Events',
                              value: queueStatus!.queuedEvents,
                            ),
                            _StatusRow(
                              label: 'Batch Size',
                              value: queueStatus!.batchSize,
                            ),
                            if (queueStatus!.sessionUUID != null)
                              _StatusRow(
                                label: 'Session UUID',
                                value: queueStatus!.sessionUUID!,
                              ),
                            if (queueStatus!.userUUID != null)
                              _StatusRow(
                                label: 'User UUID',
                                value: queueStatus!.userUUID!,
                              ),
                          ] else
                            Text('Updating state...'),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 16),

                  // Action buttons
                  Text(
                    'Testing Actions',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  SizedBox(height: 8),

                  ElevatedButton(
                    onPressed: _identifyUser,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: Text(
                      '1. Identify User',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),

                  SizedBox(height: 8),

                  ElevatedButton(
                    onPressed: _trackSingleEvent,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                    child: Text(
                      '2. Send Single Event',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),

                  SizedBox(height: 8),

                  ElevatedButton(
                    onPressed: _trackMultipleEvents,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                    ),
                    child: Text(
                      '3. Send Multiple Events (Batch Test)',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),

                  SizedBox(height: 8),

                  ElevatedButton(
                    onPressed: _trackPageView,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                    ),
                    child: Text(
                      '4. Track Page View',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),

                  SizedBox(height: 16),

                  Text(
                    'Queue Management',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  SizedBox(height: 8),

                  ElevatedButton(
                    onPressed: _flushQueue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                    ),
                    child: Text(
                      'Flush Queue Manually',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),

                  SizedBox(height: 8),

                  ElevatedButton(
                    onPressed: _resetIntegration,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: Text(
                      'Reset Integration',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),

                  SizedBox(height: 8),

                  ElevatedButton(
                    onPressed: _updateQueueStatus,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                    ),
                    child: Text(
                      'Update Status',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),

                  SizedBox(height: 32),

                  // Additional information
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Usage Information',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          SizedBox(height: 8),
                          Text(
                            '• The integration is configured in debug mode with logs enabled\n'
                            '• Events are grouped in batches of 5 for testing\n'
                            '• Batches are processed every 3 seconds\n'
                            '• Errors throw exceptions for debugging\n'
                            '• Failed events are automatically re-queued',
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

  @override
  void dispose() {
    // Clean up resources if necessary
    apiIntegration.dispose();
    super.dispose();
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({required this.label, required this.value});

  final String label;
  final dynamic value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.w500)),
          SizedBox(
            width: 100,
            child: Text(
              value.toString(),
              style: TextStyle(
                color: value is bool
                    ? (value ? Colors.green : Colors.red)
                    : null,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Examples of specific configurations for different use cases
/// Examples of specific configurations for different use cases

class IForeventsConfigExamples {
  /// Configuration for production applications
  static IForeventsAPIConfig production({
    required String projectKey,
    required String projectSecret,
    required String baseUrl,
  }) {
    return IForeventsAPIConfig(
      projectKey: projectKey,
      projectSecret: projectSecret,
      baseUrl: baseUrl,
      batchSize: 20, // Larger batches for efficiency
      batchIntervalMs: 10000, // Check every 10 seconds
      enableLogging: false, // No logs in production
      throwOnError: false, // Do not throw exceptions in production
      enableRetry: true,
      maxRetries: 3,
      retryDelayMs: 2000,
      connectTimeoutMs: 15000,
      receiveTimeoutMs: 15000,
    );
  }

  /// Configuration for development and testing
  /// Configuration for development and testing
  static IForeventsAPIConfig development({
    required String projectKey,
    required String projectSecret,
    required String baseUrl,
  }) {
    return IForeventsAPIConfig(
      projectKey: projectKey,
      projectSecret: projectSecret,
      baseUrl: baseUrl,
      batchSize: 5, // Small batches for testing
      batchIntervalMs: 3000, // Check frequently
      enableLogging: true, // Detailed logs
      throwOnError: true, // Throw exceptions for debugging
      enableRetry: true,
      maxRetries: 2,
      retryDelayMs: 1000,
    );
  }

  /// Configuration for offline-first applications
  /// Configuration for offline-first applications
  static IForeventsAPIConfig offlineFirst({
    required String projectKey,
    required String projectSecret,
    required String baseUrl,
  }) {
    return IForeventsAPIConfig(
      projectKey: projectKey,
      projectSecret: projectSecret,
      baseUrl: baseUrl,
      batchSize: 100, // Very large batches
      batchIntervalMs: 30000, // Check every 30 seconds
      enableRetry: true,
      maxRetries: 5, // More retries
      retryDelayMs: 3000,
      requeueFailedEvents: true, // Re-queue failed events
      connectTimeoutMs: 20000,
      receiveTimeoutMs: 20000,
    );
  }

  /// Configuration for real-time sending (no batching)
  /// Configuration for real-time sending (no batching)
  static IForeventsAPIConfig realTime({
    required String projectKey,
    required String projectSecret,
    required String baseUrl,
  }) {
    return IForeventsAPIConfig(
      projectKey: projectKey,
      projectSecret: projectSecret,
      baseUrl: baseUrl,
      batchSize: 1, // No batching
      enableRetry: true,
      maxRetries: 2,
      retryDelayMs: 500,
      connectTimeoutMs: 5000,
      receiveTimeoutMs: 5000,
    );
  }
}
