import 'package:clevertap_plugin/clevertap_plugin.dart';
import 'package:iforevents/models/integration.dart';

class ClevertapIntegration extends Integration {
  const ClevertapIntegration({
    super.onInit,
    super.onIdentify,
    super.onTrack,
    super.onReset,
    super.onPageView,
  });

  static bool isTheFirstTime = true;

  @override
  Future<void> identify({required IdentifyEvent event}) async {
    super.identify(event: event);

    final clevertapMap = <String, dynamic>{};

    for (var key in event.properties.keys) {
      if (['email', 'name', 'phone'].contains(key)) {
        clevertapMap[capitalize(key)] = event.properties[key];
      } else {
        clevertapMap[key] = event.properties[key];
      }
    }

    if (isTheFirstTime) {
      await CleverTapPlugin.onUserLogin(clevertapMap);
    } else {
      await CleverTapPlugin.profileSet(clevertapMap);
    }

    isTheFirstTime = false;
  }

  @override
  Future<void> track({required TrackEvent event}) async {
    super.track(event: event);

    switch (event.eventName) {
      case 'Order Completed':
        final raw = event.properties['products'];

        if (raw is! List) {
          // No line items to charge against; record it as an ordinary event
          // rather than throwing on the cast.
          await CleverTapPlugin.recordEvent(event.eventName, event.properties);
          break;
        }

        final products = raw
            .whereType<Map>()
            .map((p) => Map<String, dynamic>.from(p))
            .toList();

        // Copy before stripping: event.properties is the same map instance
        // every other integration receives, so mutating it here would delete
        // `products` for whichever integrations run after this one.
        final properties = Map<String, dynamic>.from(event.properties)
          ..remove('products');

        await CleverTapPlugin.recordChargedEvent(properties, products);
        break;
      default:
        await CleverTapPlugin.recordEvent(event.eventName, event.properties);
        break;
    }
  }

  @override
  Future<void> pageView({required PageViewEvent event}) async {
    super.pageView(event: event);

    await CleverTapPlugin.recordEvent('page_view', event.toJson());
  }

  @override
  Future<void> reset() async {
    super.reset();

    await CleverTapPlugin.clearInAppResources(false);
  }

  String capitalize(String text) {
    if (text.isEmpty) return text;

    return text[0].toUpperCase() + text.substring(1);
  }
}
