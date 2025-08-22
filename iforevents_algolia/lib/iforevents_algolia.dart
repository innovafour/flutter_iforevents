import 'package:algolia_insights/algolia_insights.dart';

class AlgoliaIntegration extends Integration {
  const AlgoliaIntegration();

  static Insights? insights;

  @override
  Future<void> init({
    String key = '',
    Map<String, dynamic> config = const {},
  }) async {
    final applicationID = config['application_id'];

    if (applicationID == null) {
      throw Exception('Algolia application_id is required');
    }

    insights = Insights(apiKey: key, applicationID: applicationID);
  }

  @override
  Future<void> identify({
    required String userID,
    required Map<String, dynamic> data,
    required DeviceData deviceData,
    bool isTheFirstTime = false,
  }) async {
    insights?.userToken = userID;
  }

  @override
  Future<void> track({required TrackEvent event}) async {
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
