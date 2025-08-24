# IForEvents

[![pub package](https://img.shields.io/pub/v/iforevents.svg)](https://pub.dev/packages/iforevents)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A comprehensive Flutter package for event tracking and analytics integration. IForEvents provides a unified interface for multiple analytics platforms while automatically collecting device information and user data.

## Table of Contents

- [IForEvents](#iforevents)
  - [Table of Contents](#table-of-contents)
  - [Features](#features)
  - [Supported Integrations](#supported-integrations)
  - [Installation](#installation)
  - [Quick Start](#quick-start)
    - [1. Import the package](#1-import-the-package)
    - [2. Initialize with your integrations](#2-initialize-with-your-integrations)
    - [3. Identify users](#3-identify-users)
    - [4. Track events](#4-track-events)
  - [Core Usage](#core-usage)
    - [Initialization](#initialization)
    - [User Identification](#user-identification)
    - [Event Tracking](#event-tracking)
    - [Screen/Route Tracking](#screenroute-tracking)
    - [Automatic Navigation Tracking](#automatic-navigation-tracking)
    - [Reset User Data](#reset-user-data)
  - [Device Information](#device-information)
    - [Android](#android)
    - [iOS](#ios)
    - [Windows](#windows)
  - [Official Integrations](#official-integrations)
    - [IForevents API](#iforevents-api)
    - [Firebase Analytics](#firebase-analytics)
    - [Mixpanel](#mixpanel)
    - [Algolia](#algolia)
    - [Meta (Facebook Pixel)](#meta-facebook-pixel)
    - [CleverTap](#clevertap)
  - [Creating Custom Integrations](#creating-custom-integrations)
    - [Basic Structure](#basic-structure)
    - [Example: Console Log Integration](#example-console-log-integration)
    - [Best Practices](#best-practices)
  - [API Reference](#api-reference)
    - [Iforevents Class](#iforevents-class)
    - [EventType Enum](#eventtype-enum)
  - [Example Application](#example-application)
  - [Contributing](#contributing)
    - [Development Setup](#development-setup)
  - [License](#license)
  - [Support](#support)
  - [Changelog](#changelog)

## Features

- 📊 **Multi-platform Analytics**: Support for Iforevents API, Firebase, Mixpanel, Algolia, Meta, and CleverTap.
- 📱 **Cross-platform**: Works on Android, iOS, and Windows.
- 🔍 **Automatic Device Detection**: Collects device information automatically.
- 🌐 **IP Detection**: Automatic IP address detection.
- 🎯 **Event Tracking**: Simple event tracking with custom properties.
- 👤 **User Identification**: User identification with custom data.
- 🔄 **Route Tracking**: Automatic screen/route tracking.
- 🏗️ **Modular Architecture**: Add only the integrations you need.
- 🔌 **Custom Integrations**: Easily extend the library with your own integrations.
- 📦 **Offline Caching & Batching**: Robust event queueing for the Iforevents API integration.

## Supported Integrations

| Integration | Package | Description |
|---|---|---|
| Iforevents API | `iforevents` | Native integration with the Iforevents backend. |
| Firebase Analytics | `iforevents_firebase` | Google Firebase Analytics integration. |
| Mixpanel | `iforevents_mixpanel` | Mixpanel analytics integration. |
| Algolia | `iforevents_algolia` | Algolia search analytics integration. |
| Meta (Facebook) | `iforevents_meta` | Facebook Pixel integration for web. |
| CleverTap | `iforevents_clevertap`| CleverTap analytics and engagement integration. |

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  iforevents: ^0.0.2
  # Add the integrations you need
  iforevents_firebase: ^0.0.1
  iforevents_mixpanel: ^0.0.1
  iforevents_algolia: ^0.0.1
  iforevents_meta: ^0.0.1
  iforevents_clevertap: ^0.0.1
```

Then run:

```bash
flutter pub get
```

## Quick Start

### 1. Import the package

```dart
import 'package:iforevents/iforevents.dart';
// Import the integrations you will use
import 'package:iforevents_firebase/iforevents_firebase.dart';
import 'package:iforevents_mixpanel/iforevents_mixpanel.dart';
```

### 2. Initialize with your integrations

```dart
final iforevents = Iforevents();

await iforevents.init(integrations: [
  const FirebaseIntegration(),
  const MixpanelIntegration(key: 'YOUR_MIXPANEL_KEY'),
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

## Core Usage

### Initialization

Initialize Iforevents with the analytics integrations you want to use. This should be done once when your app starts.

```dart
import 'package:iforevents/iforevents.dart';
import 'package:iforevents_firebase/iforevents_firebase.dart';
import 'package:iforevents_mixpanel/iforevents_mixpanel.dart';

final iforevents = Iforevents();

await iforevents.init(integrations: [
  const FirebaseIntegration(),
  const MixpanelIntegration(key: 'your_mixpanel_project_token'),
]);
```

### User Identification

The `identify` method links events to a specific user. Device information is automatically included.

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

### Event Tracking

Track custom events with properties using the `track` method.

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
```

### Screen/Route Tracking

Manually track screen navigation events.

```dart
await iforevents.screen(
  toRoute: RouteSettings(name: '/product_details'),
  previousRoute: RouteSettings(name: '/home'),
);
```

### Automatic Navigation Tracking

For automatic screen tracking, use the built-in `IforeventsNavigatorObserver`.

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

Reset user identification and clear all stored data for the current user. This is useful when a user logs out.

```dart
await iforevents.reset();
```

## Device Information

Iforevents automatically collects comprehensive device information on every event.

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

## Official Integrations

### Iforevents API

This is the native integration with the Iforevents backend, included in the core `iforevents` package. It's powerful, featuring an offline queue, event batching, and automatic retries.

**Features:**
- ✅ **User identification** and session management
- ✅ **Event tracking** (individual and batch)
- ✅ **Completely customizable configuration**
- ✅ **Offline event queue** with automatic retries
- ✅ **Detailed logging** for debugging
- ✅ **High performance** with HTTP/2 using Dio

**Usage:**

1.  **Configure and Initialize**:

    ```dart
    import 'package:iforevents/iforevents.dart';
    import 'package:iforevents/integration/iforevents.dart';

    // Use a predefined configuration
    final config = IForeventsConfigExamples.production(
      projectKey: const String.fromEnvironment('IFOREVENTS_PROJECT_KEY'),
      projectSecret: const String.fromEnvironment('IFOREVENTS_PROJECT_SECRET'),
      baseUrl: 'https://api.iforevents.com',
    );

    final apiIntegration = IForeventsAPIIntegration(config: config);

    await iforevents.init(integrations: [apiIntegration]);
    ```

2.  **Advanced Control**:
    The integration offers advanced controls like manual queue flushing and status checks.

    ```dart
    // Check status
    final status = apiIntegration.getQueueStatus();
    print('Queued events: ${status.queuedEvents}');

    // Manually flush queue
    await apiIntegration.flush();
    ```

For detailed configuration options (batching, timeouts, retries), see the `IForeventsAPIConfig` class.

### Firebase Analytics

1.  Add Firebase to your Flutter project following the [official guide](https://firebase.google.com/docs/flutter/setup).
2.  Add the `iforevents_firebase` package to your `pubspec.yaml`.
3.  Initialize the integration:

    ```dart
    import 'package:iforevents_firebase/iforevents_firebase.dart';

    await iforevents.init(integrations: [
      const FirebaseIntegration(),
    ]);
    ```

### Mixpanel

1.  Get your Mixpanel project token from [mixpanel.com](https://mixpanel.com).
2.  Add the `iforevents_mixpanel` package to your `pubspec.yaml`.
3.  Initialize with your token:

    ```dart
    import 'package:iforevents_mixpanel/iforevents_mixpanel.dart';

    await iforevents.init(integrations: [
      const MixpanelIntegration(key: 'YOUR_MIXPANEL_PROJECT_TOKEN'),
    ]);
    ```

### Algolia

1.  Get your Algolia credentials.
2.  Add the `iforevents_algolia` package to your `pubspec.yaml`.
3.  Initialize with your credentials:

    ```dart
    import 'package:iforevents_algolia/iforevents_algolia.dart';

    await iforevents.init(integrations: [
      const AlgoliaIntegration(/* your algolia config */),
    ]);
    ```

### Meta (Facebook Pixel)

1.  Get your Pixel ID from the Facebook Events Manager.
2.  Add the `iforevents_meta` package to your `pubspec.yaml`.
3.  Initialize with your Pixel ID:
    ```dart
    import 'package:iforevents_meta/iforevents_meta.dart';

    await iforevents.init(integrations: [
      const MetaIntegration(pixelId: 'YOUR_PIXEL_ID'),
    ]);
    ```

### CleverTap

1.  Get your CleverTap Account ID and Token.
2.  Add the `iforevents_clevertap` package to your `pubspec.yaml`.
3.  Initialize the integration:
    ```dart
    import 'package:iforevents_clevertap/iforevents_clevertap.dart';

    await iforevents.init(integrations: [
      const CleverTapIntegration(),
    ]);
    ```
    *Note: CleverTap's native SDKs are typically configured via native files (`Info.plist` on iOS, `AndroidManifest.xml` on Android).*

## Creating Custom Integrations

You can extend Iforevents with any analytics platform by creating a custom integration.

### Basic Structure

All custom integrations must extend the `Integration` class and implement its methods.

> **⚠️ CRITICAL: @mustCallSuper Requirement**
> You **MUST** call the parent method first in your override (e.g., `await super.track(event: event);`). This ensures that internal callbacks are executed correctly.

```dart
import 'package:iforevents/iforevents.dart';

class MyCustomIntegration extends Integration {
  @override
  Future<void> init() async {
    await super.init();
    // Initialize your analytics service
  }

  @override
  Future<void> identify({required IdentifyEvent event}) async {
    await super.identify(event: event);
    // Handle user identification
  }

  @override
  Future<void> track({required TrackEvent event}) async {
    await super.track(event: event);
    // Handle event tracking
  }

  @override
  Future<void> pageView({required PageViewEvent event}) async {
    await super.pageView(event: event);
    // Handle page view tracking
  }

  @override
  Future<void> reset() async {
    await super.reset();
    // Handle user data reset
  }
}
```

### Example: Console Log Integration

Here's a simple integration that logs all events to the console.

```dart
import 'package:iforevents/iforevents.dart';

class ConsoleLogIntegration extends Integration {
  final String prefix;
  const ConsoleLogIntegration({this.prefix = '[Analytics]'});

  @override
  Future<void> identify({required IdentifyEvent event}) async {
    await super.identify(event: event);
    print('$prefix USER IDENTIFIED: ${event.customID}');
    print('$prefix User Properties: ${event.properties}');
  }

  @override
  Future<void> track({required TrackEvent event}) async {
    await super.track(event: event);
    print('$prefix EVENT: ${event.eventName}');
    if (event.properties.isNotEmpty) {
      print('$prefix Properties: ${event.properties}');
    }
  }
}
```

### Best Practices

-   **Error Handling**: Gracefully handle errors within your integration to prevent analytics failures from crashing the app.
-   **Performance**: Avoid long-running or blocking operations on the main thread. Use `unawaited` for fire-and-forget network calls.
-   **Configuration**: Make your integration configurable via constructor parameters (e.g., API keys, settings).
-   **Privacy**: Respect user privacy by sanitizing or removing sensitive data before sending it to third-party services.

## API Reference

### Iforevents Class

#### Methods

-   `init({List<Integration> integrations})` - Initialize with analytics integrations.
-   `identify({required String id, required Map<String, dynamic> data})` - Identify a user with custom data.
-   `track({required String eventName, EventType eventType, Map<String, dynamic> properties})` - Track a custom event.
-   `screen({required RouteSettings? toRoute, required RouteSettings? previousRoute})` - Track screen navigation.
-   `reset()` - Reset user data and clear stored information.

#### Static Properties

-   `ip` - Get the current public IP address.
-   `deviceData` - Get comprehensive device information.

### EventType Enum

-   `EventType.track` - A standard tracking event.
-   `EventType.screen` - A screen view event.
-   `EventType.identify` - A user identification event.

## Example Application

Check out the [example](./example) directory for a complete implementation showing:

-   Multi-integration setup
-   User identification flow
-   Event tracking examples
-   Navigation tracking with `IforeventsNavigatorObserver`
-   Usage of the Iforevents API integration

## Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details on how to submit pull requests, report issues, and more.

### Development Setup

1.  Clone the repository:
    ```bash
    git clone https://github.com/innovafour/flutter_iforevents.git
    cd flutter_iforevents
    ```
2.  Install dependencies for all packages:
    ```bash
    make bootstrap
    ```
3.  Run tests:
    ```bash
    flutter test
    ```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

-   📧 Email: [support@innovafour.com](mailto:support@innovafour.com)
-   🐛 Issues: [GitHub Issues](https://github.com/innovafour/flutter_iforevents/issues)
-   📖 Documentation: [API Documentation](https://pub.dev/documentation/iforevents/latest/)

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for a detailed list of changes.

---

Made with ❤️ by [Innovafour](https://innovafour.com)
