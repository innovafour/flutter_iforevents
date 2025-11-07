# IForEvents

[![pub package](https://img.shields.io/pub/v/iforevents.svg)](https://pub.dev/packages/iforevents)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![codecov](https://codecov.io/gh/innovafour/flutter_iforevents/branch/main/graph/badge.svg)](https://codecov.io/gh/innovafour/flutter_iforevents)
[![style: very good analysis](https://img.shields.io/badge/style-very_good_analysis-B22C89.svg)](https://pub.dev/packages/very_good_analysis)

A comprehensive Flutter package for event tracking and analytics integration. IForEvents provides a unified interface for multiple analytics platforms while automatically collecting device information and user data.

## Table of Contents

- [IForEvents](#iforevents)
  - [Table of Contents](#table-of-contents)
  - [Features](#features)
  - [Platform Requirements](#platform-requirements)
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
    - [Lifecycle Management](#lifecycle-management)
  - [Configuration](#configuration)
    - [IForevents API Configuration](#iforevents-api-configuration)
    - [Configuration Examples](#configuration-examples)
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
  - [Error Handling & Debugging](#error-handling--debugging)
    - [Logging Configuration](#logging-configuration)
    - [Common Issues](#common-issues)
    - [Troubleshooting](#troubleshooting)
  - [Performance & Optimization](#performance--optimization)
    - [Best Practices](#best-practices-1)
    - [Batching and Queue Management](#batching-and-queue-management)
    - [Memory Management](#memory-management)
  - [Testing](#testing)
    - [Unit Testing](#unit-testing)
    - [Integration Testing](#integration-testing)
    - [Mocking](#mocking)
  - [Privacy & Data Collection](#privacy--data-collection)
    - [Data Collection](#data-collection)
    - [GDPR Compliance](#gdpr-compliance)
    - [Opt-out Configuration](#opt-out-configuration)
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

- 📊 **Multi-platform Analytics**: Support for Iforevents API, Firebase, Mixpanel, Amplitude, Algolia, Meta, and CleverTap.
- 📱 **Cross-platform**: Works on Android, iOS, Windows, macOS, Linux, and Web.
- 🔍 **Automatic Device Detection**: Collects device information automatically.
- 🌐 **IP Detection**: Automatic IP address detection.
- 🎯 **Event Tracking**: Simple event tracking with custom properties.
- 👤 **User Identification**: User identification with custom data.
- 🔄 **Route Tracking**: Automatic screen/route tracking.
- 🏗️ **Modular Architecture**: Add only the integrations you need.
- 🔌 **Custom Integrations**: Easily extend the library with your own integrations.
- 📦 **Offline Caching & Batching**: Robust event queueing for the Iforevents API integration.
- 🛡️ **Error Handling**: Graceful error handling with comprehensive logging.
- ⚡ **High Performance**: Optimized for minimal impact on app performance.
- 🔒 **Privacy Focused**: Configurable data collection with GDPR compliance.

## Platform Requirements

| Platform | Minimum Version | SDK/API Level | Notes |
|----------|-----------------|---------------|-------|
| **Android** | Android 4.4 (KitKat) | API Level 19+ | Full feature support |
| **iOS** | iOS 12.0+ | iOS 12.0+ | Full feature support |
| **Windows** | Windows 10+ | Windows 10+ | Full feature support |
| **macOS** | macOS 10.14+ | macOS 10.14+ | Full feature support |
| **Linux** | Ubuntu 18.04+ | - | Full feature support |
| **Web** | Chrome 70+, Safari 12+ | - | Limited device info |

### Flutter Requirements
- **Flutter SDK**: 3.8.1 or higher
- **Dart SDK**: 3.8.1 or higher

### Integration-Specific Requirements
- **Firebase**: Requires Firebase project setup and `google-services.json`/`GoogleService-Info.plist`
- **CleverTap**: Requires CleverTap account and native configuration
- **Meta**: Requires Facebook App ID and native SDK setup

## Supported Integrations

| Integration | Package | Description | Native Config | Platforms |
|---|---|---|---|---|
| **Iforevents API** | `iforevents` | Native integration with the Iforevents backend | ❌ No | All |
| **Firebase Analytics** | `iforevents_firebase` | Google Firebase Analytics integration | ✅ Yes | Android, iOS, Web |
| **Mixpanel** | `iforevents_mixpanel` | Mixpanel analytics integration | ❌ No | All |
| **Amplitude** | `iforevents_amplitude` | Amplitude product analytics integration | ❌ No | All |
| **Algolia** | `iforevents_algolia` | Algolia search analytics integration | ❌ No | All |
| **Meta (Facebook)** | `iforevents_meta` | Facebook Pixel integration | ✅ Yes | Android, iOS, Web |
| **CleverTap** | `iforevents_clevertap` | CleverTap analytics and engagement integration | ✅ Yes | Android, iOS |

### Integration Setup Guides
- [Firebase Setup Guide](https://pub.dev/packages/iforevents_firebase) - Requires Firebase project configuration
- [CleverTap Setup Guide](https://pub.dev/packages/iforevents_clevertap) - Requires native SDK configuration  
- [Meta Setup Guide](https://pub.dev/packages/iforevents_meta) - Requires Facebook App setup

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  iforevents: ^0.0.5
  # Add the integrations you need
  iforevents_firebase: ^0.0.3
  iforevents_mixpanel: ^0.0.3
  iforevents_amplitude: ^0.0.1
  iforevents_algolia: ^0.0.3
  iforevents_meta: ^0.0.3
  iforevents_clevertap: ^0.0.3
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

### Lifecycle Management

Proper lifecycle management ensures that events are processed and resources are cleaned up correctly.

#### App Initialization
```dart
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
      // Your integrations
    ]);
  }

  @override
  void dispose() {
    // Clean up resources when the app is disposed
    Iforevents.dispose();
    super.dispose();
  }
}
```

#### Background/Foreground Handling
```dart
class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    Iforevents.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
        // App is going to background, flush pending events
        Iforevents.processEventsNow();
        break;
      case AppLifecycleState.resumed:
        // App resumed, you might want to track this
        iforevents.track(
          event: TrackEvent(eventName: 'app_resumed'),
        );
        break;
      default:
        break;
    }
  }
}
```

## Configuration

### IForevents API Configuration

The `IForeventsAPIConfig` class provides comprehensive configuration options for the native IForevents API integration.

```dart
final config = IForeventsAPIConfig(
  // Required
  projectKey: 'your-project-key',
  projectSecret: 'your-project-secret',
  
  // Optional - Server Configuration
  baseUrl: 'https://api.iforevents.com', // Default
  
  // Optional - Batching Configuration
  batchSize: 10, // Events per batch (default: 10, set to 1 for immediate sending)
  batchIntervalMs: 5000, // Check interval in ms (default: 5000ms)
  
  // Optional - Network Timeouts
  connectTimeoutMs: 10000, // Connection timeout (default: 10000ms)
  receiveTimeoutMs: 10000, // Receive timeout (default: 10000ms)
  sendTimeoutMs: 10000, // Send timeout (default: 10000ms)
  
  // Optional - Retry Configuration
  enableRetry: true, // Enable automatic retry (default: true)
  maxRetries: 3, // Maximum retry attempts (default: 3)
  retryDelayMs: 1000, // Delay between retries (default: 1000ms)
  
  // Optional - Development & Debugging
  enableLogging: false, // Enable debug logs (default: false)
  throwOnError: false, // Throw exceptions on errors (default: false)
  
  // Optional - Advanced Options
  requeueFailedEvents: true, // Re-queue failed events (default: true)
);
```

### Configuration Examples

#### Development Configuration
```dart
final developmentConfig = IForeventsAPIConfig(
  projectKey: 'dev-project-key',
  projectSecret: 'dev-project-secret',
  baseUrl: 'https://dev-api.iforevents.com',
  batchSize: 5, // Smaller batches for testing
  batchIntervalMs: 3000, // Check more frequently
  enableLogging: true, // Enable detailed logs
  throwOnError: true, // Throw exceptions for debugging
  enableRetry: true,
  maxRetries: 2,
  retryDelayMs: 1000,
);
```

#### Production Configuration
```dart
final productionConfig = IForeventsAPIConfig(
  projectKey: const String.fromEnvironment('IFOREVENTS_PROJECT_KEY'),
  projectSecret: const String.fromEnvironment('IFOREVENTS_PROJECT_SECRET'),
  baseUrl: 'https://api.iforevents.com',
  batchSize: 20, // Larger batches for efficiency
  batchIntervalMs: 10000, // Check every 10 seconds
  enableLogging: false, // No logs in production
  throwOnError: false, // Don't throw exceptions in production
  enableRetry: true,
  maxRetries: 3,
  retryDelayMs: 2000,
  connectTimeoutMs: 15000,
  receiveTimeoutMs: 15000,
);
```

#### Real-time Configuration (No Batching)
```dart
final realtimeConfig = IForeventsAPIConfig(
  projectKey: 'your-project-key',
  projectSecret: 'your-project-secret',
  baseUrl: 'https://api.iforevents.com',
  batchSize: 1, // Send immediately
  enableRetry: true,
  maxRetries: 2,
  retryDelayMs: 500,
  connectTimeoutMs: 5000,
  receiveTimeoutMs: 5000,
);
```

#### Offline-First Configuration
```dart
final offlineConfig = IForeventsAPIConfig(
  projectKey: 'your-project-key',
  projectSecret: 'your-project-secret',
  baseUrl: 'https://api.iforevents.com',
  batchSize: 100, // Very large batches
  batchIntervalMs: 30000, // Check every 30 seconds
  enableRetry: true,
  maxRetries: 5, // More retries for offline scenarios
  retryDelayMs: 3000,
  requeueFailedEvents: true,
  connectTimeoutMs: 20000,
  receiveTimeoutMs: 20000,
);
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
- ✅ **User identification** and user management
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

### Amplitude

1.  Get your Amplitude API key from [amplitude.com](https://amplitude.com).
2.  Add the `iforevents_amplitude` package to your `pubspec.yaml`.
3.  Initialize with your API key:

    ```dart
    import 'package:iforevents_amplitude/iforevents_amplitude.dart';

    await iforevents.init(integrations: [
      const AmplitudeIntegration(apiKey: 'YOUR_AMPLITUDE_API_KEY'),
    ]);
    ```

**Features:**
- ✅ **Product analytics** with behavioral cohorts
- ✅ **Event tracking** with custom properties
- ✅ **User identification** with the Identify API
- ✅ **Revenue tracking** with the Revenue API
- ✅ **Group analytics** for B2B applications
- ✅ **Session tracking** and funnel analysis
- ✅ **EU data residency** support
- ✅ **Configurable batching** for performance optimization

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

## Error Handling & Debugging

### Logging Configuration

IForEvents provides comprehensive logging for debugging and monitoring:

```dart
// Enable logging in development
final config = IForeventsAPIConfig(
  projectKey: 'your-key',
  projectSecret: 'your-secret',
  enableLogging: true, // Enable detailed logs
  throwOnError: true, // Throw exceptions for debugging
);

// Disable logging in production
final productionConfig = IForeventsAPIConfig(
  projectKey: 'your-key',
  projectSecret: 'your-secret',
  enableLogging: false, // Disable logs
  throwOnError: false, // Handle errors gracefully
);
```

### Common Issues

#### Integration Initialization Failures
```dart
try {
  await iforevents.init(integrations: [
    const FirebaseIntegration(),
    const MixpanelIntegration(token: 'your-token'),
  ]);
} catch (e) {
  print('Analytics initialization failed: $e');
  // Continue app execution without analytics
}
```

#### Network Connectivity Issues
```dart
// Configure retry settings for poor network conditions
final config = IForeventsAPIConfig(
  projectKey: 'your-key',
  projectSecret: 'your-secret',
  enableRetry: true,
  maxRetries: 5, // Increase retries
  retryDelayMs: 3000, // Longer retry delay
  connectTimeoutMs: 20000, // Longer timeouts
);
```

#### Event Validation Errors
```dart
// Always validate event data before tracking
void trackPurchase(Map<String, dynamic> purchaseData) {
  try {
    // Validate required fields
    if (purchaseData['amount'] == null || purchaseData['currency'] == null) {
      print('Invalid purchase data: missing required fields');
      return;
    }
    
    iforevents.track(
      event: TrackEvent(
        eventName: 'purchase_completed',
        properties: purchaseData,
      ),
    );
  } catch (e) {
    print('Error tracking purchase: $e');
  }
}
```

### Troubleshooting

#### Check Queue Status
```dart
// For IForevents API integration
final apiIntegration = IForeventsAPIIntegration.instance;
if (apiIntegration != null) {
  final status = apiIntegration.getQueueStatus();
  print('Pending events: ${status.queuedEvents}');
  print('Failed events: ${status.failedEvents}');
  
  // Manually flush queue if needed
  await apiIntegration.flush();
}
```

#### Monitor Background Processing
```dart
// Get background processor statistics
final stats = Iforevents.getBackgroundProcessorStats();
print('Processing stats: $stats');

// Process events immediately if needed
await Iforevents.processEventsNow();
```

#### Debug Event Storage
```dart
// Check pending events count
final pendingCount = Iforevents.getPendingEventsCount();
print('Pending events: $pendingCount');

// Get pending events by integration
final pendingStats = Iforevents.getPendingEventsStats();
print('Pending by integration: $pendingStats');

// Clear all pending events (for testing)
await Iforevents.clearPendingEvents();
```

## Performance & Optimization

### Best Practices

#### 1. **Use Batching for High-Volume Apps**
```dart
final config = IForeventsAPIConfig(
  projectKey: 'your-key',
  projectSecret: 'your-secret',
  batchSize: 50, // Larger batches for efficiency
  batchIntervalMs: 15000, // Less frequent network calls
);
```

#### 2. **Initialize Analytics Early**
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize analytics early in app lifecycle
  final iforevents = const Iforevents();
  await iforevents.init(integrations: [
    // Your integrations
  ]);
  
  runApp(MyApp());
}
```

#### 3. **Use Background Processing**
```dart
// Events are automatically processed in the background
// No need to await track() calls for fire-and-forget events
iforevents.track(
  event: TrackEvent(eventName: 'button_clicked'),
  // Don't await this call
);
```

#### 4. **Optimize for Different Network Conditions**
```dart
// For poor network conditions
final offlineConfig = IForeventsAPIConfig(
  projectKey: 'your-key',
  projectSecret: 'your-secret',
  batchSize: 100, // Larger batches
  batchIntervalMs: 30000, // Less frequent attempts
  maxRetries: 5, // More retries
  retryDelayMs: 5000, // Longer delays
);
```

### Batching and Queue Management

#### Understanding the Queue System
- Events are automatically queued when network is unavailable
- Background processor retries failed events automatically
- Configurable retry intervals and maximum attempts
- Events are persisted across app restarts

#### Manual Queue Management
```dart
// Get current queue status
final status = apiIntegration.getQueueStatus();
print('Queued: ${status.queuedEvents}, Failed: ${status.failedEvents}');

// Force flush all pending events
await apiIntegration.flush();

// Process events immediately
await Iforevents.processEventsNow();

// Configure background processing interval
Iforevents.setBackgroundProcessingInterval(30); // 30 seconds
```

### Memory Management

#### 1. **Proper Disposal**
```dart
@override
void dispose() {
  // Always dispose when done
  Iforevents.dispose();
  super.dispose();
}
```

#### 2. **Avoid Memory Leaks**
```dart
// Don't store large objects in event properties
iforevents.track(
  event: TrackEvent(
    eventName: 'user_action',
    properties: {
      'user_id': userId, // ✅ Good - small primitive
      'timestamp': DateTime.now().toIso8601String(), // ✅ Good
      // 'user_object': entireUserObject, // ❌ Bad - large object
    },
  ),
);
```

## Testing

### Unit Testing

#### Testing Custom Integrations
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:iforevents/iforevents.dart';

class TestIntegration extends Integration {
  final List<TrackEvent> trackedEvents = [];
  bool initCalled = false;
  bool resetCalled = false;

  @override
  Future<void> init() async {
    await super.init();
    initCalled = true;
  }

  @override
  Future<void> track({required TrackEvent event}) async {
    await super.track(event: event);
    trackedEvents.add(event);
  }

  @override
  Future<void> reset() async {
    await super.reset();
    resetCalled = true;
    trackedEvents.clear();
  }
}

void main() {
  group('IForEvents Tests', () {
    late Iforevents iforevents;
    late TestIntegration testIntegration;

    setUp(() {
      iforevents = const Iforevents();
      testIntegration = TestIntegration();
    });

    tearDown(() async {
      await Iforevents.dispose();
    });

    test('should initialize integration', () async {
      await iforevents.init(integrations: [testIntegration]);
      expect(testIntegration.initCalled, isTrue);
    });

    test('should track events', () async {
      await iforevents.init(integrations: [testIntegration]);
      
      iforevents.track(
        event: TrackEvent(
          eventName: 'test_event',
          properties: {'test': 'value'},
        ),
      );

      // Wait for async processing
      await Future.delayed(Duration(milliseconds: 100));
      
      expect(testIntegration.trackedEvents, hasLength(1));
      expect(testIntegration.trackedEvents.first.eventName, equals('test_event'));
    });
  });
}
```

### Integration Testing

#### Testing with Real Services
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:iforevents/iforevents.dart';

void main() {
  IntegrationTestWidgetsBinding.ensureInitialized();

  group('IForEvents Integration Tests', () {
    testWidgets('should send events to real services', (tester) async {
      final iforevents = const Iforevents();
      
      // Use test/development configuration
      final config = IForeventsAPIConfig(
        projectKey: 'test-project-key',
        projectSecret: 'test-project-secret',
        baseUrl: 'https://test-api.iforevents.com',
        enableLogging: true,
      );

      await iforevents.init(integrations: [
        IForeventsAPIIntegration(config: config),
      ]);

      // Test user identification
      await iforevents.identify(
        event: IdentifyEvent(
          customID: 'test-user-${DateTime.now().millisecondsSinceEpoch}',
          properties: {'test': true},
        ),
      );

      // Test event tracking
      iforevents.track(
        event: TrackEvent(
          eventName: 'integration_test_event',
          properties: {
            'timestamp': DateTime.now().toIso8601String(),
            'test_run': true,
          },
        ),
      );

      // Wait for events to be processed
      await Future.delayed(Duration(seconds: 5));
      
      // Force flush to ensure events are sent
      final apiIntegration = IForeventsAPIIntegration.instance;
      if (apiIntegration != null) {
        await apiIntegration.flush();
      }
    });
  });
}
```

### Mocking

#### Mocking for Unit Tests
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:iforevents/iforevents.dart';

// Generate mocks
@GenerateMocks([Integration])
import 'analytics_test.mocks.dart';

void main() {
  group('Mocked Analytics Tests', () {
    late MockIntegration mockIntegration;

    setUp(() {
      mockIntegration = MockIntegration();
    });

    test('should call integration methods', () async {
      final iforevents = const Iforevents();
      await iforevents.init(integrations: [mockIntegration]);

      // Verify init was called
      verify(mockIntegration.init()).called(1);

      // Test tracking
      final event = TrackEvent(eventName: 'test');
      iforevents.track(event: event);

      // Wait and verify
      await Future.delayed(Duration(milliseconds: 100));
      verify(mockIntegration.track(event: event)).called(1);
    });
  });
}
```

## Privacy & Data Collection

### Data Collection

IForEvents automatically collects the following device information:

#### Always Collected
- **Device ID**: Platform-specific unique identifier
- **Device Brand & Model**: Device manufacturer and model
- **OS Version**: Operating system version
- **App Version**: Application version and build number
- **Platform**: Target platform (Android, iOS, etc.)
- **IP Address**: Both local and public IP addresses
- **Timestamp**: Event timestamp in UTC

#### Platform-Specific Data
- **Android**: Android ID, SDK version, device specifications
- **iOS**: Identifier for Vendor, device specifications
- **Windows**: Device ID, computer name, Windows version
- **Web**: Browser information, user agent

### GDPR Compliance

#### 1. **User Consent Management**
```dart
class PrivacyManager {
  static bool _analyticsEnabled = false;
  
  static bool get analyticsEnabled => _analyticsEnabled;
  
  static Future<void> setAnalyticsEnabled(bool enabled) async {
    _analyticsEnabled = enabled;
    
    if (!enabled) {
      // User opted out, reset and clear data
      await iforevents.reset();
      await Iforevents.clearPendingEvents();
    }
  }
  
  static bool shouldTrackEvent() {
    return _analyticsEnabled;
  }
}

// Use in your tracking code
void trackEvent(String eventName, Map<String, dynamic> properties) {
  if (PrivacyManager.shouldTrackEvent()) {
    iforevents.track(
      event: TrackEvent(
        eventName: eventName,
        properties: properties,
      ),
    );
  }
}
```

#### 2. **Data Minimization**
```dart
// Create a privacy-focused integration
class PrivacyFriendlyIntegration extends Integration {
  final bool collectDeviceInfo;
  final bool collectIPAddress;
  
  const PrivacyFriendlyIntegration({
    this.collectDeviceInfo = true,
    this.collectIPAddress = false,
  });

  @override
  Future<void> track({required TrackEvent event}) async {
    await super.track(event: event);
    
    // Filter out sensitive data
    final filteredProperties = <String, dynamic>{};
    
    for (final entry in event.properties.entries) {
      // Skip IP address if not allowed
      if (!collectIPAddress && entry.key.contains('ip')) {
        continue;
      }
      
      // Skip device info if not allowed
      if (!collectDeviceInfo && entry.key.startsWith('device_')) {
        continue;
      }
      
      filteredProperties[entry.key] = entry.value;
    }
    
    // Send filtered data to your analytics service
    // ... your implementation
  }
}
```

### Opt-out Configuration

#### 1. **Complete Opt-out**
```dart
class AnalyticsManager {
  static bool _isOptedOut = false;
  
  static Future<void> optOut() async {
    _isOptedOut = true;
    
    // Clear all stored data
    await iforevents.reset();
    await Iforevents.clearPendingEvents();
    
    // Stop background processing
    Iforevents.stopBackgroundProcessing();
    
    // Store opt-out preference
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('analytics_opted_out', true);
  }
  
  static Future<void> optIn() async {
    _isOptedOut = false;
    
    // Restart background processing
    Iforevents.startBackgroundProcessing();
    
    // Store opt-in preference
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('analytics_opted_out', false);
  }
  
  static Future<bool> isOptedOut() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('analytics_opted_out') ?? false;
  }
}
```

#### 2. **Selective Data Collection**
```dart
// Configure what data to collect
final privacyConfig = IForeventsAPIConfig(
  projectKey: 'your-key',
  projectSecret: 'your-secret',
  enableLogging: false, // Disable logs that might contain PII
  requeueFailedEvents: false, // Don't store failed events
);

// Initialize with privacy settings
await iforevents.init(integrations: [
  IForeventsAPIIntegration(config: privacyConfig),
  PrivacyFriendlyIntegration(
    collectDeviceInfo: await getUserConsent('device_info'),
    collectIPAddress: await getUserConsent('location_data'),
  ),
]);
```

## API Reference

### Iforevents Class

#### Methods

-   `init({List<Integration> integrations})` - Initialize with analytics integrations.
-   `identify({required IdentifyEvent event})` - Identify a user with custom data.
-   `track({required TrackEvent event})` - Track a custom event.
-   `pageViewed({required PageViewEvent event})` - Track page/screen views.
-   `reset()` - Reset user data and clear stored information.

#### Static Methods

-   `dispose()` - Clean up resources and stop background processing.
-   `processEventsNow()` - Immediately process all pending events.
-   `clearPendingEvents()` - Clear all pending events (useful for testing).
-   `getPendingEventsCount()` - Get the total number of pending events.
-   `getPendingEventsStats()` - Get pending events statistics by integration.
-   `getBackgroundProcessorStats()` - Get background processor statistics.
-   `setBackgroundProcessingInterval(int seconds)` - Set background processing interval.
-   `startBackgroundProcessing({int intervalSeconds})` - Start background processing.
-   `stopBackgroundProcessing()` - Stop background processing.
-   `setRetryIntervals(List<int> intervals)` - Set custom retry intervals.
-   `applyRetryPreset(String presetName)` - Apply a preset retry configuration.
-   `getAvailableRetryPresets()` - Get available retry presets.
-   `getCurrentConfiguration()` - Get current configuration.
-   `resetConfigurationToDefaults()` - Reset configuration to defaults.

#### Static Properties

-   `ip` - Get the current public IP address.
-   `deviceData` - Get comprehensive device information.
-   `retryIntervals` - Get current retry intervals configuration.

### EventType Enum

-   `EventType.track` - A standard tracking event.
-   `EventType.screen` - A screen view event.
-   `EventType.identify` - A user identification event.

### Event Classes

#### TrackEvent
```dart
class TrackEvent {
  final String eventName;
  final Map<String, dynamic> properties;
  
  const TrackEvent({
    required this.eventName,
    this.properties = const {},
  });
}
```

#### IdentifyEvent
```dart
class IdentifyEvent {
  final String customID;
  final Map<String, dynamic> properties;
  
  const IdentifyEvent({
    required this.customID,
    this.properties = const {},
  });
}
```

#### PageViewEvent
```dart
class PageViewEvent {
  final String? routeName;
  final String? previousRouteName;
  final Map<String, dynamic> properties;
  
  const PageViewEvent({
    this.routeName,
    this.previousRouteName,
    this.properties = const {},
  });
}
```

### Configuration Classes

#### IForeventsAPIConfig
```dart
class IForeventsAPIConfig {
  const IForeventsAPIConfig({
    required this.projectKey,
    required this.projectSecret,
    this.baseUrl = 'https://api.iforevents.com',
    this.batchSize = 10,
    this.batchIntervalMs = 5000,
    this.connectTimeoutMs = 10000,
    this.receiveTimeoutMs = 10000,
    this.sendTimeoutMs = 10000,
    this.enableRetry = true,
    this.maxRetries = 3,
    this.retryDelayMs = 1000,
    this.enableLogging = false,
    this.throwOnError = false,
    this.requeueFailedEvents = true,
  });
}
```

## Example Application

Check out the [example](./example) directory for a complete implementation showing:

-   **Multi-integration setup** with Firebase, Mixpanel, and IForevents API
-   **User identification flow** with custom properties
-   **Event tracking examples** for various use cases
-   **Navigation tracking** with `IforeventsNavigatorObserver`
-   **Advanced configuration** examples (development, production, offline-first)
-   **Error handling** and debugging techniques
-   **Queue management** and manual event processing
-   **Performance optimization** examples
-   **Privacy configuration** and consent management

### Running the Example

1. **Clone the repository**:
   ```bash
   git clone https://github.com/innovafour/flutter_iforevents.git
   cd flutter_iforevents/iforevents/example
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Configure your API keys**:
   - Update `lib/main.dart` with your project credentials
   - For Firebase: Add your `google-services.json` and `GoogleService-Info.plist`
   - For Mixpanel: Add your project token

4. **Run the example**:
   ```bash
   flutter run
   ```

### Example Screens

- **Home Screen**: Basic tracking and user identification
- **Analytics Demo**: Advanced event tracking with custom properties
- **IForevents API Examples**: Configuration examples and queue management
- **Profile Screen**: User data management and privacy controls
- **Settings Screen**: Configuration and debugging tools

## Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details on how to submit pull requests, report issues, and more.

### Development Setup

1.  **Clone the repository**:
    ```bash
    git clone https://github.com/innovafour/flutter_iforevents.git
    cd flutter_iforevents
    ```
    
2.  **Install dependencies for all packages**:
    ```bash
    make bootstrap
    ```
    
3.  **Run tests**:
    ```bash
    # Run unit tests
    flutter test
    
    # Run integration tests
    flutter test integration_test/
    
    # Run tests with coverage
    flutter test --coverage
    ```

4.  **Run analysis**:
    ```bash
    # Run static analysis
    flutter analyze
    
    # Check formatting
    dart format --set-exit-if-changed .
    ```

5.  **Run example app**:
    ```bash
    cd iforevents/example
    flutter run
    ```

### Contributing Guidelines

- **Code Style**: Follow the [Dart Style Guide](https://dart.dev/guides/language/effective-dart)
- **Testing**: Write tests for all new features and bug fixes
- **Documentation**: Update documentation for any public API changes
- **Commits**: Use [Conventional Commits](https://www.conventionalcommits.org/) format
- **Pull Requests**: Include detailed description and test coverage

### Release Process

1. Update version numbers in all `pubspec.yaml` files
2. Update `CHANGELOG.md` with release notes
3. Create a new tag: `git tag v0.0.5`
4. Push tag: `git push origin v0.0.5`
5. Publish to pub.dev: `flutter packages pub publish`

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

-   📧 **Email**: [support@innovafour.com](mailto:support@innovafour.com)
-   🐛 **Issues**: [GitHub Issues](https://github.com/innovafour/flutter_iforevents/issues)
-   📖 **Documentation**: [API Documentation](https://pub.dev/documentation/iforevents/latest/)
-   💬 **Discussions**: [GitHub Discussions](https://github.com/innovafour/flutter_iforevents/discussions)
-   📱 **Examples**: [Example Applications](https://github.com/innovafour/flutter_iforevents/tree/main/iforevents/example)

### Getting Help

1. **Check the documentation** - Most questions are answered in this README or the API docs
2. **Search existing issues** - Someone might have already encountered your problem
3. **Check the example app** - The example demonstrates most use cases
4. **Create a new issue** - If you can't find an answer, create a detailed issue

### Bug Reports

When reporting bugs, please include:
- **Flutter version** (`flutter --version`)
- **Package version** (from `pubspec.yaml`)
- **Platform** (Android, iOS, Web, etc.)
- **Minimal reproduction code**
- **Expected vs actual behavior**
- **Console logs** (if relevant)

### Feature Requests

We welcome feature requests! Please:
- **Search existing requests** first
- **Provide detailed use case** and justification
- **Consider contributing** - PRs are welcome!

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for a detailed list of changes.

---

Made with ❤️ by [Innovafour](https://innovafour.com)
