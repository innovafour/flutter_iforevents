import 'dart:async';
import 'dart:developer';
import '../models/pending_event.dart';
import 'event_storage_service.dart';
import '../iforevents.dart';

/// Service for processing pending events in background
class BackgroundProcessor {
  static Timer? _processingTimer;
  static bool _isProcessing = false;
  static int _processingIntervalSeconds = 30; // Default interval

  /// Starts automatic processing of pending events
  static void startBackgroundProcessing({int intervalSeconds = 30}) {
    _processingIntervalSeconds = intervalSeconds;

    // Cancel existing timer if there is one
    stopBackgroundProcessing();

    log(
      'Starting background processing every $_processingIntervalSeconds seconds',
    );

    // Process immediately
    _processEvents();

    // Configure periodic timer
    _processingTimer = Timer.periodic(
      Duration(seconds: _processingIntervalSeconds),
      (_) => _processEvents(),
    );
  }

  /// Stops automatic processing
  static void stopBackgroundProcessing() {
    _processingTimer?.cancel();
    _processingTimer = null;
    log('Background processing stopped');
  }

  /// Processes pending events manually
  static Future<void> processEventsNow() async {
    await _processEvents();
  }

  /// Processes pending events internally
  static Future<void> _processEvents() async {
    if (_isProcessing) {
      log('Processing already in progress, skipping...');
      return;
    }

    _isProcessing = true;

    try {
      // Get events ready for retry
      final eventsToRetry = EventStorageService.getEventsReadyForRetry();

      if (eventsToRetry.isNotEmpty) {
        log('Processing ${eventsToRetry.length} pending events');

        // Process each event
        for (final event in eventsToRetry) {
          await _processSingleEvent(event);

          // Small pause between events to avoid overload
          await Future.delayed(const Duration(milliseconds: 100));
        }

        // Clean up events that have exceeded maximum attempts
        await _cleanupExpiredEvents();
      }
    } catch (e) {
      log('Error during background processing: $e');
    } finally {
      _isProcessing = false;
    }
  }

  /// Processes an individual event
  static Future<void> _processSingleEvent(PendingEvent event) async {
    try {
      log(
        'Processing event: ${event.id} (attempt ${event.attemptCount + 1}/3)',
      );

      // Use the public processing method from the main class
      await Iforevents.processRetryEvent(event);
    } catch (e) {
      log('Error processing event ${event.id}: $e');

      // Update attempt counter in case of error
      await EventStorageService.updateEventAttempt(event.id);
    }
  }

  /// Cleans up events that have exceeded maximum attempts
  static Future<void> _cleanupExpiredEvents() async {
    try {
      await EventStorageService.removeExpiredEvents();
      log('Expired events cleanup completed');
    } catch (e) {
      log('Error cleaning up expired events: $e');
    }
  }

  /// Gets processor statistics
  static Map<String, dynamic> getProcessorStats() {
    return {
      'isRunning': _processingTimer?.isActive ?? false,
      'isProcessing': _isProcessing,
      'intervalSeconds': _processingIntervalSeconds,
      'pendingEvents': EventStorageService.getPendingEventsCount(),
      'eventsByIntegration':
          EventStorageService.getPendingEventsByIntegration(),
    };
  }

  /// Configures the processing interval
  static void setProcessingInterval(int seconds) {
    if (seconds < 10) {
      log('Warning: Very short interval, minimum recommended 10 seconds');
    }

    _processingIntervalSeconds = seconds;

    // Restart timer if it's active
    if (_processingTimer?.isActive == true) {
      startBackgroundProcessing(intervalSeconds: seconds);
    }
  }

  /// Checks if the processor is active
  static bool get isActive => _processingTimer?.isActive ?? false;

  /// Checks if it's currently processing
  static bool get isProcessing => _isProcessing;

  /// Gets the current processing interval
  static int get processingInterval => _processingIntervalSeconds;
}
