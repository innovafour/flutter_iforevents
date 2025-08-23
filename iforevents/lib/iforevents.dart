import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:android_id/android_id.dart';
import 'package:dart_ipify/dart_ipify.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:iforevents/integration/_integration.dart';
import 'package:iforevents/models/device.dart';
import 'package:iforevents/models/pending_event.dart';
import 'package:iforevents/services/event_storage_service.dart';
import 'package:iforevents/services/background_processor.dart';
import 'package:iforevents/config/retry_config.dart';
import 'package:package_info_plus/package_info_plus.dart';

export 'package:iforevents/integration/_integration.dart';
export 'package:iforevents/integration/iforevents.dart';

/// A class for managing mobile shared events.
class Iforevents {
  /// Constructs a [Iforevents] instance.
  const Iforevents();

  static Map<String, dynamic> _identifyData = {};
  static Device? _deviceData;
  static bool _isInitialized = false;

  /// Configurable retry intervals
  static List<int> get retryIntervals => RetryConfig.retryIntervals;

  Future<void> init({List<Integration> integrations = const []}) async {
    try {
      // Initialize local storage service
      await EventStorageService.init();

      // Set callback to process pending events
      EventStorageService.setRetryCallback(_processRetryEvents);

      // Start background processing
      BackgroundProcessor.startBackgroundProcessing();

      // Initialize integrations
      final results = await IntegrationFactory.init(integrations: integrations);

      // Log initialization results
      for (final result in results) {
        if (!result.success) {
          log('Error initializing ${result.integrationName}: ${result.error}');
        }
      }

      _isInitialized = true;
      log(
        'EventStorageService and BackgroundProcessor initialized successfully',
      );
    } catch (e) {
      log('Error initializing Iforevents: $e');
      return;
    }
  }

  Future<void> identify({required IdentifyEvent event}) async {
    if (event.customID.isEmpty) return;
    if (!_isInitialized) {
      log('Iforevents is not initialized. Call init() first.');
      return;
    }

    final device = await deviceData;

    final data = {
      'ip': await ip,
      'device_ip': device.ip,
      'device_brand': device.brand,
      'device_model': device.model,
      'device_os_version': device.osVersion,
      'device_app_version': device.appVersion,
      'device_platform': device.platform,
      ...event.properties,
    };

    final results = await IntegrationFactory.identify(
      customID: event.customID,
      identifyData: data,
    );

    // Process results and handle failures
    await _handleIntegrationResults(
      results,
      PendingEvent.fromIdentifyEvent(
        event.copyWith(properties: data),
        'base_event', // Will be updated with the real integration name in _handleIntegrationResults
        retryIntervalSeconds: retryIntervals[0],
      ),
    );

    _identifyData = data;
  }

  Future<void> track({required TrackEvent event}) async {
    try {
      if (!_isInitialized) {
        log('Iforevents is not initialized. Call init() first.');
        return;
      }

      final tempData = {..._identifyData, ...event.properties};
      final processedEvent = event.copyWith(properties: flattenMap(tempData));

      final results = await IntegrationFactory.track(event: processedEvent);

      // Process results and handle failures
      await _handleIntegrationResults(
        results,
        PendingEvent.fromTrackEvent(
          processedEvent,
          'base_event', // Will be updated with the real integration name in _handleIntegrationResults
          retryIntervalSeconds: retryIntervals[0],
        ),
      );
    } catch (e) {
      log('Error in track: $e');
      return;
    }
  }

  Future<void> reset() async {
    try {
      if (!_isInitialized) {
        log('Iforevents is not initialized. Call init() first.');
        return;
      }

      final results = await IntegrationFactory.reset();

      // Log errors if any
      for (final result in results) {
        if (!result.success) {
          log('Error resetting ${result.integrationName}: ${result.error}');
        }
      }

      _identifyData = {};
    } catch (e) {
      log('Error in reset: $e');
      return;
    }
  }

  Future<void> pageViewed({required PageViewEvent event}) async {
    try {
      if (!_isInitialized) {
        log('Iforevents is not initialized. Call init() first.');
        return;
      }

      final results = await IntegrationFactory.pageViewed(event: event);

      // Process results and handle failures
      await _handleIntegrationResults(
        results,
        PendingEvent.fromPageViewEvent(
          event,
          'base_event', // Will be updated with the real integration name in _handleIntegrationResults
          retryIntervalSeconds: retryIntervals[0],
        ),
      );
    } catch (e) {
      log('Error in pageViewed: $e');
      return;
    }
  }

  static Future<String> get ip async {
    try {
      final ipv4 = await Ipify.ipv4();

      return ipv4;
    } catch (_) {
      return (await _getPublicIP()) ?? '';
    }
  }

