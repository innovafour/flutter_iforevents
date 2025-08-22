import 'package:facebook_app_events/facebook_app_events.dart';
import 'package:iforevents/models/integration.dart';

class MetaIntegration extends Integration {
  const MetaIntegration({
    super.onInit,
    super.onIdentify,
    super.onTrack,
    super.onReset,
  });

  static final facebookAppEvents = FacebookAppEvents();

  @override
  Future<void> identify({required IdentifyEvent event}) async {
    super.identify(event: event);

    await facebookAppEvents.setUserID(event.customID);
    await facebookAppEvents.setUserData(
      email: event.properties['email'],
      firstName: event.properties['first_name'],
      lastName: event.properties['last_name'],
      phone: event.properties['phone'],
    );
  }

  @override
  Future<void> track({required TrackEvent event}) async {
    super.track(event: event);

    final eventName = eventsMap[event.eventName] ?? event.eventName;

    final properties = <String, dynamic>{};

    for (final key in event.properties.keys) {
      final value = event.properties[key];

      if (value is List) {
        continue;
      }

      properties[key] = value;
    }

    if (event.eventName == 'Order Completed') {
      await facebookAppEvents.logPurchase(
        parameters: properties,
        amount: event.properties['total_amount'] ?? 0.0,
        currency: event.properties['currency'] ?? 'COP',
      );

      return;
    }

    await facebookAppEvents.logEvent(name: eventName, parameters: properties);
  }

  @override
  Future<void> reset() async {
    super.reset();

    await facebookAppEvents.clearUserID();
  }

  static const eventsMap = {
    'home_view': 'HomeView',
    'login': 'login',
    'register_address': 'RegisterAddress',
    'begin_checkout': 'InitiateCheckout',
    'purchase': 'Purchase',
    'add_to_cart': 'AddToCart',
    'sign_up': 'Lead',
    'search': 'Search',
    'view_item': 'ViewContent',
  };
}
