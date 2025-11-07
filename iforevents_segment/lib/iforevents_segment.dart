import 'package:iforevents/models/integration.dart';
import 'package:segment_analytics/analytics.dart';
import 'package:segment_analytics/client.dart';
import 'package:segment_analytics/event.dart' hide TrackEvent, IdentifyEvent;
import 'package:segment_analytics/state.dart';

class SegmentIntegration extends Integration {
  const SegmentIntegration({
    required this.writeKey,
    this.debug = false,
    super.onInit,
    super.onIdentify,
    super.onTrack,
    super.onReset,
    super.onPageView,
  });

  final String writeKey;
  final bool debug;

  static Analytics? analytics;

  @override
  Future<void> init() async {
    super.init();

    analytics = createClient(Configuration(writeKey));
  }

  @override
  Future<void> identify({required IdentifyEvent event}) async {
    super.identify(event: event);

    final traits = <String, dynamic>{};

    for (final key in event.properties.keys) {
      final value = event.properties[key];

      if (value == null || value == '' || value == 'unknown') {
        continue;
      }

      traits[key] = value;
    }

    analytics?.identify(
      userId: event.customID,
      userTraits: UserTraits.fromJson(traits),
    );
  }

  @override
  Future<void> track({required TrackEvent event}) async {
    super.track(event: event);

    final properties = <String, dynamic>{};

    for (final key in event.properties.keys) {
      final value = event.properties[key];

      if (value == null || value == '') {
        properties[key] = 'unknown';
      } else {
        properties[key] = value;
      }
    }

    analytics?.track(
      event.eventName,
      properties: properties.isNotEmpty ? properties : null,
    );
  }

  @override
  Future<void> pageView({required PageViewEvent event}) async {
    super.pageView(event: event);

    final properties = event.toJson();

    analytics?.screen(
      event.toRoute?.name ?? 'Unknown Screen',
      properties: properties.isNotEmpty ? properties : null,
    );
  }

  @override
  Future<void> reset() async {
    super.reset();

    analytics?.reset();
  }

  Future<void> group({
    required String groupId,
    Map<String, dynamic>? traits,
  }) async {
    analytics?.group(groupId, groupTraits: GroupTraits.fromJson(traits ?? {}));
  }

  Future<void> alias({required String alias}) async {
    analytics?.alias(alias);
  }

  Future<void> flush() async {
    analytics?.flush();
  }
}
