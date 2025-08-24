/// Configuration class for IForevents API Integration
class IForeventsAPIConfig {
  const IForeventsAPIConfig({
    required this.projectKey,
    required this.projectSecret,
    required this.baseUrl,
    this.batchSize = 10,
    this.batchIntervalMs = 5000,
    this.connectTimeoutMs = 10000,
    this.receiveTimeoutMs = 10000,
    this.sendTimeoutMs = 10000,
    this.enableRetry = true,
    this.maxRetries = 3,
    this.retryDelayMs = 1000,
    this.enableLogging = false,
    this.throwOnError = false,
    this.requeueFailedEvents = true,
  });

  /// Project API key (required)
  final String projectKey;

  /// Project API secret (required)
  final String projectSecret;

  /// Base URL for the IForevents API (required)
  final String baseUrl;

  /// Number of events to batch before sending (default: 10)
  /// Set to 1 to disable batching
  final int batchSize;

  /// Interval in milliseconds to check for batch processing (default: 5000ms)
  final int batchIntervalMs;

  /// Connection timeout in milliseconds (default: 10000ms)
  final int connectTimeoutMs;

  /// Receive timeout in milliseconds (default: 10000ms)
  final int receiveTimeoutMs;

  /// Send timeout in milliseconds (default: 10000ms)
  final int sendTimeoutMs;

  /// Enable automatic retry on failure (default: true)
  final bool enableRetry;

  /// Maximum number of retries (default: 3)
  final int maxRetries;

  /// Delay between retries in milliseconds (default: 1000ms)
  final int retryDelayMs;

  /// Enable debug logging (default: false)
  final bool enableLogging;

  /// Throw exceptions on errors instead of just logging (default: false)
  final bool throwOnError;

  /// Re-queue failed events for retry (default: true)
  final bool requeueFailedEvents;

  IForeventsAPIConfig copyWith({
    String? projectKey,
    String? projectSecret,
    String? baseUrl,
    int? batchSize,
    int? batchIntervalMs,
    int? connectTimeoutMs,
    int? receiveTimeoutMs,
    int? sendTimeoutMs,
    bool? enableRetry,
    int? maxRetries,
    int? retryDelayMs,
    bool? enableLogging,
    bool? throwOnError,
    bool? requeueFailedEvents,
  }) {
    return IForeventsAPIConfig(
      projectKey: projectKey ?? this.projectKey,
      projectSecret: projectSecret ?? this.projectSecret,
      baseUrl: baseUrl ?? this.baseUrl,
      batchSize: batchSize ?? this.batchSize,
      batchIntervalMs: batchIntervalMs ?? this.batchIntervalMs,
      connectTimeoutMs: connectTimeoutMs ?? this.connectTimeoutMs,
      receiveTimeoutMs: receiveTimeoutMs ?? this.receiveTimeoutMs,
      sendTimeoutMs: sendTimeoutMs ?? this.sendTimeoutMs,
      enableRetry: enableRetry ?? this.enableRetry,
      maxRetries: maxRetries ?? this.maxRetries,
      retryDelayMs: retryDelayMs ?? this.retryDelayMs,
      enableLogging: enableLogging ?? this.enableLogging,
      throwOnError: throwOnError ?? this.throwOnError,
      requeueFailedEvents: requeueFailedEvents ?? this.requeueFailedEvents,
    );
  }
}
