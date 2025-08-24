# IForEvents Mixpanel Integration

[![pub package](https://img.shields.io/pub/v/iforevents_mixpanel.svg)](https://pub.dev/packages/iforevents_mixpanel)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Mixpanel analytics integration for IForEvents. This package provides seamless integration with Mixpanel's powerful analytics platform, enabling you to track user behavior, events, and create detailed user profiles.

## Features

- 🎯 **Mixpanel Analytics Integration**: Full support for Mixpanel event tracking
- 📊 **Event Tracking**: Track custom events with properties
- 👤 **User Profiles**: Create and update user profiles with custom properties
- 🔍 **User Journey Tracking**: Track user actions and funnel analysis
- 📱 **Cross-platform**: Works on Android, iOS, and Web
- 🔄 **User Aliasing**: Connect anonymous and identified users
- 🚀 **Real-time Analytics**: View events in real-time on Mixpanel dashboard

## Installation

### 1. Add Dependencies

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  iforevents: ^0.0.2
  iforevents_mixpanel: ^0.0.1
```

Then run:

```bash
flutter pub get
```

### 2. Get Mixpanel Project Token

1. **Create a Mixpanel account** at [mixpanel.com](https://mixpanel.com)
2. **Create a new project** or use an existing one
3. **Find your Project Token** in Project Settings → Project Details

### 3. No Native Configuration Required

Mixpanel integration works out of the box without any native Android or iOS configuration. The Mixpanel Flutter SDK handles all the necessary setup internally.

## Usage

### Basic Setup

```dart
import 'package:iforevents/iforevents.dart';
import 'package:iforevents_mixpanel/iforevents_mixpanel.dart';

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
      const MixpanelIntegration(
        token: 'YOUR_MIXPANEL_PROJECT_TOKEN',
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mixpanel Analytics Demo',
      home: HomeScreen(iforevents: iforevents),
    );
  }
}
```

### User Identification

```dart
// Identify a user with custom properties
await iforevents.identify(
  event: IdentifyEvent(
    customID: 'user_123',
    properties: {
      'email': 'user@example.com',
      'name': 'John Doe',
      'plan': 'premium',
      'signup_date': '2023-01-15',
      'age': 28,
      'location': 'New York',
      'subscription_status': 'active',
    },
  ),
);
```

### Event Tracking

```dart
// Track simple events
iforevents.track(
  event: TrackEvent(
    eventName: 'button_clicked',
    properties: {
      'button_name': 'signup',
      'screen': 'home',
      'timestamp': DateTime.now().toIso8601String(),
    },
  ),
);

// Track user actions
iforevents.track(
  event: TrackEvent(
    eventName: 'video_played',
    properties: {
      'video_id': 'vid_123',
      'video_title': 'Getting Started Tutorial',
      'video_duration': 120,
      'video_position': 30,
      'quality': 'HD',
    },
  ),
);

// Track ecommerce events
iforevents.track(
  event: TrackEvent(
    eventName: 'purchase_completed',
    properties: {
      'product_id': 'prod_123',
      'product_name': 'Premium Plan',
      'price': 29.99,
      'currency': 'USD',
      'payment_method': 'credit_card',
      'discount_applied': false,
    },
  ),
);
```

### Reset User Data

```dart
// Reset user identification and clear stored data
await iforevents.reset();
```

## Advanced Usage

### Custom Properties and Super Properties

Mixpanel allows you to set super properties that are included with every event:

```dart
// These properties will be included with every subsequent event
await iforevents.identify(
  event: IdentifyEvent(
    customID: 'user_123',
    properties: {
      'app_version': '1.2.0',
      'subscription_tier': 'premium',
      'referral_source': 'google_ads',
      'user_segment': 'power_user',
    },
  ),
);
```

### Funnel Analysis

Track key funnel events to analyze user conversion:

```dart
// Onboarding funnel
iforevents.track(
  event: TrackEvent(
    eventName: 'onboarding_started',
    properties: {
      'source': 'app_launch',
      'user_type': 'new_user',
    },
  ),
);

iforevents.track(
  event: TrackEvent(
    eventName: 'onboarding_step_completed',
    properties: {
      'step_number': 1,
      'step_name': 'welcome_screen',
      'time_spent': 15,
    },
  ),
);

iforevents.track(
  event: TrackEvent(
    eventName: 'onboarding_completed',
    properties: {
      'total_time': 120,
      'steps_completed': 4,
      'signup_method': 'email',
    },
  ),
);
```

### A/B Testing

Track A/B test variants and outcomes:

```dart
iforevents.track(
  event: TrackEvent(
    eventName: 'ab_test_exposure',
    properties: {
      'test_name': 'checkout_button_color',
      'variant': 'blue_button',
      'user_segment': 'new_users',
    },
  ),
);

iforevents.track(
  event: TrackEvent(
    eventName: 'ab_test_conversion',
    properties: {
      'test_name': 'checkout_button_color',
      'variant': 'blue_button',
      'conversion_event': 'purchase_completed',
      'conversion_value': 29.99,
    },
  ),
);
```

### User Engagement Tracking

```dart
// Session tracking
iforevents.track(
  event: TrackEvent(
    eventName: 'session_started',
    properties: {
      'session_id': 'sess_123',
      'entry_point': 'home_screen',
    },
  ),
);

