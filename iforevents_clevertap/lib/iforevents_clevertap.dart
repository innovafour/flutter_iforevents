import 'package:clevertap_plugin/clevertap_plugin.dart';
import 'package:iforevents/models/integration.dart';

class ClevertapIntegration extends Integration {
  const ClevertapIntegration({
    super.onInit,
    super.onIdentify,
    super.onTrack,
    super.onReset,
  });

  static bool isTheFirstTime = true;

  @override
  Future<void> init({
    String key = '',
    Map<String, dynamic> config = const {},
  }) async {}

  @override
  Future<void> identify({required IdentifyEvent event}) async {
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
    switch (event.eventName) {
      case 'Order Completed':
        final properties = event.properties;
        final products = List<Map<String, dynamic>>.from(
          properties['products'],
        );

        properties.removeWhere((key, value) {
          return ['products'].contains(key);
        });

        await CleverTapPlugin.recordChargedEvent(properties, products);
        break;
      default:
        await CleverTapPlugin.recordEvent(event.eventName, event.properties);
        break;
    }
  }

  @override
  Future<void> reset() async {
    await CleverTapPlugin.clearInAppResources(false);
  }

  String capitalize(String text) {
    if (text.isEmpty) return text;

    return text[0].toUpperCase() + text.substring(1);
  }
}
