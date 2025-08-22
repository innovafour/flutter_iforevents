# IforEvents

[![pub package](https://img.shields.io/pub/v/iforevents.svg)](https://pub.dev/packages/iforevents)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A comprehensive Flutter package for event tracking and analytics integration. IforEvents provides a unified interface for multiple analytics platforms while automatically collecting device information and user data.

## Features

- 📊 **Multi-platform Analytics**: Support for Firebase Analytics, Mixpanel, and Algolia
- 📱 **Cross-platform**: Works on Android, iOS, and Windows
- 🔍 **Automatic Device Detection**: Collects device information automatically
- 🌐 **IP Detection**: Automatic IP address detection
- 🎯 **Event Tracking**: Simple event tracking with custom properties
- 👤 **User Identification**: User identification with custom data
- 🔄 **Route Tracking**: Automatic screen/route tracking
- 🏗️ **Modular Architecture**: Add only the integrations you need

## Supported Integrations

| Integration | Package | Description |
|-------------|---------|-------------|
| Firebase Analytics | `iforevents_firebase` | Google Firebase Analytics integration |
| Mixpanel | `iforevents_mixpanel` | Mixpanel analytics integration |
| Algolia | `iforevents_algolia` | Algolia search analytics integration |

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  iforevents: ^0.0.1
  # Add the integrations you need
  iforevents_firebase: ^0.0.1  # For Firebase Analytics
  iforevents_mixpanel: ^0.0.1  # For Mixpanel
  iforevents_algolia: ^0.0.1   # For Algolia
```

Then run:

```bash
flutter pub get
```

## Quick Start

### 1. Import the package

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
  const MixpanelIntegration(key: 'YOUR_MIXPANEL_KEY'),
]);
```

### 3. Identify users

```dart
await iforevents.identify(
  id: 'user123',
  data: {
    'email': 'user@example.com',
    'name': 'John Doe',
    'plan': 'premium',
  },
);
```

### 4. Track events

```dart
iforevents.track(
  eventName: 'button_clicked',
  properties: {
    'button_name': 'signup',
    'screen': 'home',
  },
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
  const MixpanelIntegration(key: 'your_mixpanel_project_token'),
]);
```

### User Identification

Identify users with custom data. Device information is automatically included:

```dart
await iforevents.identify(
  id: 'user_123',
  data: {
    'email': 'john.doe@example.com',
    'name': 'John Doe',
    'age': 30,
    'subscription': 'premium',
    'signup_date': '2023-01-15',
  },
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
iforevents.track(eventName: 'app_opened');

// Event with properties
iforevents.track(
  eventName: 'purchase_completed',
  properties: {
    'product_id': 'prod_123',
    'price': 29.99,
    'currency': 'USD',
    'category': 'premium_features',
  },
);

// Different event types
iforevents.track(
  eventName: 'page_view',
  eventType: EventType.screen,
  properties: {
    'page_name': 'product_details',
    'product_id': 'prod_123',
  },
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
- `identify({required String id, required Map<String, dynamic> data})` - Identify user with custom data
- `track({required String eventName, EventType eventType, Map<String, dynamic> properties})` - Track events
- `screen({required RouteSettings? toRoute, required RouteSettings? previousRoute})` - Track screen navigation
- `reset()` - Reset user data and clear stored information

#### Static Properties

- `ip` - Get current IP address
- `deviceData` - Get comprehensive device information

### EventType Enum

- `EventType.track` - Standard tracking event
- `EventType.screen` - Screen view event
- `EventType.identify` - User identification event

## Integration Guides

### Firebase Analytics

1. Add Firebase to your Flutter project following the [official guide](https://firebase.google.com/docs/flutter/setup)
2. Add the Firebase integration:

```yaml
dependencies:
  iforevents_firebase: ^0.0.1
```

3. Initialize:

```dart
import 'package:iforevents_firebase/iforevents_firebase.dart';

await iforevents.init(integrations: [
  const FirebaseIntegration(),
]);
```

### Mixpanel

1. Get your Mixpanel project token from [mixpanel.com](https://mixpanel.com)
2. Add the Mixpanel integration:

```yaml
dependencies:
  iforevents_mixpanel: ^0.0.1
```

3. Initialize with your token:

```dart
import 'package:iforevents_mixpanel/iforevents_mixpanel.dart';

await iforevents.init(integrations: [
  const MixpanelIntegration(key: 'YOUR_MIXPANEL_PROJECT_TOKEN'),
]);
```

### Algolia

1. Get your Algolia credentials
2. Add the Algolia integration:

```yaml
dependencies:
  iforevents_algolia: ^0.0.1
```

3. Initialize with your credentials:

```dart
import 'package:iforevents_algolia/iforevents_algolia.dart';

await iforevents.init(integrations: [
  const AlgoliaIntegration(/* your algolia config */),
]);
```

## Example

Check out the [example](./example) directory for a complete implementation showing:

- Multi-integration setup
- User identification flow
- Event tracking examples
- Navigation tracking
- Error handling

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

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

- 📧 Email: [support@innovafour.com](mailto:support@innovafour.com)
- 🐛 Issues: [GitHub Issues](https://github.com/innovafour/flutter_iforevents/issues)
- 📖 Documentation: [API Documentation](https://pub.dev/documentation/iforevents/latest/)

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for a detailed list of changes.

---

Made with ❤️ by [Innovafour](https://innovafour.com)
