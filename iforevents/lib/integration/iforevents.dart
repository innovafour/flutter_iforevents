import 'dart:async';
import 'dart:developer' as developer;

import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import 'package:iforevents/iforevents.dart';
import 'package:iforevents/models/iforevents_api_config.dart';
import 'package:uuid/uuid.dart';

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

  static const String _userIdKey = 'iforevents_user_id';
  static const String _identifiedKey = 'iforevents_user_identified';

  /// The id every request carries in `X-User-Id`: an anonymous id generated
  /// on first launch (`anon_...`), or the `customID` of the last identify.
  /// Without it the api would file events under a profile derived from the
  /// device's address, merging every user behind one carrier or NAT.
  String? _userId;
  final List<IForeventsQueuedEvent> _eventQueue = [];
  Timer? _batchTimer;
  bool _isInitialized = false;
  bool _isIdentified = false;

  /// The id events are attributed to (anonymous until identify).
  String? get userId => _userId;

  /// Whether the integration has been initialized
  bool get isInitialized => _isInitialized;

  /// Whether a user has been identified
  bool get isIdentified => _isIdentified;

  /// Number of events currently queued
  int get queuedEventsCount => _eventQueue.length;

  void _setupDio() {
    Iforevents.collectPublicIP = config.collectPublicIP;

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
          });

          if (_userId != null) {
            options.headers['X-User-Id'] = _userId;
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

      if (_userId == null) {
        final stored = _storage.read<String>(_userIdKey);
        if (stored != null && stored.isNotEmpty) {
          _userId = stored;
          _isIdentified = _storage.read<bool>(_identifiedKey) ?? false;

          if (config.enableLogging) {
            developer.log(
              'Loaded saved user id: $_userId',
              name: 'IForeventsAPI',
            );
          }
        } else {
          await _setUser(_anonymousId(), identified: false);

          if (config.enableLogging) {
            developer.log(
              'Generated anonymous user id: $_userId',
              name: 'IForeventsAPI',
            );
          }
        }
      } else {
        if (config.enableLogging) {
          developer.log(
            'User id already loaded in singleton: $_userId',
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
      // Attribute from now on, even if the profile request itself fails:
      // the api creates the profile on the first event it sees for this id.
      if (event.customID.isNotEmpty) {
        await _setUser(event.customID, identified: true);
      }

      final requestData = _buildIdentifyRequest(event);

      await _dio.post('/events/identify', data: requestData);

      if (config.enableLogging) {
        developer.log(
          'User identified successfully. User: $_userId',
          name: 'IForeventsAPI',
        );
      }
    } catch (e) {
      final error = _classify(e);
      _noteOutcome(error);

      if (config.enableLogging) {
        developer.log(
          'Failed to identify user: ${event.customID}',
          name: 'IForeventsAPI',
          error: error,
        );
      }

      if (config.throwOnError) {
        throw error;
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

      // Forget the person; the next events belong to a fresh anonymous id.
      await _setUser(_anonymousId(), identified: false);

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
      userId: _userId,
    );
  }

  /// Get the user id stored in local storage (if any)
  String? getStoredUserId() {
    return _storage.read<String>(_userIdKey);
  }

  /// Clear the stored user id from local storage; the next init generates
  /// a new anonymous one.
  Future<void> clearStoredUserId() async {
    await _storage.remove(_userIdKey);
    await _storage.remove(_identifiedKey);
    if (config.enableLogging) {
      developer.log(
        'Stored user id cleared from local storage',
        name: 'IForeventsAPI',
      );
    }
  }

  Future<void> _setUser(String id, {required bool identified}) async {
    _userId = id;
    _isIdentified = identified;
    await _storage.write(_userIdKey, id);
    await _storage.write(_identifiedKey, identified);
  }

  /// A fresh anonymous id, unrelated to anything the server derives.
  static String _anonymousId() {
    return 'anon_${const Uuid().v4().replaceAll('-', '')}';
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

  /// Set after a `quota_exceeded` answer; cleared by the next accepted request.
  bool _quotaExceeded = false;

  /// Whether the last ingest attempt was refused for an exhausted quota.
  bool get isQuotaExceeded => _quotaExceeded;

  /// Maps a transport error to the typed exceptions of [errors.dart].
  IForeventsAPIException _classify(Object error) {
    if (error is IForeventsAPIException) return error;
    if (error is! DioException) {
      return IForeventsAPIException(error.toString());
    }
    final response = error.response;
    final status = response?.statusCode;
    final data = response?.data;
    final details = data is Map<String, dynamic> ? data : null;
    final code = details?['error'];
    final message =
        (details?['message'] ?? code ?? error.message ?? 'request failed')
            .toString();

    if (status == 429 && code == 'quota_exceeded') {
      return IForeventsQuotaExceededException(
        message,
        details: details,
        limit: _asInt(details?['limit']),
        used: _asInt(details?['used']),
        organizationUuid: details?['org_uuid'] as String?,
      );
    }
    if (status == 429) {
      final header = response?.headers.value('retry-after');
      final seconds = header == null ? null : int.tryParse(header);
      return IForeventsRateLimitedException(
        message,
        details: details,
        retryAfter: seconds == null ? null : Duration(seconds: seconds),
      );
    }
    if (status == 401 || status == 403) {
      return IForeventsAuthException(
        message,
        statusCode: status,
        details: details,
      );
    }
    return IForeventsAPIException(
      message,
      statusCode: status,
      details: details,
    );
  }

  static int? _asInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  /// Quota and credential failures are permanent for the events at hand.
  bool _isPermanent(IForeventsAPIException error) =>
      error is IForeventsQuotaExceededException ||
      error is IForeventsAuthException;

  void _noteOutcome(IForeventsAPIException? error) {
    if (error is IForeventsQuotaExceededException) {
      if (!_quotaExceeded) {
        _quotaExceeded = true;
        config.onQuotaExceeded?.call(error);
      }
    } else if (error == null) {
      _quotaExceeded = false;
    }
  }

  Future<void> _sendSingleEvent(IForeventsQueuedEvent eventData) async {
    try {
      await _dio.post(
        '/events/track',
        data: {
          'event_name': eventData.name,
          // Without this the server defaults every event to "track" and page
          // views become indistinguishable from ordinary events.
          'event_type': eventData.type,
          'properties': eventData.properties,
        },
      );

      _noteOutcome(null);

      if (config.enableLogging) {
        developer.log(
          'Single event sent successfully: ${eventData.name}',
          name: 'IForeventsAPI',
        );
      }
    } catch (e) {
      final error = _classify(e);
      _noteOutcome(error);

      if (config.enableLogging) {
        developer.log(
          'Failed to send single event: ${eventData.name}',
          name: 'IForeventsAPI',
          error: error,
        );
      }
      throw error;
    }
  }

  Future<void> _sendBatchEvents(List<IForeventsQueuedEvent> events) async {
    if (events.isEmpty) return;

    try {
      final body = events.map((e) => e.toJson()).toList();

      await _dio.post('/events/batch', data: {'events': body});
      _noteOutcome(null);

      if (config.enableLogging) {
        developer.log(
          'Batch of ${events.length} events sent successfully',
          name: 'IForeventsAPI',
        );
      }
    } catch (e) {
      final error = _classify(e);
      _noteOutcome(error);

      if (config.enableLogging) {
        developer.log(
          'Failed to send batch of ${events.length} events',
          name: 'IForeventsAPI',
          error: error,
        );
      }

      // Transient failures go back to the front of the queue; an exhausted
      // quota or a refused key would fail the same way forever, so those
      // events are dropped.
      if (config.requeueFailedEvents && !_isPermanent(error)) {
        _eventQueue.insertAll(0, events);
      }

      throw error;
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
    this.userId,
  });

  final int queuedEvents;
  final int batchSize;
  final bool isInitialized;
  final bool isIdentified;

  /// The id events are attributed to (`X-User-Id`).
  final String? userId;

  Map<String, dynamic> toJson() {
    return {
      'queued_events': queuedEvents,
      'batch_size': batchSize,
      'is_initialized': isInitialized,
      'is_identified': isIdentified,
      'user_id': userId,
    };
  }
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

      final delay = _delayFor(err, retryCount);
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

    // Retry on network errors, 5xx server errors and short rate limits. A
    // quota_exceeded 429 is not a rate limit: it holds until the next month
    // or a plan change, so retrying it is pointless.
    return error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.connectionError ||
        (statusCode != null && statusCode >= 500) ||
        (statusCode == 429 && !_isQuotaExceeded(error));
  }

  static bool _isQuotaExceeded(DioException error) {
    final data = error.response?.data;
    return data is Map && data['error'] == 'quota_exceeded';
  }

  /// Server-suggested wait for a 429, else the linear backoff.
  Duration _delayFor(DioException error, int attempt) {
    final header = error.response?.headers.value('retry-after');
    final seconds = header == null ? null : int.tryParse(header);
    if (error.response?.statusCode == 429 && seconds != null && seconds > 0) {
      return Duration(seconds: seconds);
    }
    return Duration(milliseconds: retryDelayMs * (attempt + 1));
  }
}
