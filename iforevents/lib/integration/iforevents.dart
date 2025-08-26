import 'dart:async';
import 'dart:developer' as developer;

import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import 'package:iforevents/iforevents.dart';
import 'package:iforevents/models/iforevents_api_config.dart';

/// IForevents API Integration for Flutter
///
/// A comprehensive integration for the IForevents API that supports:
/// - User identification and user management
/// - Individual event tracking
/// - Batch event processing (recommended)
/// - Customizable configuration
/// - Offline event queuing
/// - Error handling and retry logic
///
/// This class implements a singleton pattern to ensure user state
/// persistence across the application lifecycle.
///
/// Usage:
/// ```dart
/// final integration = IForeventsAPIIntegration(config: config);
/// await integration.init();
///
/// // Or using the static getter
/// final integration = IForeventsAPIIntegration.instance;
/// ```
class IForeventsAPIIntegration extends Integration {
  // Singleton implementation
  static IForeventsAPIIntegration? _instance;

  // Private constructor
  IForeventsAPIIntegration._internal({required this.config}) : _dio = Dio() {
    _setupDio();
    _initializeQueue();
  }

  // Factory constructor that returns the singleton instance
  factory IForeventsAPIIntegration({required IForeventsAPIConfig config}) {
    _instance ??= IForeventsAPIIntegration._internal(config: config);
    return _instance!;
  }

  // Static getter for the instance
  static IForeventsAPIIntegration? get instance => _instance;

  final IForeventsAPIConfig config;
  final Dio _dio;
  final GetStorage _storage = GetStorage();

  static const String _userUUIDKey = 'iforevents_user_uuid';

  String? _userUUID;
  final List<IForeventsQueuedEvent> _eventQueue = [];
  Timer? _batchTimer;
  bool _isInitialized = false;
  bool _isIdentified = false;

  /// User UUID from the last identify call
  String? get userUUID => _userUUID;

  /// Whether the integration has been initialized
  bool get isInitialized => _isInitialized;

  /// Whether a user has been identified
  bool get isIdentified => _isIdentified;

  /// Number of events currently queued
  int get queuedEventsCount => _eventQueue.length;

