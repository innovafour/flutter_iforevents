import 'dart:async';
import 'dart:developer';
import 'package:get_storage/get_storage.dart';
import 'package:iforevents/models/pending_event.dart';

class EventStorageService {
  static const String _storageKey = 'pending_events';
  static GetStorage? _storage;
  static Timer? _retryTimer;

  /// Initializes the storage service
  static Future<void> init() async {
    try {
      await GetStorage.init();
      _storage = GetStorage();

      // Start automatic processing of pending events
      _startRetryTimer();

      log('EventStorageService initialized correctly');
    } catch (e) {
      log('Error initializing EventStorageService: $e');
    }
  }

  /// Saves a pending event in the local database
  static Future<void> savePendingEvent(PendingEvent event) async {
    try {
      final events = _getAllEventsMap();
      events[event.id] = event.toJson();
      await _storage?.write(_storageKey, events);
      log('Event saved: ${event.id} for ${event.integrationName}');
    } catch (e) {
      log('Error saving pending event: $e');
    }
  }

  /// Removes a successful event from the database
  static Future<void> removeSuccessfulEvent(String eventId) async {
    try {
      final events = _getAllEventsMap();
      events.remove(eventId);
      await _storage?.write(_storageKey, events);
      log('Event successfully removed: $eventId');
    } catch (e) {
      log('Error removing event: $e');
    }
  }

  /// Updates the attempt counter of an event
  static Future<void> updateEventAttempt(String eventId) async {
    try {
      final events = _getAllEventsMap();
      final eventData = events[eventId];

      if (eventData != null) {
        final event = PendingEvent.fromJson(
          Map<String, dynamic>.from(eventData),
        );
        final updatedEvent = event.copyWith(
          attemptCount: event.attemptCount + 1,
          lastAttempt: DateTime.now(),
        );

        // If already attempted 3 times, remove the event
        if (updatedEvent.attemptCount >= 3) {
          events.remove(eventId);
          log('Event removed after 3 attempts: $eventId');
        } else {
          events[eventId] = updatedEvent.toJson();
          log(
            'Attempt updated for event: $eventId (${updatedEvent.attemptCount}/3)',
          );
        }

        await _storage?.write(_storageKey, events);
      }
    } catch (e) {
      log('Error updating event attempt: $e');
    }
  }

  /// Gets all pending events that are ready for retry
  static List<PendingEvent> getEventsReadyForRetry() {
    try {
      final allEvents = _getAllEvents();
      return allEvents.where((event) => event.shouldRetry).toList();
    } catch (e) {
      log('Error getting events for retry: $e');
      return [];
    }
  }

  /// Gets pending events by specific integration
  static List<PendingEvent> getEventsByIntegration(String integrationName) {
    try {
      final allEvents = _getAllEvents();
      return allEvents
          .where(
            (event) =>
                event.integrationName == integrationName && event.shouldRetry,
          )
          .toList();
    } catch (e) {
      log('Error getting events by integration: $e');
      return [];
    }
  }

  /// Gets events ready for retry (alias for compatibility)
  static List<PendingEvent> getEventsForRetry() {
    return getEventsReadyForRetry();
  }

  /// Removes expired events that have exceeded maximum lifetime
  static Future<void> removeExpiredEvents({Duration? maxAge}) async {
    try {
      final cutoffTime = DateTime.now().subtract(
        maxAge ?? const Duration(days: 7),
      );
      final events = _getAllEventsMap();
      final allEvents = _getAllEvents();

      final expiredEventIds = allEvents
          .where((event) => event.createdAt.isBefore(cutoffTime))
          .map((event) => event.id)
          .toList();

      for (final eventId in expiredEventIds) {
        events.remove(eventId);
      }

      if (expiredEventIds.isNotEmpty) {
        await _storage?.write(_storageKey, events);
        log('Removed ${expiredEventIds.length} expired events');
      }
    } catch (e) {
      log('Error removing expired events: $e');
    }
  }

  /// Gets the total number of pending events
  static int getPendingEventsCount() {
    try {
      final events = _getAllEventsMap();
      return events.length;
    } catch (e) {
      log('Error getting pending events count: $e');
      return 0;
    }
  }

  /// Gets pending events statistics by integration
  static Map<String, int> getPendingEventsByIntegration() {
    try {
      final allEvents = _getAllEvents();
      final stats = <String, int>{};

      for (final event in allEvents) {
        stats[event.integrationName] = (stats[event.integrationName] ?? 0) + 1;
      }

      return stats;
    } catch (e) {
      log('Error getting statistics: $e');
      return {};
    }
  }

  /// Clears all pending events (useful for testing or reset)
  static Future<void> clearAllPendingEvents() async {
    try {
      await _storage?.remove(_storageKey);
      log('All pending events have been removed');
    } catch (e) {
      log('Error clearing pending events: $e');
    }
  }

  /// Gets all events as a map from storage
  static Map<String, dynamic> _getAllEventsMap() {
    try {
      final data = _storage?.read(_storageKey);
      if (data == null) return {};
      return Map<String, dynamic>.from(data);
    } catch (e) {
      log('Error reading events from storage: $e');
      return {};
    }
  }

  /// Gets all events as a list of PendingEvent
  static List<PendingEvent> _getAllEvents() {
    try {
      final eventsMap = _getAllEventsMap();
      return eventsMap.values
          .map(
            (eventData) =>
                PendingEvent.fromJson(Map<String, dynamic>.from(eventData)),
          )
          .toList();
    } catch (e) {
      log('Error converting events: $e');
      return [];
    }
  }

  /// Starts the timer to process pending events automatically
  static void _startRetryTimer() {
    _retryTimer?.cancel();

    // Process events every 30 seconds
    _retryTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _processRetryEvents();
    });
  }

  /// Processes pending events that are ready for retry
  static void _processRetryEvents() {
    try {
      final eventsToRetry = getEventsReadyForRetry();

      if (eventsToRetry.isNotEmpty) {
        log('Processing ${eventsToRetry.length} events for retry');

        // Notify that there are events ready for retry
        // This will be handled by the Iforevents class
        _onRetryEventsReady?.call(eventsToRetry);
      }
    } catch (e) {
      log('Error processing events for retry: $e');
    }
  }

  /// Callback to notify when there are events ready for retry
  static void Function(List<PendingEvent>)? _onRetryEventsReady;

  /// Sets the callback for events ready for retry
  static void setRetryCallback(void Function(List<PendingEvent>) callback) {
    _onRetryEventsReady = callback;
  }

  /// Stops the retry timer
  static void stopRetryTimer() {
    _retryTimer?.cancel();
    _retryTimer = null;
  }

  /// Closes the storage service
  static Future<void> close() async {
    try {
      stopRetryTimer();
      log('EventStorageService closed correctly');
    } catch (e) {
      log('Error closing EventStorageService: $e');
    }
  }
}
