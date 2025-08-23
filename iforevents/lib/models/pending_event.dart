import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:iforevents/models/event.dart';
import 'package:iforevents/models/identify.dart';
import 'package:iforevents/models/pageview.dart';
import '../config/retry_config.dart';

enum PendingEventType { track, identify, pageView }

class PendingEvent extends Equatable {
  final String id;
  final PendingEventType eventType;
  final Map<String, dynamic> eventData;
  final String integrationName;
  final int attemptCount;
  final DateTime lastAttempt;
  final int retryIntervalSeconds;
  final DateTime createdAt;

  const PendingEvent({
    required this.id,
    required this.eventType,
    required this.eventData,
    required this.integrationName,
    this.attemptCount = 0,
    required this.lastAttempt,
    this.retryIntervalSeconds = 30,
    required this.createdAt,
  });

  PendingEvent copyWith({
    String? id,
    PendingEventType? eventType,
    Map<String, dynamic>? eventData,
    String? integrationName,
    int? attemptCount,
    DateTime? lastAttempt,
    int? retryIntervalSeconds,
    DateTime? createdAt,
  }) {
    return PendingEvent(
      id: id ?? this.id,
      eventType: eventType ?? this.eventType,
      eventData: eventData ?? this.eventData,
      integrationName: integrationName ?? this.integrationName,
      attemptCount: attemptCount ?? this.attemptCount,
      lastAttempt: lastAttempt ?? this.lastAttempt,
      retryIntervalSeconds: retryIntervalSeconds ?? this.retryIntervalSeconds,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Checks if it's time to retry the event
  bool get shouldRetry {
    if (attemptCount >= RetryConfig.maxRetryAttempts) return false;

    final nextRetryTime = lastAttempt.add(
      Duration(seconds: _getRetryInterval()),
    );

    return DateTime.now().isAfter(nextRetryTime);
  }

  /// Calculates the retry interval based on the number of attempts
  int _getRetryInterval() {
    final interval = RetryConfig.getRetryIntervalForAttempt(attemptCount + 1);
    return interval ?? RetryConfig.retryIntervals.last;
  }

  /// Converts the pending event back to the original event
  dynamic toOriginalEvent() {
    switch (eventType) {
      case PendingEventType.track:
        return TrackEvent(
          eventName: eventData['eventName'] as String,
          properties: Map<String, dynamic>.from(eventData['properties'] ?? {}),
          eventType: EventType.values.firstWhere(
            (e) => e.toString() == eventData['eventType'],
            orElse: () => EventType.track,
          ),
        );
      case PendingEventType.identify:
        return IdentifyEvent(
          customID: eventData['customID'] as String,
          properties: Map<String, dynamic>.from(eventData['properties'] ?? {}),
        );
      case PendingEventType.pageView:
        return PageViewEvent(
          navigationType: eventData['navigationType'] as String,
          toRoute: eventData['toRoute'] != null
              ? RouteSettings(name: eventData['toRoute'] as String)
              : null,
          previousRoute: eventData['previousRoute'] != null
              ? RouteSettings(name: eventData['previousRoute'] as String)
              : null,
        );
    }
  }

  /// Creates a PendingEvent from a TrackEvent
  static PendingEvent fromTrackEvent(
    TrackEvent event,
    String integrationName, {
    int retryIntervalSeconds = 30,
  }) {
    return PendingEvent(
      id: '${DateTime.now().millisecondsSinceEpoch}_${integrationName}_track',
      eventType: PendingEventType.track,
      eventData: {
        'eventName': event.eventName,
        'properties': event.properties,
        'eventType': event.eventType.toString(),
      },
      integrationName: integrationName,
      lastAttempt: DateTime.now(),
      retryIntervalSeconds: retryIntervalSeconds,
      createdAt: DateTime.now(),
    );
  }

  /// Creates a PendingEvent from an IdentifyEvent
  static PendingEvent fromIdentifyEvent(
    IdentifyEvent event,
    String integrationName, {
    int retryIntervalSeconds = 30,
  }) {
    return PendingEvent(
      id: '${DateTime.now().millisecondsSinceEpoch}_${integrationName}_identify',
      eventType: PendingEventType.identify,
      eventData: {'customID': event.customID, 'properties': event.properties},
      integrationName: integrationName,
      lastAttempt: DateTime.now(),
      retryIntervalSeconds: retryIntervalSeconds,
      createdAt: DateTime.now(),
    );
  }

  /// Creates a PendingEvent from a PageViewEvent
  static PendingEvent fromPageViewEvent(
    PageViewEvent event,
    String integrationName, {
    int retryIntervalSeconds = 30,
  }) {
    return PendingEvent(
      id: '${DateTime.now().millisecondsSinceEpoch}_${integrationName}_pageview',
      eventType: PendingEventType.pageView,
      eventData: {
        'navigationType': event.navigationType,
        'toRoute': event.toRoute?.name,
        'previousRoute': event.previousRoute?.name,
      },
      integrationName: integrationName,
      lastAttempt: DateTime.now(),
      retryIntervalSeconds: retryIntervalSeconds,
      createdAt: DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
    id,
    eventType,
    eventData,
    integrationName,
    attemptCount,
    lastAttempt,
    retryIntervalSeconds,
    createdAt,
  ];

  /// Converts the PendingEvent to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'eventType': eventType.name,
      'eventData': eventData,
      'integrationName': integrationName,
      'attemptCount': attemptCount,
      'lastAttempt': lastAttempt.millisecondsSinceEpoch,
      'retryIntervalSeconds': retryIntervalSeconds,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  /// Creates a PendingEvent from JSON
  static PendingEvent fromJson(Map<String, dynamic> json) {
    return PendingEvent(
      id: json['id'] as String,
      eventType: PendingEventType.values.firstWhere(
        (e) => e.name == json['eventType'],
      ),
      eventData: Map<String, dynamic>.from(json['eventData']),
      integrationName: json['integrationName'] as String,
      attemptCount: json['attemptCount'] as int,
      lastAttempt: DateTime.fromMillisecondsSinceEpoch(
        json['lastAttempt'] as int,
      ),
      retryIntervalSeconds: json['retryIntervalSeconds'] as int,
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int),
    );
  }
}