  static Future<String?> _getPublicIP() async {
    try {
      final url = Uri.parse('https://api.ipify.org?format=json');
      final response = await HttpClient().getUrl(url).then((req) {
        return req.close();
      });

      final json = await response.transform(utf8.decoder).join();

      return jsonDecode(json)['ip'];
    } catch (e) {
      return null;
    }
  }

  static Future<Device> get deviceData async {
    if (_deviceData != null) return _deviceData!;

    final deviceInfoPlugin = DeviceInfoPlugin();
    final packageInfo = await PackageInfo.fromPlatform();

    final appVersion = packageInfo.version;
    Map<String, dynamic> result = {};

    final packageInfoData = <String, dynamic>{};

    for (final entry in packageInfo.data.entries) {
      final value = entry.value;

      if (value is DateTime) {
        packageInfoData[entry.key] = value.toIso8601String();
      }

      packageInfoData[entry.key] = value.toString();
    }

    final deviceIP = await ip;

    switch (Platform.operatingSystem) {
      case 'android':
        final androidInfo = await deviceInfoPlugin.androidInfo;

        result = {
          'id': await const AndroidId().getId(),
          'ip': deviceIP,
          'brand': androidInfo.brand,
          'model': androidInfo.model,
          'os_version': androidInfo.version.sdkInt.toString(),
          'app_version': appVersion,
          'platform': 'android',
          'data': {
            'device': androidInfo.device,
            'sdk_int': androidInfo.version.sdkInt,
            'is_physical_device': androidInfo.isPhysicalDevice,
            ...packageInfoData,
          },
        };
        break;

      case 'ios':
        final iosInfo = await deviceInfoPlugin.iosInfo;

        result = {
          'id': iosInfo.identifierForVendor,
          'ip': deviceIP,
          'brand': iosInfo.name,
          'model': iosInfo.model,
          'os_version': iosInfo.systemVersion,
          'app_version': appVersion,
          'platform': 'ios',
          'data': {
            'system_name': iosInfo.systemName,
            'is_physical_device': iosInfo.isPhysicalDevice,
            ...packageInfoData,
          },
        };
        break;
      case 'windows':
        final windowsInfo = await deviceInfoPlugin.windowsInfo;

        result = {
          'id': windowsInfo.deviceId,
          'ip': deviceIP,
          'brand': windowsInfo.computerName,
          'model': windowsInfo.displayVersion,
          'os_version': windowsInfo.buildNumber.toString(),
          'app_version': appVersion,
          'platform': 'windows',
          'data': {...packageInfoData},
        };
        break;
      default:
        result = {'error': 'OS not supported or not detected'};

        break;
    }

    final device = Device.fromMap(result);

    _deviceData = device;
    return device;
  }

  Map<String, dynamic> flattenMap(
    Map<String, dynamic> original, {
    String prefix = '',
  }) {
    final Map<String, dynamic> result = {};

    original.forEach((key, value) {
      final newKey = prefix.isEmpty ? key : '${prefix}_$key';

      if (value is Map) {
        result.addAll(
          flattenMap(Map<String, dynamic>.from(value), prefix: newKey),
        );
      } else {
        result[newKey] = value;
      }
    });

    return result;
  }

  /// Handles integration results and saves failed events
  static Future<void> _handleIntegrationResults(
    List<IntegrationResult> results,
    PendingEvent baseEvent,
  ) async {
    for (final result in results) {
      if (result.success) {
        log('Event successfully sent to ${result.integrationName}');
      } else {
        log(
          'Error sending event to ${result.integrationName}: ${result.error}',
        );

        // Create specific pending event for this integration
        final pendingEvent = baseEvent.copyWith(
          id: '${baseEvent.id}_${result.integrationName}',
          integrationName: result.integrationName,
        );

        // Save failed event for retry
        await EventStorageService.savePendingEvent(pendingEvent);
      }
    }
  }

