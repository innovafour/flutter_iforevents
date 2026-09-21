import 'package:amplitude_flutter/amplitude.dart';
import 'package:amplitude_flutter/autocapture/autocapture.dart';
import 'package:amplitude_flutter/configuration.dart';
import 'package:amplitude_flutter/constants.dart';
import 'package:amplitude_flutter/events/base_event.dart';
import 'package:amplitude_flutter/events/identify.dart' as amplitude_identify;
import 'package:amplitude_flutter/events/revenue.dart';
import 'package:iforevents/models/integration.dart';

class AmplitudeIntegration extends Integration {
  const AmplitudeIntegration({
    required this.apiKey,
    this.flushQueueSize = Constants.flushQueueSize,
    this.flushIntervalMillis = Constants.flushIntervalMillis,
    this.optOut = false,
    this.minIdLength,
    this.autocapture = const AutocaptureOptions(),
    this.useBatch = false,
    this.serverZone = ServerZone.us,
    super.onInit,
    super.onIdentify,
    super.onTrack,
    super.onReset,
    super.onPageView,
  });

  final String apiKey;
  final int flushQueueSize;
  final int flushIntervalMillis;
  final bool optOut;
  final int? minIdLength;

  /// Replaces the removed `defaultTracking`. The default value here resolves to
  /// exactly what `DefaultTrackingOptions()` used to produce, so behaviour is
  /// unchanged for callers that never set it.
  final Autocapture autocapture;
  final bool useBatch;
  final ServerZone serverZone;

  static Amplitude? amplitude;

  @override
  Future<void> init() async {
    super.init();

    amplitude = Amplitude(
      Configuration(
        apiKey: apiKey,
        flushQueueSize: flushQueueSize,
        flushIntervalMillis: flushIntervalMillis,
        optOut: optOut,
        minIdLength: minIdLength,
        autocapture: autocapture,
        useBatch: useBatch,
        serverZone: serverZone,
      ),
    );

    await amplitude?.isBuilt;
  }

  @override
  Future<void> identify({required IdentifyEvent event}) async {
    super.identify(event: event);

    await amplitude?.setUserId(event.customID);

    final identify = amplitude_identify.Identify();

    for (final key in event.properties.keys) {
      final value = event.properties[key];

      if (value == null || value == '' || value == 'unknown') {
        identify.unset(key);
        continue;
      }

      identify.set(key, value);
    }

    amplitude?.identify(identify);
  }

  @override
  Future<void> track({required TrackEvent event}) async {
    super.track(event: event);

    final eventProperties = <String, dynamic>{};

    for (final key in event.properties.keys) {
      final value = event.properties[key];

      if (value == null || value == '') {
        eventProperties[key] = 'unknown';
      } else {
        eventProperties[key] = value;
      }
    }

    amplitude?.track(
      BaseEvent(
        event.eventName,
        eventProperties: eventProperties.isNotEmpty ? eventProperties : null,
      ),
    );
  }

  Future<void> trackRevenue({
    required double price,
    int quantity = 1,
    String? productId,
    String? revenueType,
  }) async {
    final revenue = Revenue()
      ..price = price
      ..quantity = quantity;

    if (productId != null) {
      revenue.productId = productId;
    }

    if (revenueType != null) {
      revenue.revenueType = revenueType;
    }

    amplitude?.revenue(revenue);
  }

  Future<void> setGroup(String groupType, dynamic groupName) async {
    amplitude?.setGroup(groupType, groupName);
  }

  Future<void> groupIdentify(
    String groupType,
    dynamic groupName,
    amplitude_identify.Identify identify,
  ) async {
    amplitude?.groupIdentify(groupType, groupName, identify);
  }

  @override
  Future<void> pageView({required PageViewEvent event}) async {
    super.pageView(event: event);

    amplitude?.track(BaseEvent('page_view', eventProperties: event.toJson()));
  }

  @override
  Future<void> reset() async {
    super.reset();

    amplitude?.reset();
  }

  Future<void> flush() async {
    amplitude?.flush();
  }
}
