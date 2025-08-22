import 'package:algolia_insights/algolia_insights.dart';
import 'package:iforevents/models/integration.dart';

class AlgoliaIntegration extends Integration<Insights> {
  const AlgoliaIntegration({
    required this.applicationID,
    required this.apiKey,
    super.onInit,
    super.onIdentify,
    super.onTrack,
    super.onReset,
  });

  final String applicationID;
  final String apiKey;

  static Insights? insights;

  @override
  Future<void> init() async {
    super.init();

    if (applicationID.isEmpty) {
      throw Exception('Algolia application_id is required');
    }

    if (apiKey.isEmpty) {
      throw Exception('Algolia api_key is required');
    }

    insights = Insights(apiKey: apiKey, applicationID: applicationID);
  }

  @override
  Future<void> identify({required IdentifyEvent event}) async {
    super.identify(event: event);

    insights?.userToken = event.customID;
  }

  @override
  Future<void> track({required TrackEvent event}) async {
    super.track(event: event);

    const eventsDict = <String, String>{
      'view_product': 'Product Viewed',
      'checkout_coupon': 'Coupon Entered',
      'checkout_coupon_remove': 'Coupon Removed',
      'initiate_checkout': 'Checkout Started',
      'view_offer': 'Promotion Viewed',
      'open_cart': 'Cart Viewed',
      'add_to_cart_keyboard': 'Product Added',
      'add_to_cart_button': 'Product Added',
      'add_to_cart': 'Product Added',
    };

    final eventName = eventsDict[event.eventName] ?? event.eventName;
    final objectIDs = <String>[];

    final oIdsParams =
        event.properties['objectIDs'] as List<dynamic>? ?? <String>[];

    for (final oId in oIdsParams) {
      if (oId == null) continue;

      objectIDs.add(oId.toString());
    }

    final indexName = event.properties['index'];
    final timestamp = DateTime.now();

    if (indexName == null) return;

    switch (event.eventName) {
      case 'view_product':
        insights?.viewedObjects(
          eventName: eventName,
          objectIDs: objectIDs,
          indexName: indexName,
          timestamp: timestamp,
        );

        break;
      default:
        if (objectIDs.isEmpty) {
          return;
        }

        insights?.clickedObjects(
          eventName: eventName,
          objectIDs: objectIDs,
          indexName: indexName,
          timestamp: timestamp,
        );

        break;
    }
  }
}
