# IForEvents Algolia Integration

[![pub package](https://img.shields.io/pub/v/iforevents_algolia.svg)](https://pub.dev/packages/iforevents_algolia)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Algolia Insights integration for IForEvents. This package provides seamless integration with Algolia's search analytics platform, enabling you to track search events, user interactions, and optimize your search experience through detailed analytics.

## Features

- 🔍 **Algolia Insights Integration**: Full support for Algolia search analytics
- 📊 **Search Event Tracking**: Track search queries, clicks, and conversions
- 👤 **User Journey Tracking**: Understand how users interact with search results
- 📈 **Search Performance Analytics**: Measure search effectiveness and user engagement
- 🎯 **Personalization Support**: Track user preferences for personalized search
- 📱 **Cross-platform**: Works on Android, iOS, and Web
- 🚀 **Real-time Analytics**: View search analytics in real-time on Algolia dashboard

## Installation

### 1. Add Dependencies

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  iforevents: ^0.0.3
  iforevents_algolia: ^0.0.3
```

Then run:

```bash
flutter pub get
```

### 2. Get Algolia Credentials

1. **Create an Algolia account** at [algolia.com](https://www.algolia.com)
2. **Create a new application** or use an existing one
3. **Get your credentials** from API Keys section:
   - Application ID
   - Search-Only API Key (recommended) or Admin API Key

### 3. No Native Configuration Required

Algolia integration works out of the box without any native Android or iOS configuration. The Algolia Insights SDK handles all the necessary setup internally.

## Usage

### Basic Setup

```dart
import 'package:iforevents/iforevents.dart';
import 'package:iforevents_algolia/iforevents_algolia.dart';

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final Iforevents iforevents = const Iforevents();

  @override
  void initState() {
    super.initState();
    _initializeAnalytics();
  }

  Future<void> _initializeAnalytics() async {
    await iforevents.init(integrations: [
      const AlgoliaIntegration(
        applicationID: 'YOUR_ALGOLIA_APPLICATION_ID',
        apiKey: 'YOUR_ALGOLIA_API_KEY',
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Algolia Analytics Demo',
      home: SearchScreen(iforevents: iforevents),
    );
  }
}
```

### User Identification

```dart
// Identify a user for personalized search analytics
await iforevents.identify(
  event: IdentifyEvent(
    customID: 'user_123',
    properties: {
      'email': 'user@example.com',
      'name': 'John Doe',
      'user_segment': 'premium',
      'location': 'New York',
      'preferences': ['electronics', 'books'],
    },
  ),
);
```

### Search Event Tracking

```dart
// Track product views (when users view search results)
iforevents.track(
  event: TrackEvent(
    eventName: 'view_product',
    properties: {
      'objectIDs': ['product_123', 'product_456'], // Required: Array of object IDs viewed
      'index': 'products', // Required: Your Algolia index name
      'queryID': 'query_abc123', // Optional: Query ID from search response
      'position': 1, // Optional: Position in search results
    },
  ),
);

// Track product clicks (when users click on search results)
iforevents.track(
  event: TrackEvent(
    eventName: 'add_to_cart',
    properties: {
      'objectIDs': ['product_123'], // Required: Array of clicked object IDs
      'index': 'products', // Required: Your Algolia index name
      'queryID': 'query_abc123', // Optional: Query ID from search response
      'position': 1, // Optional: Position of clicked item
    },
  ),
);

// Track any other interaction events
iforevents.track(
  event: TrackEvent(
    eventName: 'add_to_wishlist',
    properties: {
      'objectIDs': ['product_789'],
      'index': 'products',
      'queryID': 'query_def456',
    },
  ),
);
```

### Search Analytics Events

Algolia Insights supports various types of search-related events:

```dart
// Search performed
iforevents.track(
  event: TrackEvent(
    eventName: 'search_performed',
    properties: {
      'query': 'flutter development',
      'index': 'articles',
      'filters': ['category:programming'],
      'results_count': 42,
    },
  ),
);

// Search result clicked
iforevents.track(
  event: TrackEvent(
    eventName: 'search_result_clicked',
    properties: {
      'objectIDs': ['article_123'],
      'index': 'articles',
      'queryID': 'query_search_123',
      'position': 3,
      'query': 'flutter development',
    },
  ),
);

// Filter applied
iforevents.track(
  event: TrackEvent(
    eventName: 'filter_applied',
    properties: {
      'filter_name': 'category',
      'filter_value': 'programming',
      'index': 'articles',
      'results_count': 15,
    },
  ),
);
```

### E-commerce Events

Track e-commerce interactions with search results:

```dart
// Product added to cart from search
iforevents.track(
  event: TrackEvent(
    eventName: 'add_to_cart',
    properties: {
      'objectIDs': ['product_123'],
      'index': 'products',
      'queryID': 'query_ecommerce_456',
      'product_name': 'Flutter Development Book',
      'price': 29.99,
      'currency': 'USD',
    },
  ),
);

// Purchase conversion
iforevents.track(
  event: TrackEvent(
    eventName: 'purchase_completed',
    properties: {
      'objectIDs': ['product_123', 'product_456'],
      'index': 'products',
      'total_amount': 59.98,
      'currency': 'USD',
      'payment_method': 'credit_card',
    },
  ),
);
```

## Advanced Usage

### Custom Event Mapping

The Algolia integration includes built-in event mapping for common e-commerce events:

```dart
// These events are automatically mapped to Algolia Insights events:
// 'view_product' → 'Product Viewed'
// 'add_to_cart' → 'Product Added'
// 'checkout_coupon' → 'Coupon Entered'
// 'initiate_checkout' → 'Checkout Started'
// etc.

iforevents.track(
  event: TrackEvent(
    eventName: 'view_product', // Automatically mapped
    properties: {
      'objectIDs': ['product_123'],
      'index': 'products',
    },
  ),
);
```

### Creating Custom Algolia Integration

You can extend the Algolia integration for custom behavior:

```dart
import 'package:iforevents/iforevents.dart';
import 'package:algolia_insights/algolia_insights.dart';

class CustomAlgoliaIntegration extends Integration {
  final String applicationID;
  final String apiKey;
  final String? region;
  final bool enableLogging;
  
  const CustomAlgoliaIntegration({
    required this.applicationID,
    required this.apiKey,
    this.region,
    this.enableLogging = false,
  });

  static Insights? insights;

  @override
  Future<void> init() async {
    // IMPORTANT: Always call super.init() first due to @mustCallSuper
    await super.init();
    
    if (applicationID.isEmpty) {
      throw Exception('Algolia Application ID is required');
    }

    if (apiKey.isEmpty) {
      throw Exception('Algolia API Key is required');
    }

    insights = Insights(
      apiKey: apiKey,
      applicationID: applicationID,
      region: region,
    );

    if (enableLogging) {
      print('Custom Algolia Integration initialized');
      print('Application ID: $applicationID');
    }
  }

  @override
  Future<void> identify({required IdentifyEvent event}) async {
    // IMPORTANT: Always call super.identify() first due to @mustCallSuper
    await super.identify(event: event);
    
    insights?.userToken = event.customID;
    
    if (enableLogging) {
      print('Algolia user identified: ${event.customID}');
    }
  }

  @override
  Future<void> track({required TrackEvent event}) async {
    // IMPORTANT: Always call super.track() first due to @mustCallSuper
    await super.track(event: event);
    // Custom event filtering and validation
    final objectIDs = _extractObjectIDs(event.properties);
    final indexName = event.properties['index'];
    
    if (objectIDs.isEmpty || indexName == null) {
      if (enableLogging) {
        print('Skipping Algolia event: missing objectIDs or index');
      }
      return;
    }

    final timestamp = DateTime.now();
    final eventName = _mapEventName(event.eventName);

    // Custom event routing logic
    switch (event.eventName) {
      case 'view_product':
      case 'product_viewed':
        await insights?.viewedObjects(
          eventName: eventName,
          objectIDs: objectIDs,
          indexName: indexName,
          timestamp: timestamp,
        );
        break;
        
      case 'search_performed':
        // Custom search tracking
        final query = event.properties['query']?.toString() ?? '';
        await insights?.clickedObjects(
          eventName: 'Search Performed',
          objectIDs: objectIDs,
          indexName: indexName,
          timestamp: timestamp,
        );
        break;
        
      default:
        await insights?.clickedObjects(
          eventName: eventName,
          objectIDs: objectIDs,
          indexName: indexName,
          timestamp: timestamp,
        );
    }

    if (enableLogging) {
      print('Algolia event tracked: ${event.eventName} -> $eventName');
    }
  }

  List<String> _extractObjectIDs(Map<String, dynamic> properties) {
    final objectIDs = <String>[];
    final oIdsParams = properties['objectIDs'] as List<dynamic>? ?? <String>[];

    for (final oId in oIdsParams) {
      if (oId != null && oId.toString().isNotEmpty) {
        objectIDs.add(oId.toString());
      }
    }

    return objectIDs;
  }

  String _mapEventName(String originalEventName) {
    const eventMapping = <String, String>{
      'view_product': 'Product Viewed',
      'add_to_cart': 'Product Added to Cart',
      'remove_from_cart': 'Product Removed from Cart',
      'purchase_completed': 'Order Completed',
      'search_performed': 'Search Performed',
      'filter_applied': 'Filter Applied',
    };

    return eventMapping[originalEventName] ?? originalEventName;
  }
}
```

Then use your custom integration:

```dart
await iforevents.init(integrations: [
  const CustomAlgoliaIntegration(
    applicationID: 'YOUR_ALGOLIA_APPLICATION_ID',
    apiKey: 'YOUR_ALGOLIA_API_KEY',
    region: 'us', // Optional: specify region
    enableLogging: true, // Enable for debugging
  ),
]);
```

### Search Performance Optimization

Use Algolia analytics to optimize search performance:

```dart
// Track search performance metrics
iforevents.track(
  event: TrackEvent(
    eventName: 'search_no_results',
    properties: {
      'query': 'non-existent product',
      'index': 'products',
      'filters_applied': ['category:electronics'],
      'search_time_ms': 150,
    },
  ),
);

// Track successful searches
iforevents.track(
  event: TrackEvent(
    eventName: 'search_success',
    properties: {
      'query': 'flutter book',
      'index': 'products',
      'results_count': 25,
      'first_result_clicked': true,
      'click_position': 1,
      'search_time_ms': 85,
    },
  ),
);
```

## Best Practices

### 1. Required Properties
Always include these properties for proper Algolia analytics:
- `objectIDs`: Array of object IDs being tracked
- `index`: The Algolia index name
- `queryID`: Query ID from Algolia search response (when available)

### 2. Event Naming
- Use clear, consistent event names
- Follow e-commerce conventions when applicable
- Map custom events to standard Algolia event types

### 3. User Journey Tracking
- Track the complete search journey: search → view → interact → convert
- Include context properties: query, position, filters
- Use consistent user identification throughout the user

### 4. Performance Monitoring
- Track search response times
- Monitor no-results queries
- Analyze click-through rates and conversion

## Algolia Dashboard Features

### Search Analytics
1. Go to Algolia Dashboard → Analytics
2. View search metrics: queries, clicks, conversions
3. Analyze search performance and user behavior

### A/B Testing
1. Set up search experiments
2. Track different search configurations
3. Measure impact on user engagement

### Query Rules
1. Create rules based on analytics data
2. Optimize search results for better conversion
3. Personalize search based on user behavior

## Troubleshooting

### Common Issues

1. **Events not appearing in Algolia Dashboard**
   - Check your Application ID and API Key
   - Verify `objectIDs` and `index` are provided
   - Events may take a few minutes to appear

2. **Missing object IDs**
   - Ensure `objectIDs` is an array of strings
   - Check that object IDs exist in your Algolia index

3. **Invalid index name**
   - Verify the index name matches your Algolia configuration
   - Check that the index exists and has data

### Debug Mode

Enable debug logging in your custom integration to troubleshoot:

```dart
const CustomAlgoliaIntegration(
  applicationID: 'YOUR_APP_ID',
  apiKey: 'YOUR_API_KEY',
  enableLogging: true, // Enable for debugging
);
```

## Package Dependencies

This package uses the following dependencies:

- [`algolia_insights`](https://pub.dev/packages/algolia_insights) ^1.0.3 - Official Algolia Insights SDK for Flutter
- [`iforevents`](https://pub.dev/packages/iforevents) - Core IforEvents package

## Algolia Documentation

For more information about Algolia:

- [Algolia Documentation](https://www.algolia.com/doc/)
- [Algolia Insights API](https://www.algolia.com/doc/rest-api/insights/)
- [Search Analytics Guide](https://www.algolia.com/doc/guides/search-analytics/overview/)

## Support

- 📧 Email: [support@innovafour.com](mailto:support@innovafour.com)
- 🐛 Issues: [GitHub Issues](https://github.com/innovafour/flutter_iforevents/issues)
- 📖 Documentation: [API Documentation](https://pub.dev/documentation/iforevents_algolia/latest/)

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

Made with ❤️ by [Innovafour](https://innovafour.com)
