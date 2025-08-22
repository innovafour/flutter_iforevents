import 'package:iforevents/models/integration.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class FirebaseIntegration extends Integration {
  const FirebaseIntegration({
    super.onInit,
    super.onIdentify,
    super.onTrack,
    super.onReset,
  });

  static final firebaseAnalytics = FirebaseAnalytics.instance;

  @override
  Future<void> init() async {
    await firebaseAnalytics.setAnalyticsCollectionEnabled(true);
  }

  @override
  Future<void> identify({required IdentifyEvent event}) async {
    await firebaseAnalytics.setUserId(
      id: event.customID,
      callOptions: AnalyticsCallOptions(global: true),
    );

    for (final key in event.properties.keys) {
      firebaseAnalytics.setUserProperty(
        name: key,
        value: event.properties[key].toString(),
      );
    }
  }

  @override
  Future<void> track({required TrackEvent event}) async {
    final eventProperties = <String, String>{};

    for (final key in event.properties.keys) {
      final value = event.properties[key];

      eventProperties[key] = value.toString();
    }

    await firebaseAnalytics.logEvent(
      name: event.eventName,
      parameters: eventProperties,
    );
  }

  @override
  Future<void> reset() async {
    await firebaseAnalytics.resetAnalyticsData();
  }
}
