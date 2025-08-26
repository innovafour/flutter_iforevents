# IForEvents - Core Package

[![pub package](https://img.shields.io/pub/v/iforevents.svg)](https://pub.dev/packages/iforevents)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A comprehensive Flutter package for event tracking and analytics integration. IForEvents provides a unified interface for multiple analytics platforms while automatically collecting device information and user data.

## Features

- 📊 **Multi-platform Analytics**: Support for Firebase Analytics, Mixpanel, Algolia, CleverTap, and Meta
- 📱 **Cross-platform**: Works on Android, iOS, and Windows
- 🔍 **Automatic Device Detection**: Collects device information automatically
- 🌐 **IP Detection**: Automatic IP address detection
- 🎯 **Event Tracking**: Simple event tracking with custom properties
- 👤 **User Identification**: User identification with custom data
- 🔄 **Route Tracking**: Automatic screen/route tracking
- 🏗️ **Modular Architecture**: Add only the integrations you need
- 🔧 **Extensible**: Create custom integrations easily
## Supported Integrations

| Integration | Package | Description | Native Config Required |
|-------------|---------|-------------|------------------------|
| IForevents API | `iforevents` | Native integration with the IForevents backend | ❌ No |
| Firebase Analytics | `iforevents_firebase` | Google Firebase Analytics integration | ✅ Yes |
| Mixpanel | `iforevents_mixpanel` | Mixpanel analytics integration | ❌ No |
| Algolia Insights | `iforevents_algolia` | Algolia search analytics integration | ❌ No |
| CleverTap | `iforevents_clevertap` | CleverTap engagement platform integration | ✅ Yes |
| Meta (Facebook) | `iforevents_meta` | Facebook App Events integration | ✅ Yes |

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  iforevents: ^0.0.3
  # Add the integrations you need
  iforevents_firebase: ^0.0.3    # For Firebase Analytics
  iforevents_mixpanel: ^0.0.3    # For Mixpanel
  iforevents_algolia: ^0.0.3     # For Algolia Insights
  iforevents_clevertap: ^0.0.3   # For CleverTap
  iforevents_meta: ^0.0.3        # For Meta/Facebook
```

Then run:

```bash
flutter pub get
```

## Quick Start

### 1. Import the packages

```dart
import 'package:iforevents/iforevents.dart';
import 'package:iforevents_firebase/iforevents_firebase.dart';
import 'package:iforevents_mixpanel/iforevents_mixpanel.dart';
```

### 2. Initialize with your integrations

```dart
final iforevents = Iforevents();

await iforevents.init(integrations: [
  const FirebaseIntegration(),
  const MixpanelIntegration(token: 'YOUR_MIXPANEL_TOKEN'),
]);
```

### 3. Identify users

```dart
await iforevents.identify(
  event: IdentifyEvent(
    customID: 'user123',
    properties: {
      'email': 'user@example.com',
      'name': 'John Doe',
      'plan': 'premium',
    },
  ),
);
```

### 4. Track events

```dart
iforevents.track(
  event: TrackEvent(
    eventName: 'button_clicked',
    properties: {
      'button_name': 'signup',
      'screen': 'home',
    },
  ),
);
```

## Usage

### Initialization

Initialize IforEvents with the analytics integrations you want to use:

```dart
import 'package:iforevents/iforevents.dart';
import 'package:iforevents_firebase/iforevents_firebase.dart';
import 'package:iforevents_mixpanel/iforevents_mixpanel.dart';

final iforevents = Iforevents();

await iforevents.init(integrations: [
  const FirebaseIntegration(),
  const MixpanelIntegration(token: 'your_mixpanel_project_token'),
]);
```

### User Identification

Identify users with custom data. Device information is automatically included:

```dart
await iforevents.identify(
  event: IdentifyEvent(
    customID: 'user_123',
    properties: {
      'email': 'john.doe@example.com',
      'name': 'John Doe',
      'age': 30,
      'subscription': 'premium',
      'signup_date': '2023-01-15',
    },
  ),
);
```

The following device data is automatically collected and included:
- IP address
- Device brand and model
- OS version
- App version
- Platform (Android/iOS/Windows)
- Unique device identifier

### Event Tracking

Track custom events with properties:

```dart
// Simple event
iforevents.track(
  event: TrackEvent(eventName: 'app_opened'),
);

// Event with properties
iforevents.track(
  event: TrackEvent(
    eventName: 'purchase_completed',
    properties: {
      'product_id': 'prod_123',
      'price': 29.99,
      'currency': 'USD',
      'category': 'premium_features',
    },
  ),
);

// Different event types
iforevents.track(
  event: TrackEvent(
    eventName: 'page_view',
    eventType: EventType.screen,
    properties: {
      'page_name': 'product_details',
      'product_id': 'prod_123',
    },
  ),
);
```

### Screen/Route Tracking

Automatically track screen navigation:

```dart
await iforevents.screen(
  toRoute: RouteSettings(name: '/product_details'),
  previousRoute: RouteSettings(name: '/home'),
);
```

### Navigation Observer

Use the built-in navigator observer for automatic route tracking:

```dart
import 'package:iforevents/utils/navigator_observer.dart';

MaterialApp(
  navigatorObservers: [
    IforeventsNavigatorObserver(iforevents: iforevents),
  ],
  // ... rest of your app
)
```

### Reset User Data

Reset user identification and clear stored data:

```dart
await iforevents.reset();
```

## Creating Custom Integrations

You can create your own analytics integrations by extending the `Integration` class. This allows you to add support for any analytics platform not currently supported.

### Basic Custom Integration

```dart
import 'package:iforevents/iforevents.dart';

class CustomAnalyticsIntegration extends Integration {
  final String apiKey;
  final String endpoint;
  
  const CustomAnalyticsIntegration({
    required this.apiKey,
    required this.endpoint,
  });

  @override
  Future<void> init() async {
    // IMPORTANT: Always call super.init() first
    await super.init();
    
    // Initialize your analytics SDK here
    print('Initializing custom analytics with API key: $apiKey');
    
    // Example: Initialize SDK
    // await CustomAnalyticsSDK.initialize(apiKey);
  }

  @override
  Future<void> identify({required IdentifyEvent event}) async {
    // IMPORTANT: Always call super.identify() first
    await super.identify(event: event);
    
    // Handle user identification
    print('Identifying user: ${event.customID}');
    
    // Example: Set user properties
    // await CustomAnalyticsSDK.setUserId(event.customID);
    // await CustomAnalyticsSDK.setUserProperties(event.properties);
  }

  @override
  Future<void> track({required TrackEvent event}) async {
    // IMPORTANT: Always call super.track() first
    await super.track(event: event);
    
    // Handle event tracking
    print('Tracking event: ${event.eventName}');
    
    // Example: Track event
    // await CustomAnalyticsSDK.track(
    //   event.eventName,
    //   properties: event.properties,
    // );
  }

  @override
  Future<void> reset() async {
    // IMPORTANT: Always call super.reset() first
    await super.reset();
    
    // Handle user data reset
    print('Resetting custom analytics data');
    
    // Example: Reset user data
    // await CustomAnalyticsSDK.reset();
  }

  @override
  Future<void> pageView({required PageViewEvent event}) async {
    // IMPORTANT: Always call super.pageView() first
    await super.pageView(event: event);
    
    // Handle page view tracking
    if (event.toRoute?.name != null) {
      print('Page view: ${event.toRoute!.name}');
      print('Navigation type: ${event.navigationType}');
      
      // Example: Track page view
      // await CustomAnalyticsSDK.trackPageView(event.toRoute!.name!);
    }
  }
}
```

> **⚠️ CRITICAL: @mustCallSuper Requirement**
> 
> All Integration methods are marked with `@mustCallSuper`, which means you **MUST** call the parent method first in your override. This ensures that any callback functions (onInit, onIdentify, onTrack, onReset, onPageView) are executed properly.
>
> **Failure to call `super.method()` will result in missing functionality and potential bugs.**

### Advanced Custom Integration with HTTP API

Here's an example of a custom integration that sends data to a REST API:

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:iforevents/iforevents.dart';

class HTTPAnalyticsIntegration extends Integration {
  final String baseUrl;
  final String apiKey;
  final Map<String, String> headers;
  final bool enableLogging;
  
  const HTTPAnalyticsIntegration({
    required this.baseUrl,
    required this.apiKey,
    this.headers = const {},
    this.enableLogging = false,
  });

  String? _userId;

  @override
  Future<void> init() async {
    if (enableLogging) {
      print('HTTP Analytics Integration initialized');
      print('Base URL: $baseUrl');
    }
  }

  @override
  Future<void> identify({required IdentifyEvent event}) async {
    _userId = event.customID;
    
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/identify'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
          ...headers,
        },
        body: jsonEncode({
          'user_id': event.customID,
          'properties': event.properties,
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );
      
      if (enableLogging) {
        print('Identify response: ${response.statusCode}');
      }
    } catch (e) {
      if (enableLogging) {
        print('Error identifying user: $e');
      }
    }
  }

  @override
  Future<void> track({required TrackEvent event}) async {
    try {
      final payload = {
        'event': event.eventName,
        'properties': event.properties,
        'timestamp': DateTime.now().toIso8601String(),
      };
      
      if (_userId != null) {
        payload['user_id'] = _userId!;
      }
      
      final response = await http.post(
        Uri.parse('$baseUrl/track'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
          ...headers,
        },
        body: jsonEncode(payload),
      );
      
      if (enableLogging) {
        print('Track event response: ${response.statusCode}');
      }
    } catch (e) {
      if (enableLogging) {
        print('Error tracking event: $e');
      }
    }
  }

  @override
  Future<void> reset() async {
    _userId = null;
    
    if (enableLogging) {
      print('HTTP Analytics data reset');
    }
  }

  @override
  Future<void> pageView({
    required RouteSettings? toRoute,
    required RouteSettings? previousRoute,
  }) async {
    if (toRoute?.name != null) {
      await track(
        event: TrackEvent(
          eventName: 'page_view',
          eventType: EventType.screen,
          properties: {
            'page_name': toRoute!.name!,
            'previous_page': previousRoute?.name,
          },
        ),
      );
    }
  }
}
```

### Using Custom Integrations

Once you've created your custom integration, use it just like any other integration:

```dart
await iforevents.init(integrations: [
  // Built-in integrations
  const FirebaseIntegration(),
  const MixpanelIntegration(token: 'your_token'),
  
  // Your custom integrations
  const CustomAnalyticsIntegration(
    apiKey: 'your_api_key',
    endpoint: 'https://api.your-analytics.com',
  ),
  const HTTPAnalyticsIntegration(
    baseUrl: 'https://api.your-service.com',
    apiKey: 'your_api_key',
    enableLogging: true,
  ),
]);
```

### Integration Best Practices

1. **Error Handling**: Always wrap SDK calls in try-catch blocks
2. **Async Operations**: Use async/await for all network and SDK operations
3. **Validation**: Validate input data before sending to analytics services
4. **Logging**: Provide optional logging for debugging
5. **Configuration**: Make integrations configurable with constructor parameters
6. **Null Safety**: Handle null values appropriately
7. **Performance**: Avoid blocking the UI thread with heavy operations

### Testing Custom Integrations

Create unit tests for your custom integrations:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:iforevents/iforevents.dart';

void main() {
  group('CustomAnalyticsIntegration', () {
    late CustomAnalyticsIntegration integration;
    
    setUp(() {
      integration = const CustomAnalyticsIntegration(
        apiKey: 'test_key',
        endpoint: 'https://test.com',
      );
    });
    
    test('should initialize without errors', () async {
      await expectLater(integration.init(), completes);
    });
    
    test('should identify users', () async {
      final event = IdentifyEvent(
        customID: 'test_user',
        properties: {'email': 'test@example.com'},
      );
      
      await expectLater(
        integration.identify(event: event),
        completes,
      );
    });
    
    test('should track events', () async {
      final event = TrackEvent(
        eventName: 'test_event',
        properties: {'key': 'value'},
      );
      
      await expectLater(
        integration.track(event: event),
        completes,
      );
    });
  });
}
```

## Device Information

IforEvents automatically collects comprehensive device information:

### Android
- Device ID (Android ID)
- Brand and model
- OS version (SDK version)
- Physical device detection
- App version and build info

### iOS
- Identifier for vendor
- Device name and model
- iOS version
- Physical device detection
- App version and build info

### Windows
- Device ID
- Computer name
- Windows version and build
- App version info

## API Reference

### Iforevents Class

#### Methods

- `init({List<Integration> integrations})` - Initialize with analytics integrations
- `identify({required IdentifyEvent event})` - Identify user with custom data
- `track({required TrackEvent event})` - Track events
- `screen({required RouteSettings? toRoute, required RouteSettings? previousRoute})` - Track screen navigation
- `reset()` - Reset user data and clear stored information

#### Static Properties

- `ip` - Get current IP address
- `deviceData` - Get comprehensive device information

### EventType Enum

- `EventType.track` - Standard tracking event
- `EventType.screen` - Screen view event
- `EventType.alias` - User alias event

### Integration Class

Base class for creating custom integrations. **All methods are marked with `@mustCallSuper`**, which means you **must** call the parent method first in your override:

```dart
abstract class Integration<T> {
  const Integration({
    this.onInit,
    this.onIdentify, 
    this.onTrack,
    this.onReset,
    this.onPageView,
  });

  // Override these methods in your custom integration
  // IMPORTANT: Always call super.method() first due to @mustCallSuper
  @mustCallSuper
  Future<void> init() async {}
  
  @mustCallSuper
  Future<void> identify({required IdentifyEvent event}) async {}
  
  @mustCallSuper
  Future<void> track({required TrackEvent event}) async {}
  
  @mustCallSuper
  Future<void> reset() async {}
  
  @mustCallSuper
  Future<void> pageView({required PageViewEvent event}) async {}
}
```

> **⚠️ CRITICAL: All Integration methods are marked with `@mustCallSuper`, which means you **MUST** call the parent method first in your override. Failure to do so will result in missing functionality and potential bugs.

## Integration Guides

For detailed setup instructions for each integration, see their respective README files:

- [Firebase Integration](https://pub.dev/packages/iforevents_firebase) - Requires native configuration
- [Mixpanel Integration](https://pub.dev/packages/iforevents_mixpanel) - No native configuration required
- [Algolia Integration](https://pub.dev/packages/iforevents_algolia) - No native configuration required
- [CleverTap Integration](https://pub.dev/packages/iforevents_clevertap) - Requires native configuration
- [Meta Integration](https://pub.dev/packages/iforevents_meta) - Requires native configuration

## Example

Check out the [example](./example) directory for a complete implementation showing:

- Multi-integration setup
- User identification flow
- Event tracking examples
- Navigation tracking
- Error handling
- Custom integration examples

## Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

### Development Setup

1. Clone the repository:
```bash
git clone https://github.com/innovafour/flutter_iforevents.git
cd flutter_iforevents
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run tests:
```bash
flutter test
```

## Support

- 📧 Email: [support@innovafour.com](mailto:support@innovafour.com)
- 🐛 Issues: [GitHub Issues](https://github.com/innovafour/flutter_iforevents/issues)
- 📖 Documentation: [API Documentation](https://pub.dev/documentation/iforevents/latest/)

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

Made with ❤️ by [Innovafour](https://innovafour.com)
