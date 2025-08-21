import 'package:iforevents/models/event_type.dart';
import 'package:iforevents/models/integration.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class FirebaseIntegration extends Integration {
  const FirebaseIntegration();

  static final firebaseAnalytics = FirebaseAnalytics.instance;

  @override
  Future<void> init() async {
    await firebaseAnalytics.setAnalyticsCollectionEnabled(true);
  }

  @override
  Future<void> identify({
    required String id,
    required Map<String, dynamic> data,
    bool isTheFirstTime = false,
  }) async {
    await firebaseAnalytics.setUserId(
      id: id,
      callOptions: AnalyticsCallOptions(global: true),
    );

    for (final key in data.keys) {
      firebaseAnalytics.setUserProperty(name: key, value: data[key].toString());
    }
  }

  @override
  Future<void> track({
    required String eventName,
    EventType eventType = EventType.track,
    Map<String, dynamic> properties = const {},
  }) async {
    final eventProperties = <String, String>{};

    for (final key in properties.keys) {
      final value = properties[key];

      eventProperties[key] = value.toString();
    }

    await firebaseAnalytics.logEvent(
      name: eventName,
      parameters: eventProperties,
    );
  }

  @override
  Future<void> reset() async {
    await firebaseAnalytics.resetAnalyticsData();
  }
}
