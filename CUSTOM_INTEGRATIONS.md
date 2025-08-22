# Creating Custom IforEvents Integrations

This guide shows you how to create custom analytics integrations for IforEvents. By extending the `Integration` class, you can add support for any analytics platform or custom tracking solution.

## Table of Contents

1. [Basic Integration Structure](#basic-integration-structure)
2. [Simple Custom Integration](#simple-custom-integration)
3. [HTTP API Integration](#http-api-integration)
4. [Database Integration](#database-integration)
5. [Integration with Configuration](#integration-with-configuration)
6. [Advanced Features](#advanced-features)
7. [Testing Custom Integrations](#testing-custom-integrations)
8. [Best Practices](#best-practices)

## Basic Integration Structure

All custom integrations must extend the `Integration` class and implement the required methods:

```dart
import 'package:iforevents/iforevents.dart';

class MyCustomIntegration extends Integration {
  @override
  Future<void> init() async {
    // IMPORTANT: Always call super.init() first
    await super.init();
    
    // Initialize your analytics service
  }

  @override
  Future<void> identify({required IdentifyEvent event}) async {
    // IMPORTANT: Always call super.identify() first
    await super.identify(event: event);
    
    // Handle user identification
  }

  @override
  Future<void> track({required TrackEvent event}) async {
    // IMPORTANT: Always call super.track() first
    await super.track(event: event);
    
    // Handle event tracking
  }

  @override
  Future<void> reset() async {
    // IMPORTANT: Always call super.reset() first
    await super.reset();
    
    // Handle user data reset
  }

  @override
  Future<void> pageView({required PageViewEvent event}) async {
    // IMPORTANT: Always call super.pageView() first
    await super.pageView(event: event);
    
    // Handle page view tracking
    // event.toRoute contains the destination route
    // event.previousRoute contains the previous route
    // event.navigationType contains the type of navigation
  }
}
```

> **⚠️ CRITICAL: @mustCallSuper Requirement**
> 
> All Integration methods are marked with `@mustCallSuper`, which means you **MUST** call the parent method first in your override. This ensures that any callback functions (onInit, onIdentify, onTrack, onReset, onPageView) are executed properly.
>
> **Failure to call `super.method()` will result in missing functionality and potential bugs.**

## Simple Custom Integration

Here's a basic example that logs events to the console:

```dart
import 'package:iforevents/iforevents.dart';

class ConsoleLogIntegration extends Integration {
  final String prefix;
  final bool enableTimestamps;
  
  const ConsoleLogIntegration({
    this.prefix = '[Analytics]',
    this.enableTimestamps = true,
  });

  String _getTimestamp() {
    if (!enableTimestamps) return '';
    return '${DateTime.now().toIso8601String()} ';
  }

  @override
  Future<void> init() async {
    // IMPORTANT: Always call super.init() first
    await super.init();
    
    print('${_getTimestamp()}$prefix Integration initialized');
  }

  @override
  Future<void> identify({required IdentifyEvent event}) async {
    // IMPORTANT: Always call super.identify() first
    await super.identify(event: event);
    
    print('${_getTimestamp()}$prefix USER IDENTIFIED: ${event.customID}');
    print('${_getTimestamp()}$prefix User Properties: ${event.properties}');
  }

  @override
  Future<void> track({required TrackEvent event}) async {
    // IMPORTANT: Always call super.track() first
    await super.track(event: event);
    
    print('${_getTimestamp()}$prefix EVENT: ${event.eventName}');
    if (event.properties.isNotEmpty) {
      print('${_getTimestamp()}$prefix Properties: ${event.properties}');
    }
  }

  @override
  Future<void> reset() async {
    // IMPORTANT: Always call super.reset() first
    await super.reset();
    
    print('${_getTimestamp()}$prefix User data reset');
  }

  @override
  Future<void> pageView({required PageViewEvent event}) async {
    // IMPORTANT: Always call super.pageView() first
    await super.pageView(event: event);
    
    if (event.toRoute?.name != null) {
      print('${_getTimestamp()}$prefix PAGE VIEW: ${event.toRoute!.name}');
      print('${_getTimestamp()}$prefix Navigation Type: ${event.navigationType}');
      if (event.previousRoute?.name != null) {
        print('${_getTimestamp()}$prefix Previous: ${event.previousRoute!.name}');
      }
    }
  }
}
```

Usage:
```dart
await iforevents.init(integrations: [
  const ConsoleLogIntegration(
    prefix: '[MyApp Analytics]',
    enableTimestamps: true,
  ),
]);
```

## HTTP API Integration

Example integration that sends data to a REST API:

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:iforevents/iforevents.dart';

class HTTPAnalyticsIntegration extends Integration {
  final String baseUrl;
  final String apiKey;
  final Map<String, String> defaultHeaders;
  final Duration timeout;
  final bool enableLogging;
  final bool enableRetry;
  
  const HTTPAnalyticsIntegration({
    required this.baseUrl,
    required this.apiKey,
    this.defaultHeaders = const {},
    this.timeout = const Duration(seconds: 10),
    this.enableLogging = false,
    this.enableRetry = true,
  });

  String? _userId;
  String? _sessionId;

  @override
  Future<void> init() async {
    // IMPORTANT: Always call super.init() first
    await super.init();
    
    _sessionId = _generateSessionId();
    
    if (enableLogging) {
      print('HTTP Analytics initialized');
      print('Base URL: $baseUrl');
      print('Session ID: $_sessionId');
    }
    
    // Send initialization event
    await _sendRequest('/init', {
      'session_id': _sessionId,
      'timestamp': DateTime.now().toIso8601String(),
      'platform': 'flutter',
    });
  }

  @override
  Future<void> identify({required IdentifyEvent event}) async {
    // IMPORTANT: Always call super.identify() first
    await super.identify(event: event);
    
    _userId = event.customID;
    
    await _sendRequest('/identify', {
      'user_id': event.customID,
      'session_id': _sessionId,
      'properties': event.properties,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  @override
  Future<void> track({required TrackEvent event}) async {
    // IMPORTANT: Always call super.track() first
    await super.track(event: event);
    
    final payload = {
      'event': event.eventName,
      'event_type': event.eventType.toString(),
      'properties': event.properties,
      'session_id': _sessionId,
      'timestamp': DateTime.now().toIso8601String(),
    };
    
    if (_userId != null) {
      payload['user_id'] = _userId!;
    }
    
    await _sendRequest('/track', payload);
  }

  @override
  Future<void> reset() async {
    // IMPORTANT: Always call super.reset() first
    await super.reset();
    
    if (_userId != null) {
      await _sendRequest('/reset', {
        'user_id': _userId,
        'session_id': _sessionId,
        'timestamp': DateTime.now().toIso8601String(),
      });
    }
    
    _userId = null;
    _sessionId = _generateSessionId();
  }

  @override
  Future<void> pageView({required PageViewEvent event}) async {
    // IMPORTANT: Always call super.pageView() first
    await super.pageView(event: event);
    
    if (event.toRoute?.name != null) {
      await track(
        event: TrackEvent(
          eventName: 'page_view',
          eventType: EventType.screen,
          properties: {
            'page_name': event.toRoute!.name!,
            'previous_page': event.previousRoute?.name,
            'navigation_type': event.navigationType,
            'session_id': _sessionId,
          },
        ),
      );
    }
  }

  Future<void> _sendRequest(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl$endpoint'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $apiKey',
              'User-Agent': 'IforEvents-Flutter/1.0',
              ...defaultHeaders,
            },
            body: jsonEncode(data),
          )
          .timeout(timeout);

      if (enableLogging) {
        print('Request to $endpoint: ${response.statusCode}');
        if (response.statusCode >= 400) {
          print('Error response: ${response.body}');
        }
      }

      if (enableRetry && response.statusCode >= 500) {
        // Retry once for server errors
        await Future.delayed(const Duration(seconds: 1));
        await _sendRequest(endpoint, data);
      }
    } catch (e) {
      if (enableLogging) {
        print('Error sending request to $endpoint: $e');
      }
      // Don't rethrow - analytics failures shouldn't crash the app
    }
  }

  String _generateSessionId() {
    return 'sess_${DateTime.now().millisecondsSinceEpoch}_${_generateRandomString(8)}';
  }

  String _generateRandomString(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    return String.fromCharCodes(Iterable.generate(
      length,
      (_) => chars.codeUnitAt((chars.length * (DateTime.now().microsecond / 1000000)).floor()),
    ));
  }
}
```

## Database Integration

Example integration that stores analytics data locally:

```dart
import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:iforevents/iforevents.dart';
import 'package:path/path.dart';

class DatabaseIntegration extends Integration {
  final String databaseName;
  final bool enableLogging;
  
  const DatabaseIntegration({
    this.databaseName = 'analytics.db',
    this.enableLogging = false,
  });

  Database? _database;

  @override
  Future<void> init() async {
    // IMPORTANT: Always call super.init() first
    await super.init();
    
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, databaseName);
    
    _database = await openDatabase(
      path,
      version: 1,
      onCreate: _createTables,
    );
    
    if (enableLogging) {
      print('Database analytics integration initialized');
      print('Database path: $path');
    }
  }

  Future<void> _createTables(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        properties TEXT,
        created_at TEXT,
        updated_at TEXT
      )
    ''');
    
    await db.execute('''
      CREATE TABLE events (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT,
        event_name TEXT,
        event_type TEXT,
        properties TEXT,
        timestamp TEXT,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');
    
    await db.execute('''
      CREATE TABLE page_views (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT,
        page_name TEXT,
        previous_page TEXT,
        timestamp TEXT,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');
  }

  @override
  Future<void> identify({required IdentifyEvent event}) async {
    // IMPORTANT: Always call super.identify() first
    await super.identify(event: event);
    
    if (_database == null) return;
    
    final now = DateTime.now().toIso8601String();
    
    await _database!.insert(
      'users',
      {
        'id': event.customID,
        'properties': jsonEncode(event.properties),
        'created_at': now,
        'updated_at': now,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    
    if (enableLogging) {
      print('User ${event.customID} saved to database');
    }
  }

  @override
  Future<void> track({required TrackEvent event}) async {
    // IMPORTANT: Always call super.track() first
    await super.track(event: event);
    
    if (_database == null) return;
    
    // Get current user ID from the latest user record
    final userResult = await _database!.query(
      'users',
      orderBy: 'updated_at DESC',
      limit: 1,
    );
    
    final userId = userResult.isNotEmpty ? userResult.first['id'] as String? : null;
    
    await _database!.insert('events', {
      'user_id': userId,
      'event_name': event.eventName,
      'event_type': event.eventType.toString(),
      'properties': jsonEncode(event.properties),
      'timestamp': DateTime.now().toIso8601String(),
    });
    
    if (enableLogging) {
      print('Event ${event.eventName} saved to database');
    }
  }

  @override
  Future<void> reset() async {
    // IMPORTANT: Always call super.reset() first
    await super.reset();
    
    if (_database == null) return;
    
    await _database!.delete('events');
    await _database!.delete('page_views');
    await _database!.delete('users');
    
    if (enableLogging) {
      print('All analytics data cleared from database');
    }
  }

  @override
  Future<void> pageView({required PageViewEvent event}) async {
    // IMPORTANT: Always call super.pageView() first
    await super.pageView(event: event);
    
    if (_database == null || event.toRoute?.name == null) return;
    
    // Get current user ID
    final userResult = await _database!.query(
      'users',
      orderBy: 'updated_at DESC',
      limit: 1,
    );
    
    final userId = userResult.isNotEmpty ? userResult.first['id'] as String? : null;
    
    await _database!.insert('page_views', {
      'user_id': userId,
      'page_name': event.toRoute!.name!,
      'previous_page': event.previousRoute?.name,
      'navigation_type': event.navigationType,
      'timestamp': DateTime.now().toIso8601String(),
    });
    
    if (enableLogging) {
      print('Page view ${event.toRoute!.name} saved to database');
    }
  }

  // Helper method to export data
  Future<Map<String, List<Map<String, dynamic>>>> exportData() async {
    if (_database == null) return {};
    
    final users = await _database!.query('users');
    final events = await _database!.query('events');
    final pageViews = await _database!.query('page_views');
    
    return {
      'users': users,
      'events': events,
      'page_views': pageViews,
    };
  }

  // Helper method to get analytics summary
  Future<Map<String, int>> getAnalyticsSummary() async {
    if (_database == null) return {};
    
    final userCount = Sqflite.firstIntValue(
      await _database!.rawQuery('SELECT COUNT(*) FROM users'),
    ) ?? 0;
    
    final eventCount = Sqflite.firstIntValue(
      await _database!.rawQuery('SELECT COUNT(*) FROM events'),
    ) ?? 0;
    
    final pageViewCount = Sqflite.firstIntValue(
      await _database!.rawQuery('SELECT COUNT(*) FROM page_views'),
    ) ?? 0;
    
    return {
      'users': userCount,
      'events': eventCount,
      'page_views': pageViewCount,
    };
  }
}
```

## Integration with Configuration

Example of a highly configurable integration:

```dart
import 'package:iforevents/iforevents.dart';

class ConfigurableIntegration extends Integration {
  final AnalyticsConfig config;
  
  const ConfigurableIntegration({required this.config});

  @override
  Future<void> init() async {
    // IMPORTANT: Always call super.init() first
    await super.init();
    
    if (config.enableLogging) {
      print('Configurable integration initialized');
      print('Config: ${config.toString()}');
    }
  }

  @override
  Future<void> identify({required IdentifyEvent event}) async {
    // IMPORTANT: Always call super.identify() first
    await super.identify(event: event);
    
    if (!config.enableUserTracking) return;
    
    // Apply user data filters
    final filteredProperties = _filterProperties(
      event.properties,
      config.allowedUserProperties,
      config.blockedUserProperties,
    );
    
    if (config.enableLogging) {
      print('User identified: ${event.customID}');
      print('Filtered properties: $filteredProperties');
    }
    
    // Send to configured endpoints
    for (final endpoint in config.identifyEndpoints) {
      await _sendToEndpoint(endpoint, 'identify', {
        'user_id': event.customID,
        'properties': filteredProperties,
      });
    }
  }

  @override
  Future<void> track({required TrackEvent event}) async {
    // IMPORTANT: Always call super.track() first
    await super.track(event: event);
    
    // Check if event is allowed
    if (config.blockedEvents.contains(event.eventName)) {
      if (config.enableLogging) {
        print('Event ${event.eventName} blocked by configuration');
      }
      return;
    }
    
    if (config.allowedEvents.isNotEmpty && 
        !config.allowedEvents.contains(event.eventName)) {
      if (config.enableLogging) {
        print('Event ${event.eventName} not in allowed list');
      }
      return;
    }
    
    // Apply property filters
    final filteredProperties = _filterProperties(
      event.properties,
      config.allowedEventProperties,
      config.blockedEventProperties,
    );
    
    // Apply transformations
    final transformedEvent = _transformEvent(event, filteredProperties);
    
    if (config.enableLogging) {
      print('Event tracked: ${transformedEvent.eventName}');
    }
    
    // Send to configured endpoints
    for (final endpoint in config.trackEndpoints) {
      await _sendToEndpoint(endpoint, 'track', {
        'event': transformedEvent.eventName,
        'properties': transformedEvent.properties,
      });
    }
  }

  @override
  Future<void> reset() async {
    // IMPORTANT: Always call super.reset() first
    await super.reset();
    
    if (config.enableLogging) {
      print('Analytics data reset');
    }
  }

  Map<String, dynamic> _filterProperties(
    Map<String, dynamic> properties,
    List<String> allowedProperties,
    List<String> blockedProperties,
  ) {
    var filtered = Map<String, dynamic>.from(properties);
    
    // Remove blocked properties
    for (final blocked in blockedProperties) {
      filtered.remove(blocked);
    }
    
    // Keep only allowed properties (if allowedProperties is not empty)
    if (allowedProperties.isNotEmpty) {
      filtered = Map.fromEntries(
        filtered.entries.where((entry) => allowedProperties.contains(entry.key)),
      );
    }
    
    return filtered;
  }

  TrackEvent _transformEvent(TrackEvent event, Map<String, dynamic> properties) {
    // Apply event name transformations
    String eventName = event.eventName;
    if (config.eventNameMappings.containsKey(eventName)) {
      eventName = config.eventNameMappings[eventName]!;
    }
    
    // Apply property transformations
    final transformedProperties = <String, dynamic>{};
    for (final entry in properties.entries) {
      final key = config.propertyNameMappings[entry.key] ?? entry.key;
      transformedProperties[key] = entry.value;
    }
    
    return TrackEvent(
      eventName: eventName,
      eventType: event.eventType,
      properties: transformedProperties,
    );
  }

  Future<void> _sendToEndpoint(
    String endpoint,
    String type,
    Map<String, dynamic> data,
  ) async {
    // Implementation depends on endpoint type (HTTP, database, etc.)
    if (config.enableLogging) {
      print('Sending $type to $endpoint: $data');
    }
  }
}

class AnalyticsConfig {
  final bool enableUserTracking;
  final bool enableLogging;
  final List<String> allowedEvents;
  final List<String> blockedEvents;
  final List<String> allowedUserProperties;
  final List<String> blockedUserProperties;
  final List<String> allowedEventProperties;
  final List<String> blockedEventProperties;
  final Map<String, String> eventNameMappings;
  final Map<String, String> propertyNameMappings;
  final List<String> identifyEndpoints;
  final List<String> trackEndpoints;
  
  const AnalyticsConfig({
    this.enableUserTracking = true,
    this.enableLogging = false,
    this.allowedEvents = const [],
    this.blockedEvents = const [],
    this.allowedUserProperties = const [],
    this.blockedUserProperties = const [],
    this.allowedEventProperties = const [],
    this.blockedEventProperties = const [],
    this.eventNameMappings = const {},
    this.propertyNameMappings = const {},
    this.identifyEndpoints = const [],
    this.trackEndpoints = const [],
  });
  
  @override
  String toString() {
    return 'AnalyticsConfig(enableUserTracking: $enableUserTracking, '
           'enableLogging: $enableLogging, allowedEvents: $allowedEvents, '
           'blockedEvents: $blockedEvents)';
  }
}
```

Usage:
```dart
await iforevents.init(integrations: [
  ConfigurableIntegration(
    config: AnalyticsConfig(
      enableLogging: true,
      blockedEvents: ['debug_event', 'test_event'],
      blockedUserProperties: ['password', 'ssn'],
      eventNameMappings: {
        'button_click': 'user_interaction',
        'page_view': 'screen_view',
      },
      propertyNameMappings: {
        'user_id': 'userId',
        'event_time': 'timestamp',
      },
      trackEndpoints: ['http://api.example.com/track'],
      identifyEndpoints: ['http://api.example.com/identify'],
    ),
  ),
]);
```

## Testing Custom Integrations

Create comprehensive tests for your integrations:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:iforevents/iforevents.dart';

void main() {
  group('ConsoleLogIntegration', () {
    late ConsoleLogIntegration integration;
    
    setUp(() {
      integration = const ConsoleLogIntegration(
        prefix: '[Test]',
        enableTimestamps: false,
      );
    });
    
    test('should initialize without errors', () async {
      await expectLater(integration.init(), completes);
    });
    
    test('should identify users', () async {
      final event = IdentifyEvent(
        customID: 'test_user',
        properties: {'email': 'test@example.com'},
      );
      
      await expectLater(
        integration.identify(event: event),
        completes,
      );
    });
    
    test('should track events', () async {
      final event = TrackEvent(
        eventName: 'test_event',
        properties: {'key': 'value'},
      );
      
      await expectLater(
        integration.track(event: event),
        completes,
      );
    });
    
    test('should handle page views', () async {
      final event = PageViewEvent(
        navigationType: 'push',
        toRoute: RouteSettings(name: '/test'),
        previousRoute: RouteSettings(name: '/home'),
      );
      
      await expectLater(
        integration.pageView(event: event),
        completes,
      );
    });
    
    test('should reset without errors', () async {
      await expectLater(integration.reset(), completes);
    });
  });
  
  group('HTTPAnalyticsIntegration', () {
    // Mock HTTP client for testing
    // Use packages like mockito or http_mock_adapter
    
    test('should handle network errors gracefully', () async {
      // Test network failure scenarios
    });
    
    test('should retry on server errors', () async {
      // Test retry logic
    });
  });
}
```

## Best Practices

### 1. Error Handling
Always handle errors gracefully to prevent analytics failures from crashing your app:

```dart
@override
Future<void> track({required TrackEvent event}) async {
  // IMPORTANT: Always call super.track() first
  await super.track(event: event);
  
  try {
    await _sendAnalyticsData(event);
  } catch (e) {
    if (enableLogging) {
      print('Analytics error: $e');
    }
    // Don't rethrow - analytics should be fire-and-forget
  }
}
```

### 2. Performance
Avoid blocking operations on the main thread:

```dart
@override
Future<void> track({required TrackEvent event}) async {
  // IMPORTANT: Always call super.track() first
  await super.track(event: event);
  
  // Run analytics in background
  unawaited(_sendAnalyticsData(event));
}
```

### 3. Configuration
Make integrations configurable:

```dart
class MyIntegration extends Integration {
  final String apiKey;
  final bool enableDebug;
  final Duration timeout;
  
  const MyIntegration({
    required this.apiKey,
    this.enableDebug = false,
    this.timeout = const Duration(seconds: 10),
  });
}
```

### 4. Validation
Validate input data:

```dart
@override
Future<void> identify({required IdentifyEvent event}) async {
  // IMPORTANT: Always call super.identify() first
  await super.identify(event: event);
  
  if (event.customID.isEmpty) {
    if (enableLogging) {
      print('Warning: Empty user ID provided');
    }
    return;
  }
  
  // Continue with identification
}
```

### 5. Privacy
Respect user privacy:

```dart
Map<String, dynamic> _sanitizeProperties(Map<String, dynamic> properties) {
  final sanitized = Map<String, dynamic>.from(properties);
  
  // Remove sensitive data
  sanitized.remove('password');
  sanitized.remove('ssn');
  sanitized.remove('credit_card');
  
  return sanitized;
}
```

This comprehensive guide should help you create robust, maintainable custom integrations for IforEvents. Remember to test thoroughly and follow Flutter best practices for async operations and error handling.