  /// Processes pending events for retry
  static Future<void> _processRetryEvents(List<PendingEvent> events) async {
    if (!_isInitialized) return;

    log('Processing ${events.length} events for retry');

    for (final event in events) {
      try {
        IntegrationResult? result;

        // Execute the event according to its type in the specific integration
        switch (event.eventType) {
          case PendingEventType.track:
            final trackEvent = event.toOriginalEvent() as TrackEvent;
            result = await IntegrationFactory.executeSpecificIntegration(
              event.integrationName,
              (integration) => integration.track(event: trackEvent),
            );
            break;

          case PendingEventType.identify:
            final identifyEvent = event.toOriginalEvent() as IdentifyEvent;
            result = await IntegrationFactory.executeSpecificIntegration(
              event.integrationName,
              (integration) => integration.identify(event: identifyEvent),
            );
            break;

          case PendingEventType.pageView:
            final pageViewEvent = event.toOriginalEvent() as PageViewEvent;
            result = await IntegrationFactory.executeSpecificIntegration(
              event.integrationName,
              (integration) => integration.pageView(event: pageViewEvent),
            );
            break;
        }

        if (result != null) {
          if (result.success) {
            // Successful event, remove from database
            await EventStorageService.removeSuccessfulEvent(event.id);
            log('Event resent successfully: ${event.id}');
          } else {
            // Event failed, update attempt counter
            await EventStorageService.updateEventAttempt(event.id);
            log(
              'Retry failed for event: ${event.id} (${event.attemptCount + 1}/3)',
            );
          }
        } else {
          log('Integration not found for event: ${event.id}');
          await EventStorageService.updateEventAttempt(event.id);
        }
      } catch (e) {
        log('Error processing retry event ${event.id}: $e');
        await EventStorageService.updateEventAttempt(event.id);
      }
    }
  }

  /// Gets statistics of pending events
  static Map<String, int> getPendingEventsStats() {
    return EventStorageService.getPendingEventsByIntegration();
  }

  /// Gets the total number of pending events
  static int getPendingEventsCount() {
    return EventStorageService.getPendingEventsCount();
  }

  /// Sets custom retry intervals
  static bool setRetryIntervals(List<int> intervals) {
    final success = RetryConfig.setRetryIntervals(intervals);
    if (success) {
      log('Retry intervals updated: $intervals seconds');
    } else {
      log(
        'Error: Invalid retry intervals. Must be 3 values between ${RetryConfig.minimumRetryInterval} and ${RetryConfig.maximumRetryInterval} seconds',
      );
    }
    return success;
  }

  /// Applies a preset configuration of intervals
  static bool applyRetryPreset(String presetName) {
    final success = RetryConfig.applyPresetConfiguration(presetName);
    if (success) {
      log(
        'Preset configuration "$presetName" applied: ${RetryConfig.retryIntervals}',
      );
    } else {
      log('Error: Preset configuration "$presetName" not found');
    }
    return success;
  }

  /// Gets available preset configurations
  static List<String> getAvailableRetryPresets() {
    return RetryConfig.availablePresets;
  }

  /// Gets the full current configuration
  static Map<String, dynamic> getCurrentConfiguration() {
    return RetryConfig.toMap();
  }

  /// Restores configuration to defaults
  static void resetConfigurationToDefaults() {
    RetryConfig.resetToDefaults();
    log('Configuration restored to default values');
  }

  /// Clears all pending events (useful for testing)
  static Future<void> clearPendingEvents() async {
    await EventStorageService.clearAllPendingEvents();
  }

  /// Gets background processor statistics
  static Map<String, dynamic> getBackgroundProcessorStats() {
    return BackgroundProcessor.getProcessorStats();
  }

  /// Sets the background processing interval
  static bool setBackgroundProcessingInterval(int seconds) {
    final configSuccess = RetryConfig.setBackgroundProcessingInterval(seconds);
    if (configSuccess) {
      BackgroundProcessor.setProcessingInterval(seconds);
      log('Background processing interval updated: $seconds seconds');
    } else {
      log(
        'Error: Invalid interval. Must be between ${RetryConfig.minimumRetryInterval} and ${RetryConfig.maximumRetryInterval} seconds',
      );
    }
    return configSuccess;
  }

  /// Starts background processing manually
  static void startBackgroundProcessing({int intervalSeconds = 30}) {
    BackgroundProcessor.startBackgroundProcessing(
      intervalSeconds: intervalSeconds,
    );
  }

  /// Stops background processing
  static void stopBackgroundProcessing() {
    BackgroundProcessor.stopBackgroundProcessing();
  }

  /// Processes pending events immediately
  static Future<void> processEventsNow() async {
    await BackgroundProcessor.processEventsNow();
  }

  /// Processes a specific event for retry (public method)
  static Future<void> processRetryEvent(PendingEvent event) async {
    await _processRetryEvents([event]);
  }

  /// Closes the event service (call when closing the app)
  static Future<void> dispose() async {
    BackgroundProcessor.stopBackgroundProcessing();
    await EventStorageService.close();
    _isInitialized = false;
  }
}

extension StringExtension on String {
  String get toSnakeCase {
    final exp = RegExp(r'(?<!^)([A-Z])');

    return replaceAllMapped(exp, (Match m) => '_${m[0]}').toLowerCase();
  }
}
