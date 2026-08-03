## 0.1.0

### 💥 Breaking

* **Requires `iforevents` ^0.1.0.** The previous `^0.0.5` constraint could not
  resolve against the current core, so this package silently held users back on
  the old core that still carried a project secret. Upgrade both together.

### ✨ Improvements

* `onPageView` is accepted by the constructor and forwarded to the caller.
  Algolia Insights has no screen-view concept, so nothing is sent to Algolia.

## 0.0.3

**Multi-Platform Support** 🌐

### ✨ Improvements

* **Complete Platform Coverage**: Added support for Web, macOS, Linux, and Windows platforms
* **Enhanced Compatibility**: Updated to work with IForEvents 0.0.3 multi-platform support

---

## 0.0.1

**Initial Release** 🔍

This is the first release of IForEvents Algolia Integration, providing comprehensive Algolia search analytics integration for the IForEvents tracking platform.

### ✨ Features

* **Algolia Insights Integration**: Full support for Algolia search analytics and user behavior tracking
* **Search Analytics**: Track product views, clicks, and search interactions
* **User Token Management**: Automatic user token assignment for personalized search analytics
* **Event Mapping**: Intelligent event name mapping for common e-commerce events
* **Object ID Tracking**: Track interactions with specific search results and products
* **Timestamp Management**: Automatic timestamp assignment for accurate event sequencing

### 🔌 Integration Capabilities

* **Product Tracking**: Track product views, additions to cart, and purchases
* **Search Behavior**: Monitor search patterns and user engagement
* **Click Analytics**: Comprehensive click tracking on search results
* **View Analytics**: Track when users view products or content
* **Index-based Tracking**: Support for multiple search indices and content types

### 🎯 Supported Events

* **Product Viewed**: Track when users view products in search results
* **Product Added**: Monitor additions to cart from search
* **Checkout Events**: Track checkout initiation and coupon usage
* **Cart Operations**: Monitor cart views and modifications
* **Promotion Tracking**: Track promotion views and interactions

### 🚀 Key Components

* **AlgoliaIntegration**: Main integration class with Algolia Insights configuration
* **Event Mapping**: Smart mapping of IForEvents to Algolia event formats
* **API Configuration**: Secure API key and application ID management
* **Object ID Management**: Robust handling of search result identifiers

### 📱 Platform Support

* **Android**: Full Algolia Insights support
* **iOS**: Complete iOS Algolia search analytics
* **Web**: Algolia web search tracking

### 🔧 Usage

```dart
import 'package:iforevents_algolia/iforevents_algolia.dart';

// Add Algolia integration to IForEvents
final algoliaIntegration = AlgoliaIntegration(
  applicationID: 'YOUR_APP_ID',
  apiKey: 'YOUR_API_KEY',
);
```

### 📦 Dependencies

* Algolia Insights 1.0.3+
* IForEvents 0.0.1+
* Flutter SDK 3.8.1+

This integration enables powerful search analytics and user behavior insights through Algolia's comprehensive analytics platform, helping optimize search experiences and content discovery.