  void _setupDio() {
    _dio.options.baseUrl = '${config.baseUrl}/v1';
    _dio.options.connectTimeout = Duration(
      milliseconds: config.connectTimeoutMs,
    );

    _dio.options.receiveTimeout = Duration(
      milliseconds: config.receiveTimeoutMs,
    );

    _dio.options.sendTimeout = Duration(milliseconds: config.sendTimeoutMs);

    // Add request interceptor for authentication
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          options.headers.addAll({
            'Content-Type': 'application/json',
            'X-Project-Key': config.projectKey,
            'X-Project-Secret': config.projectSecret,
          });

          if (_userUUID != null) {
            options.headers['X-User-UUID'] = _userUUID;
          }

          if (config.enableLogging) {
            developer.log(
              'IForevents API Request: ${options.method} ${options.path}',
              name: 'IForeventsAPI',
            );
          }

          handler.next(options);
        },
        onResponse: (response, handler) {
          if (config.enableLogging) {
            developer.log(
              'IForevents API Response: ${response.statusCode}',
              name: 'IForeventsAPI',
            );
          }

          handler.next(response);
        },
        onError: (error, handler) {
          if (config.enableLogging) {
            developer.log(
              'IForevents API Error: ${error.message}',
              name: 'IForeventsAPI',
              error: error,
            );
          }
          handler.next(error);
        },
      ),
    );

    // Add retry interceptor if enabled
    if (config.enableRetry) {
      _dio.interceptors.add(
        _IForeventsRetryInterceptor(
          dio: _dio,
          retries: config.maxRetries,
          retryDelayMs: config.retryDelayMs,
          enableLogging: config.enableLogging,
        ),
      );
    }
  }

  void _initializeQueue() {
    if (config.batchSize > 1) {
      _batchTimer = Timer.periodic(
        Duration(milliseconds: config.batchIntervalMs),
        (_) => _processBatchIfNeeded(),
      );
    }
  }

  @override
  Future<void> init() async {
    try {
      super.init();

      if (_userUUID == null) {
        _userUUID = _storage.read(_userUUIDKey);
        if (_userUUID != null) {
          _isIdentified = true;

          if (config.enableLogging) {
            developer.log(
              'Loaded saved userUUID: $_userUUID',
              name: 'IForeventsAPI',
            );
          }
        }
      } else {
        if (config.enableLogging) {
          developer.log(
            'UserUUID already loaded in singleton: $_userUUID',
            name: 'IForeventsAPI',
          );
        }
      }

      _isInitialized = true;

      if (config.enableLogging) {
        developer.log(
          'IForevents API Integration initialized successfully',
          name: 'IForeventsAPI',
        );
      }
    } catch (e) {
      if (config.enableLogging) {
        developer.log(
          'Failed to initialize IForevents API Integration',
          name: 'IForeventsAPI',
          error: e,
        );
      }
      rethrow;
    }
  }

  @override
  Future<void> identify({required IdentifyEvent event}) async {
    super.identify(event: event);

    if (!_isInitialized) {
      throw IForeventsAPIException(
        'Integration not initialized. Call init() first.',
      );
    }

    try {
      final requestData = _buildIdentifyRequest(event);

      final response = await _dio.post('/events/identify', data: requestData);

      if (response.data != null) {
        final responseData = response.data as Map<String, dynamic>;
        final user = responseData['user'] as Map<String, dynamic>?;

        if (user != null) {
          final userUUID = user['uuid'] as String?;

          if (userUUID != null) {
            await _storage.write(_userUUIDKey, userUUID);

            if (config.enableLogging) {
              developer.log(
                'UserUUID updated and saved: $userUUID',
                name: 'IForeventsAPI',
              );
            }
          }

          _isIdentified = true;

          if (config.enableLogging) {
            developer.log(
              'User identified successfully. User: $userUUID',
              name: 'IForeventsAPI',
            );
          }
        }
      }
    } catch (e) {
      if (config.enableLogging) {
        developer.log(
          'Failed to identify user: ${event.customID}',
          name: 'IForeventsAPI',
          error: e,
        );
      }

      if (config.throwOnError) {
        rethrow;
      }
    }
  }

  @override
  Future<void> track({required TrackEvent event}) async {
    super.track(event: event);

    if (!_isInitialized) {
      throw IForeventsAPIException(
        'Integration not initialized. Call init() first.',
      );
    }

    try {
      final queuedEvent = _buildTrackEventData(event);

      if (config.batchSize > 1) {
        _addToQueue(queuedEvent);
        await _processBatchIfNeeded();
      } else {
        await _sendSingleEvent(queuedEvent);
      }
    } catch (e) {
      if (config.enableLogging) {
        developer.log(
          'Failed to track event: ${event.eventName}',
          name: 'IForeventsAPI',
          error: e,
        );
      }

      if (config.throwOnError) {
        rethrow;
      }
    }
  }

  @override
  Future<void> pageView({required PageViewEvent event}) async {
    super.pageView(event: event);

    if (!_isInitialized) {
      throw IForeventsAPIException(
        'Integration not initialized. Call init() first.',
      );
    }

    final trackEvent = TrackEvent(
      eventName: 'page_view',
      eventType: EventType.screen,
      properties: {
        ...event.toJson(),
        'type': 'page_view',
        'created_at': DateTime.now().toUtc().toIso8601String(),
      },
    );

    await track(event: trackEvent);
  }

  @override
  Future<void> reset() async {
    try {
      super.reset();

      // Send any remaining queued events before resetting
      if (_eventQueue.isNotEmpty) {
        await _sendBatchEvents(List.from(_eventQueue));
        _eventQueue.clear();
      }

      // Clear userUUID both in memory and storage
      _userUUID = null;
      _userUUID = null;
      _isIdentified = false;
      await _storage.remove(_userUUIDKey);

      if (config.enableLogging) {
        developer.log(
          'IForevents API Integration reset successfully',
          name: 'IForeventsAPI',
        );
      }
    } catch (e) {
      if (config.enableLogging) {
        developer.log('Error during reset', name: 'IForeventsAPI', error: e);
      }
    }
  }

  /// Manually flush all queued events
  Future<void> flush() async {
    if (_eventQueue.isNotEmpty) {
      await _sendBatchEvents(List.from(_eventQueue));
      _eventQueue.clear();
    }
  }

  /// Get current queue status
  IForeventsQueueStatus getQueueStatus() {
    return IForeventsQueueStatus(
      queuedEvents: _eventQueue.length,
      batchSize: config.batchSize,
      isInitialized: _isInitialized,
      isIdentified: _isIdentified,
      userUUID: _userUUID,
    );
  }

  /// Get the userUUID stored in local storage (if any)
  String? getStoredUserUUID() {
    return _storage.read(_userUUIDKey);
  }

  /// Clear the stored userUUID from local storage
  Future<void> clearStoredUserUUID() async {
    await _storage.remove(_userUUIDKey);
    if (config.enableLogging) {
      developer.log(
        'Stored userUUID cleared from local storage',
        name: 'IForeventsAPI',
      );
    }
  }

  /// Reset the singleton instance completely
  /// This will create a new instance on the next factory call
  static void resetSingleton() {
    _instance?.dispose();
    _instance = null;
  }

  /// Get or create the singleton instance
  static IForeventsAPIIntegration getInstance({
    required IForeventsAPIConfig config,
  }) {
    return IForeventsAPIIntegration(config: config);
  }

  Map<String, dynamic> _buildIdentifyRequest(IdentifyEvent event) {
    final request = <String, dynamic>{'custom_id': event.customID};

    // Extract standard fields if present
    final properties = Map<String, dynamic>.from(event.properties);

    if (properties.containsKey('email')) {
      request['email'] = properties.remove('email');
    }
    if (properties.containsKey('phone_number')) {
      request['phone_number'] = properties.remove('phone_number');
    }
    if (properties.containsKey('name')) {
      request['name'] = properties.remove('name');
    }

    // Add remaining properties
    if (properties.isNotEmpty) {
      request['properties'] = properties;
    }

    return request;
  }

  IForeventsQueuedEvent _buildTrackEventData(TrackEvent event) {
    return IForeventsQueuedEvent(
      name: event.eventName,
      type: _mapEventType(event.eventType),
      properties: event.properties,
      createdAt: DateTime.now().toUtc(),
    );
  }

  String _mapEventType(EventType type) {
    switch (type) {
      case EventType.track:
        return 'track';
      case EventType.screen:
        return 'page_view';
      case EventType.alias:
        return 'track';
    }
  }

  void _addToQueue(IForeventsQueuedEvent eventData) {
    _eventQueue.add(eventData);

    if (config.enableLogging) {
      developer.log(
        'Event added to queue. Queue size: ${_eventQueue.length}/${config.batchSize}',
        name: 'IForeventsAPI',
      );
    }
  }

  Future<void> _processBatchIfNeeded() async {
    if (_eventQueue.length >= config.batchSize) {
      final batch = _eventQueue.take(config.batchSize).toList();
      _eventQueue.removeRange(0, config.batchSize);

      await _sendBatchEvents(batch);
    }
  }

  Future<void> _sendSingleEvent(IForeventsQueuedEvent eventData) async {
    try {
      await _dio.post(
        '/events/track',
        data: {
          'event_name': eventData.name,
          'properties': eventData.properties,
        },
      );

      if (config.enableLogging) {
        developer.log(
          'Single event sent successfully: ${eventData.name}',
          name: 'IForeventsAPI',
        );
      }
    } catch (e) {
      if (config.enableLogging) {
        developer.log(
          'Failed to send single event: ${eventData.name}',
          name: 'IForeventsAPI',
          error: e,
        );
      }
      rethrow;
    }
  }

  Future<void> _sendBatchEvents(List<IForeventsQueuedEvent> events) async {
    if (events.isEmpty) return;

    try {
      final body = events.map((e) => e.toJson()).toList();

      await _dio.post('/events/batch', data: {'events': body});

      if (config.enableLogging) {
        developer.log(
          'Batch of ${events.length} events sent successfully',
          name: 'IForeventsAPI',
        );
      }
    } catch (e) {
      if (config.enableLogging) {
        developer.log(
          'Failed to send batch of ${events.length} events',
          name: 'IForeventsAPI',
          error: e,
        );
      }

      // Re-queue events if configured to do so
      if (config.requeueFailedEvents) {
        _eventQueue.insertAll(0, events);
      }

      rethrow;
    }
  }

  void dispose() {
    _batchTimer?.cancel();
    _dio.close();
  }
}

