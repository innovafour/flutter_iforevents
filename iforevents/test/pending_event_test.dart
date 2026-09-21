import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iforevents/config/retry_config.dart';
import 'package:iforevents/models/event.dart';
import 'package:iforevents/models/identify.dart';
import 'package:iforevents/models/pageview.dart';
import 'package:iforevents/models/pending_event.dart';

void main() {
  setUp(RetryConfig.resetToDefaults);

  group('PendingEvent round trips', () {
    test('a track event survives queueing', () {
      const original = TrackEvent(
        eventName: 'checkout_started',
        properties: {'plan': 'pro', 'seats': 3},
        eventType: EventType.track,
      );

      final restored =
          PendingEvent.fromTrackEvent(original, 'iforevents').toOriginalEvent()
              as TrackEvent;

      expect(restored.eventName, original.eventName);
      expect(restored.eventType, original.eventType);
      expect(restored.properties, original.properties);
    });

    test('a screen event keeps its type', () {
      const original = TrackEvent(
        eventName: 'home_viewed',
        eventType: EventType.screen,
      );

      final restored =
          PendingEvent.fromTrackEvent(original, 'iforevents').toOriginalEvent()
              as TrackEvent;

      expect(restored.eventType, EventType.screen);
    });

    test('an identify event survives queueing', () {
      const original = IdentifyEvent(
        customID: 'user-1',
        properties: {'email': 'ada@example.com'},
      );

      final restored =
          PendingEvent.fromIdentifyEvent(
                original,
                'iforevents',
              ).toOriginalEvent()
              as IdentifyEvent;

      expect(restored.customID, 'user-1');
      expect(restored.properties['email'], 'ada@example.com');
    });

    test('a page view survives queueing', () {
      const original = PageViewEvent(
        navigationType: 'push',
        toRoute: RouteSettings(name: '/checkout'),
        previousRoute: RouteSettings(name: '/cart'),
      );

      final restored =
          PendingEvent.fromPageViewEvent(
                original,
                'iforevents',
              ).toOriginalEvent()
              as PageViewEvent;

      expect(restored.navigationType, 'push');
      expect(restored.toRoute?.name, '/checkout');
      expect(restored.previousRoute?.name, '/cart');
    });
  });

  group('PendingEvent.shouldRetry', () {
    PendingEvent build({required int attemptCount, required Duration age}) {
      return PendingEvent(
        id: 'id',
        eventType: PendingEventType.track,
        eventData: const {'eventName': 'x', 'properties': {}},
        integrationName: 'iforevents',
        attemptCount: attemptCount,
        lastAttempt: DateTime.now().subtract(age),
        createdAt: DateTime.now().subtract(age),
      );
    }

    test('waits until the backoff for the attempt has elapsed', () {
      expect(
        build(attemptCount: 0, age: const Duration(seconds: 5)).shouldRetry,
        isFalse,
      );

      expect(
        build(attemptCount: 0, age: const Duration(seconds: 31)).shouldRetry,
        isTrue,
      );
    });

    test('uses a longer backoff for later attempts', () {
      // Attempt 2 waits 120s, so 60s is still too early.
      expect(
        build(attemptCount: 1, age: const Duration(seconds: 60)).shouldRetry,
        isFalse,
      );

      expect(
        build(attemptCount: 1, age: const Duration(seconds: 121)).shouldRetry,
        isTrue,
      );
    });

    // Without this, a permanently failing event retries forever.
    test('gives up once the attempt cap is reached', () {
      expect(
        build(
          attemptCount: RetryConfig.maxRetryAttempts,
          age: const Duration(days: 1),
        ).shouldRetry,
        isFalse,
      );
    });

    test('honours a custom backoff configuration', () {
      RetryConfig.setRetryIntervals([10, 20, 30]);

      expect(
        build(attemptCount: 0, age: const Duration(seconds: 11)).shouldRetry,
        isTrue,
      );
    });
  });

  test('copyWith replaces only what it is given', () {
    final event = PendingEvent(
      id: 'id',
      eventType: PendingEventType.track,
      eventData: const {'eventName': 'x', 'properties': {}},
      integrationName: 'iforevents',
      lastAttempt: DateTime.now(),
      createdAt: DateTime.now(),
    );

    final updated = event.copyWith(attemptCount: 2);

    expect(updated.attemptCount, 2);
    expect(updated.id, event.id);
    expect(updated.integrationName, event.integrationName);
  });
}