iforevents.track(
  event: TrackEvent(
    eventName: 'session_ended',
    properties: {
      'session_id': 'sess_123',
      'session_duration': 480, // seconds
      'pages_viewed': 5,
      'actions_taken': 12,
    },
  ),
);
```

## Creating Custom Integrations

You can extend the `Integration` class to create your own custom integrations:

```dart
import 'package:iforevents/iforevents.dart';

class CustomMixpanelIntegration extends Integration {
  final String projectToken;
  
  const CustomMixpanelIntegration({required this.projectToken});

  @override
  Future<void> init() async {
    // IMPORTANT: Always call super.init() first due to @mustCallSuper
    await super.init();
    
    // Custom initialization logic
    Mixpanel.init(projectToken);
    print('Custom Mixpanel Integration initialized with token: $projectToken');
  }

  @override
  Future<void> identify({required IdentifyEvent event}) async {
    // IMPORTANT: Always call super.identify() first due to @mustCallSuper
    await super.identify(event: event);
    
    // Custom user identification logic
    await Mixpanel.identify(event.customID);
    
    // Set user properties with custom transformation
    final transformedProperties = <String, dynamic>{};
    for (final entry in event.properties.entries) {
      if (entry.value != null) {
        // Custom property transformation
        transformedProperties['custom_${entry.key}'] = entry.value;
      }
    }
    
    await Mixpanel.getPeople().set(transformedProperties);
    print('User identified: ${event.customID}');
  }

  @override
  Future<void> track({required TrackEvent event}) async {
    // IMPORTANT: Always call super.track() first due to @mustCallSuper
    await super.track(event: event);
    
    // Custom event tracking with filtering
    final customProperties = <String, dynamic>{};
    
    for (final entry in event.properties.entries) {
      if (entry.value != null && entry.key.startsWith('mixpanel_')) {
        // Only track properties with specific prefix
        final cleanKey = entry.key.replaceFirst('mixpanel_', '');
        customProperties[cleanKey] = entry.value;
      }
    }

    await Mixpanel.track(event.eventName, customProperties);
    print('Event tracked: ${event.eventName}');
  }

  @override
  Future<void> reset() async {
    // IMPORTANT: Always call super.reset() first due to @mustCallSuper
    await super.reset();
    
    // Custom reset logic
    await Mixpanel.reset();
    print('Mixpanel data reset');
  }

  @override
  Future<void> pageView({required PageViewEvent event}) async {
    // IMPORTANT: Always call super.pageView() first due to @mustCallSuper
    await super.pageView(event: event);
    
    // Custom page view tracking
    if (event.toRoute?.name != null) {
      await Mixpanel.track('Page View', {
        'page_name': event.toRoute!.name,
        'navigation_type': event.navigationType.toString(),
        'previous_page': event.previousRoute?.name ?? 'unknown',
      });
      print('Page view tracked: ${event.toRoute!.name}');
    }
  }
}
```

## Best Practices

### 1. Event Naming Convention
- Use clear, descriptive names: `signup_completed`, `video_played`
- Be consistent across your app
- Use present tense: `button_clicked` not `button_click`

### 2. Property Guidelines
- Include context properties: `screen_name`, `feature_name`
- Use consistent data types
- Avoid deeply nested objects
- Include timing information when relevant

### 3. User Profile Management
- Update user properties when user state changes
- Use reserved properties correctly (`$email`, `$name`, etc.)
- Set user properties early in the user journey

### 4. Performance Optimization
- Batch events when possible using flush intervals
- Avoid tracking too frequently
- Use appropriate data types for properties

## Mixpanel Dashboard Features

### Real-time Event Tracking
1. Go to Mixpanel Dashboard → Live View
2. See events as they happen in real-time
3. Verify your implementation

### Funnel Analysis
1. Create funnels to track conversion rates
2. Analyze where users drop off
3. Optimize user experience based on data

### Cohort Analysis
1. Create user cohorts based on behavior
2. Track retention over time
3. Compare different user segments

### A/B Testing
1. Set up experiments in Mixpanel
2. Track exposure and conversion events
3. Analyze results statistically

## Troubleshooting

### Common Issues

1. **Events not appearing in Mixpanel**
   - Check your project token
   - Verify internet connection
   - Events may take a few minutes to appear

2. **User profiles not updating**
   - Ensure you're calling `identify()` before tracking events
   - Check that user properties are properly formatted

3. **Missing event properties**
   - Verify property names and values
   - Check for null or empty values that might be filtered

### Debug Mode

Enable debug logging to troubleshoot issues:

```dart
const MixpanelIntegration(
  token: 'YOUR_TOKEN',
  // Enable logging in debug mode
);
```

## Package Dependencies

This package uses the following dependencies:

- [`mixpanel_flutter`](https://pub.dev/packages/mixpanel_flutter) ^2.4.4 - Official Mixpanel SDK for Flutter
- [`iforevents`](https://pub.dev/packages/iforevents) - Core IforEvents package

## Mixpanel Documentation

For more information about Mixpanel:

- [Mixpanel Documentation](https://docs.mixpanel.com/)
- [Mixpanel Flutter SDK](https://github.com/mixpanel/mixpanel-flutter)
- [Mixpanel Best Practices](https://docs.mixpanel.com/docs/tracking/how-tos/events-and-properties)

## Support

- 📧 Email: [support@innovafour.com](mailto:support@innovafour.com)
- 🐛 Issues: [GitHub Issues](https://github.com/innovafour/flutter_iforevents/issues)
- 📖 Documentation: [API Documentation](https://pub.dev/documentation/iforevents_mixpanel/latest/)

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

Made with ❤️ by [Innovafour](https://innovafour.com)