/// Model for queued events
class IForeventsQueuedEvent {
  const IForeventsQueuedEvent({
    required this.name,
    required this.type,
    required this.properties,
    required this.createdAt,
  });

  final String name;
  final String type;
  final Map<String, dynamic> properties;
  final DateTime createdAt;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type,
      'properties': properties,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

/// Model for queue status information
class IForeventsQueueStatus {
  const IForeventsQueueStatus({
    required this.queuedEvents,
    required this.batchSize,
    required this.isInitialized,
    required this.isIdentified,
    this.userUUID,
  });

  final int queuedEvents;
  final int batchSize;
  final bool isInitialized;
  final bool isIdentified;
  final String? userUUID;

  Map<String, dynamic> toJson() {
    return {
      'queued_events': queuedEvents,
      'batch_size': batchSize,
      'is_initialized': isInitialized,
      'is_identified': isIdentified,
      'user_uuid': userUUID,
    };
  }
}

/// Exception class for IForevents API errors
class IForeventsAPIException implements Exception {
  const IForeventsAPIException(this.message);

  final String message;

  @override
  String toString() => 'IForeventsAPIException: $message';
}

/// Internal retry interceptor for Dio
class _IForeventsRetryInterceptor extends Interceptor {
  _IForeventsRetryInterceptor({
    required this.dio,
    required this.retries,
    required this.retryDelayMs,
    required this.enableLogging,
  });

  final Dio dio;
  final int retries;
  final int retryDelayMs;
  final bool enableLogging;

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final extra = err.requestOptions.extra;
    final retryCount = extra['retry_count'] as int? ?? 0;

    if (retryCount < retries && _shouldRetry(err)) {
      extra['retry_count'] = retryCount + 1;

      final delay = Duration(milliseconds: retryDelayMs * (retryCount + 1));
      await Future.delayed(delay);

      if (enableLogging) {
        developer.log(
          'Retrying request (${retryCount + 1}/$retries) after ${delay.inMilliseconds}ms',
          name: 'IForeventsAPI',
        );
      }

      try {
        final response = await dio.fetch(err.requestOptions);
        handler.resolve(response);
        return;
      } catch (e) {
        // Continue to next retry or fail
      }
    }

    handler.next(err);
  }

  bool _shouldRetry(DioException error) {
    final statusCode = error.response?.statusCode;

    // Retry on network errors or 5xx server errors
    return error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.connectionError ||
        (statusCode != null && statusCode >= 500);
  }
}
