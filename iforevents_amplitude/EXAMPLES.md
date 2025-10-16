# Amplitude Integration Examples

This document provides detailed examples of how to use the Amplitude integration with IforEvents.

## Demo Screen

The project includes a complete demo screen at:
`iforevents/example/lib/screens/amplitude_demo_screen.dart`

To access the demo:
1. Run the example app: `cd iforevents/example && flutter run`
2. Navigate to "Amplitude Demo" from the main screen
3. Explore all interactive features

---

# Amplitude Integration - Quick Start Examples

## Basic Setup

```dart
import 'package:iforevents/iforevents.dart';
import 'package:iforevents_amplitude/iforevents_amplitude.dart';

void main() async {
  final iforevents = const Iforevents();
  
  await iforevents.init(integrations: [
    const AmplitudeIntegration(
      apiKey: 'YOUR_AMPLITUDE_API_KEY',
    ),
  ]);
}
```

## Production Configuration

```dart
import 'package:amplitude_flutter/configuration.dart';
import 'package:amplitude_flutter/default_tracking.dart';

const AmplitudeIntegration(
  apiKey: 'YOUR_API_KEY',
  flushQueueSize: 50,
  flushIntervalMillis: 30000,
  optOut: false,
  defaultTracking: DefaultTrackingOptions(
    sessions: true,
    appLifecycles: false,
    deepLinks: false,
  ),
  useBatch: false,
  serverZone: ServerZone.us,
)
```

## Event Tracking

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

## User Identification

```dart
await iforevents.identify(
  event: IdentifyEvent(
    customID: 'user_123',
    properties: {
      'email': 'user@example.com',
      'name': 'John Doe',
      'plan': 'premium',
    },
  ),
);
```

## Revenue Tracking

```dart
final amplitude = AmplitudeIntegration.amplitude;

await amplitude?.trackRevenue(
  price: 29.99,
  quantity: 1,
  productId: 'premium_monthly',
  revenueType: 'purchase',
);
```

## Group Analytics

```dart
final amplitude = AmplitudeIntegration.amplitude;

await amplitude?.setGroup('company', 'acme_corp');

await amplitude?.setGroup('role', ['admin', 'power_user']);
```

## EU Data Residency

```dart
import 'package:amplitude_flutter/configuration.dart';

const AmplitudeIntegration(
  apiKey: 'YOUR_EU_API_KEY',
  serverZone: ServerZone.eu,
)
```

## Complete Example

```dart
import 'package:flutter/material.dart';
import 'package:iforevents/iforevents.dart';
import 'package:iforevents_amplitude/iforevents_amplitude.dart';
import 'package:amplitude_flutter/configuration.dart';
import 'package:amplitude_flutter/default_tracking.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

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
      const AmplitudeIntegration(
        apiKey: 'YOUR_AMPLITUDE_API_KEY',
        flushQueueSize: 30,
        flushIntervalMillis: 30000,
        defaultTracking: DefaultTrackingOptions(
          sessions: true,
          appLifecycles: true,
        ),
        serverZone: ServerZone.us,
      ),
    ]);

    await iforevents.identify(
      event: IdentifyEvent(
        customID: 'user_${DateTime.now().millisecondsSinceEpoch}',
        properties: {
          'platform': 'mobile',
          'app_version': '1.0.0',
        },
      ),
    );
  }

  void _trackButtonClick() {
    iforevents.track(
      event: TrackEvent(
        eventName: 'button_clicked',
        properties: {
          'button_name': 'home_cta',
          'timestamp': DateTime.now().toIso8601String(),
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Amplitude Integration')),
        body: Center(
          child: ElevatedButton(
            onPressed: _trackButtonClick,
            child: const Text('Track Event'),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    Iforevents.dispose();
    super.dispose();
  }
}
```
