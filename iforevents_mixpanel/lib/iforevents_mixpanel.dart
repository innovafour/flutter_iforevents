import 'package:iforevents/models/integration.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';

class MixpanelIntegration extends Integration {
  const MixpanelIntegration({
    /// Mixpanel project token
    required this.token,
    super.onInit,
    super.onIdentify,
    super.onTrack,
    super.onReset,
  });

  final String token;

  static Mixpanel? mixpanel;
  static People? people;

  @override
  Future<void> init() async {
    super.init();

    mixpanel = await Mixpanel.init(token, trackAutomaticEvents: false);

    people = mixpanel?.getPeople();

    mixpanel?.setLoggingEnabled(false);
  }

  @override
  Future<void> identify({required IdentifyEvent event}) async {
    super.identify(event: event);

    people?.deleteUser();
    await mixpanel?.clearSuperProperties();

    final currentDistinctID = await mixpanel?.getDistinctId() ?? '';

    mixpanel?.alias(event.customID, currentDistinctID);
    await mixpanel?.identify(event.customID);

    people = mixpanel?.getPeople();

    const unknown = 'unknown';

    final customData = {...event.properties};

    for (final key in customData.keys) {
      final value = customData[key];

      if (value == null) continue;
      if (value == '') continue;
      if (value == unknown) continue;

      people?.unset(key);
      people?.set(key, value.toString());
    }

    await Future.delayed(const Duration(milliseconds: 1000));

    await mixpanel?.flush();
  }

  @override
  Future<void> track({required TrackEvent event}) async {
    super.track(event: event);

    await mixpanel?.track(
      event.eventName,
      properties: event.properties.map((key, value) {
        if (value == null || value == '') {
          return MapEntry(key, 'unknown');
        }

        return MapEntry(key, value.toString());
      }),
    );
  }

  @override
  Future<void> reset() async {
    super.reset();

    await mixpanel?.flush();
    await mixpanel?.reset();
  }
}
