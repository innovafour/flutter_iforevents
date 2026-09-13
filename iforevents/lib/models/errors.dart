/// Errors raised by the IForevents API integration.
///
/// The API answers every failure with `{"error": ...}`; machine-readable
/// failures also carry a stable code in `error` and the prose in `message`
/// (for example `quota_exceeded`). The integration maps the ones an app can
/// act on to the classes below and treats them as permanent: the affected
/// events are dropped instead of re-queued, because retrying an exhausted
/// quota or a revoked key only burns battery.
library;

/// Base class for API failures.
class IForeventsAPIException implements Exception {
  const IForeventsAPIException(this.message, {this.statusCode, this.details});

  /// Human-readable description.
  final String message;

  /// HTTP status of the failed request, when there was a response.
  final int? statusCode;

  /// Decoded error body, when the API sent JSON.
  final Map<String, dynamic>? details;

  /// The stable machine-readable code (`error` field) when the API set one.
  String? get code {
    final value = details?['error'];
    return value is String ? value : null;
  }

  @override
  String toString() => 'IForeventsAPIException: $message';
}

/// The organization is past its monthly event quota and grace period (429,
/// `quota_exceeded`). Events sent while this holds are refused by the API;
/// the integration drops them and stops re-queueing until the next call
/// succeeds. Upgrade the plan or wait for the next month.
class IForeventsQuotaExceededException extends IForeventsAPIException {
  const IForeventsQuotaExceededException(
    super.message, {
    super.details,
    this.limit,
    this.used,
    this.organizationUuid,
  }) : super(statusCode: 429);

  /// Monthly event limit of the plan.
  final int? limit;

  /// Events already counted this month.
  final int? used;

  /// Organization the quota belongs to.
  final String? organizationUuid;

  @override
  String toString() =>
      'IForeventsQuotaExceededException: $message'
      '${limit != null ? ' ($used/$limit)' : ''}';
}

/// The project key was refused (401 unknown or rotated key, 403 disabled
/// project). Permanent until the app ships a valid key.
class IForeventsAuthException extends IForeventsAPIException {
  const IForeventsAuthException(
    super.message, {
    super.statusCode,
    super.details,
  });

  @override
  String toString() => 'IForeventsAuthException: $message';
}

/// Too many requests in a short window (429 without a quota code). The
/// integration retries after [retryAfter] when retries are enabled and
/// re-queues the events otherwise.
class IForeventsRateLimitedException extends IForeventsAPIException {
  const IForeventsRateLimitedException(
    super.message, {
    super.details,
    this.retryAfter,
  }) : super(statusCode: 429);

  /// Server-suggested wait, from the Retry-After header.
  final Duration? retryAfter;

  @override
  String toString() => 'IForeventsRateLimitedException: $message';
}
