import 'package:iforevents/models/errors.dart';

/// Configuration for the IForevents API integration.
///
/// Only [projectKey] is needed. It is a public write key: it grants event
/// ingestion and nothing else, so embedding it in a shipped app is safe.
///
/// There is deliberately no project secret here. A value compiled into a mobile
/// binary can be extracted with `strings`, so it cannot be a secret. Reading
/// analytics requires a dashboard session, never a credential held by a client.
class IForeventsAPIConfig {
  const IForeventsAPIConfig({
    required this.projectKey,
    this.baseUrl = 'https://api.iforevents.com',
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
    this.collectPublicIP = false,
    this.onQuotaExceeded,
  });

  /// Public project write key (required).
  final String projectKey;

  /// Base URL of the IForevents API.
  final String baseUrl;

  /// Events to accumulate before sending. Set to 1 to disable batching.
  final int batchSize;

  /// How often the batch timer fires, in milliseconds.
  final int batchIntervalMs;

  final int connectTimeoutMs;
  final int receiveTimeoutMs;
  final int sendTimeoutMs;

  final bool enableRetry;
  final int maxRetries;
  final int retryDelayMs;

  final bool enableLogging;

  /// Throw instead of only logging when a request fails.
  final bool throwOnError;

  /// Re-queue events that failed to send.
  final bool requeueFailedEvents;

  /// Called once when the API starts refusing events with `quota_exceeded`
  /// (429), and again after a later success followed by a new refusal. Use
  /// it to surface an upgrade prompt; the refused events are dropped.
  final void Function(IForeventsQuotaExceededException error)? onQuotaExceeded;

  /// Resolve the device's public IP by calling a third-party service.
  ///
  /// Off by default: it sends the user's address to an unrelated host, which is
  /// a disclosure most apps do not want and some privacy regimes do not permit.
  /// The API already records the source IP of each request, so leaving this off
  /// loses nothing.
  final bool collectPublicIP;

  IForeventsAPIConfig copyWith({
    String? projectKey,
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
    bool? collectPublicIP,
  }) {
    return IForeventsAPIConfig(
      projectKey: projectKey ?? this.projectKey,
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
      collectPublicIP: collectPublicIP ?? this.collectPublicIP,
    );
  }
}
