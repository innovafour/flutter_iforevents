# IForEvents CleverTap Integration

[![pub package](https://img.shields.io/pub/v/iforevents_clevertap.svg)](https://pub.dev/packages/iforevents_clevertap)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

CleverTap analytics integration for IForEvents. This package provides seamless integration with CleverTap's customer engagement platform, enabling you to track user events, create detailed user profiles, and trigger personalized campaigns.

## Features

- 🚀 **CleverTap Integration**: Full support for CleverTap analytics and engagement
- 📊 **Event Tracking**: Track custom events with properties
- 👤 **User Profiles**: Create and update user profiles with custom properties
- 💳 **Revenue Tracking**: Track purchases and revenue with charged events
- 📱 **Push Notifications**: Support for CleverTap's push notification features
- 🎯 **Campaign Triggers**: Events can trigger personalized campaigns
- 📈 **Real-time Analytics**: View events and user data in real-time
- 🔄 **User Journey Mapping**: Track complete user lifecycle

## Installation

### 1. Add Dependencies

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  iforevents: ^0.0.2
  iforevents_clevertap: ^0.0.1
```

Then run:

```bash
flutter pub get
```

### 2. Get CleverTap Credentials

1. **Create a CleverTap account** at [clevertap.com](https://clevertap.com)
2. **Create a new project** or use an existing one
3. **Get your credentials** from Settings → Project:
   - Account ID
   - Token
   - Region (if applicable)

### 3. Native Configuration

CleverTap requires native configuration for both Android and iOS platforms.

#### Android Setup

1. **Add CleverTap SDK to Android**:

   In `android/app/build.gradle`:
   ```gradle
   dependencies {
       implementation 'com.clevertap.android:clevertap-android-sdk:4.+'
       implementation 'com.android.support:support-v4:28.0.0'
   }
   ```

2. **Add CleverTap configuration**:

   In `android/app/src/main/AndroidManifest.xml`:
   ```xml
   <application
       android:name="com.clevertap.android.sdk.Application">
       
       <!-- CleverTap Account ID and Token -->
       <meta-data
           android:name="CLEVERTAP_ACCOUNT_ID"
           android:value="YOUR_CLEVERTAP_ACCOUNT_ID" />
       <meta-data
           android:name="CLEVERTAP_TOKEN"
           android:value="YOUR_CLEVERTAP_TOKEN" />
       
       <!-- Optional: CleverTap Region -->
       <meta-data
           android:name="CLEVERTAP_REGION"
           android:value="YOUR_REGION" />
       
       <!-- CleverTap Notification Icon -->
       <meta-data
           android:name="CLEVERTAP_NOTIFICATION_ICON"
           android:value="ic_notification" />
   </application>
   ```

3. **Add Permissions**:
   ```xml
   <uses-permission android:name="android.permission.INTERNET" />
   <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
   <uses-permission android:name="android.permission.WAKE_LOCK" />
   ```

4. **Add ProGuard Rules** (if using ProGuard):

   In `android/app/proguard-rules.pro`:
   ```
   -dontwarn com.clevertap.**
   -keep class com.clevertap.** { *; }
   ```

#### iOS Setup

1. **Add CleverTap SDK to iOS**:

   In `ios/Podfile`:
   ```ruby
   pod 'CleverTap-iOS-SDK'
   ```

   Then run:
   ```bash
   cd ios && pod install
   ```

2. **Add CleverTap configuration**:

   In `ios/Runner/Info.plist`:
   ```xml
   <dict>
       <!-- CleverTap Account ID and Token -->
       <key>CleverTapAccountID</key>
       <string>YOUR_CLEVERTAP_ACCOUNT_ID</string>
       <key>CleverTapToken</key>
       <string>YOUR_CLEVERTAP_TOKEN</string>
       
       <!-- Optional: CleverTap Region -->
       <key>CleverTapRegion</key>
       <string>YOUR_REGION</string>
   </dict>
   ```

3. **Initialize CleverTap in AppDelegate**:

   In `ios/Runner/AppDelegate.swift`:
   ```swift
   import UIKit
   import Flutter
   import CleverTapSDK

   @UIApplicationMain
   @objc class AppDelegate: FlutterAppDelegate {
     override func application(
       _ application: UIApplication,
       didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
     ) -> Bool {
       
       // Initialize CleverTap
       CleverTap.autoIntegrate()
       
       GeneratedPluginRegistrant.register(with: self)
       return super.application(application, didFinishLaunchingWithOptions: launchOptions)
     }
   }
   ```

## Usage

### Basic Setup

```dart
import 'package:iforevents/iforevents.dart';
import 'package:iforevents_clevertap/iforevents_clevertap.dart';

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
      const ClevertapIntegration(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CleverTap Analytics Demo',
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
      'email': 'user@example.com', // Mapped to CleverTap Email
      'name': 'John Doe',          // Mapped to CleverTap Name
      'phone': '+1234567890',      // Mapped to CleverTap Phone
      'age': 28,
      'plan': 'premium',
      'signup_date': '2023-01-15',
      'location': 'New York',
      'interests': ['technology', 'sports'],
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

// Track user engagement
iforevents.track(
  event: TrackEvent(
    eventName: 'content_viewed',
    properties: {
      'content_id': 'article_123',
      'content_type': 'blog_post',
      'category': 'technology',
      'reading_time': 240,
    },
  ),
);

// Track app usage
iforevents.track(
  event: TrackEvent(
    eventName: 'feature_used',
    properties: {
      'feature_name': 'search',
      'usage_count': 5,
      'session_duration': 180,
    },
  ),
);
```

### Revenue Tracking

CleverTap has special handling for revenue events. Use the "Order Completed" event name:

```dart
// Track purchase/revenue (automatically uses CleverTap's charged event)
iforevents.track(
  event: TrackEvent(
    eventName: 'Order Completed', // Special event name for revenue
    properties: {
      'order_id': 'order_123',
      'total_amount': 99.99,
      'currency': 'USD',
      'payment_method': 'credit_card',
      'discount_applied': true,
      'discount_amount': 10.00,
      'products': [
        {
          'product_id': 'prod_123',
          'product_name': 'Premium Plan',
          'category': 'subscription',
          'price': 79.99,
          'quantity': 1,
        },
        {
          'product_id': 'prod_456',
          'product_name': 'Add-on Feature',
          'category': 'feature',
          'price': 19.99,
          'quantity': 1,
        }
      ],
    },
  ),
);
```

### Reset User Data

```dart
// Clear CleverTap resources and reset user data
await iforevents.reset();
```

## Advanced Usage

### Campaign and Segmentation Events

Track events that can be used for user segmentation and campaign triggers:

```dart
// User lifecycle events
iforevents.track(
  event: TrackEvent(
    eventName: 'onboarding_completed',
    properties: {
      'onboarding_version': 'v2.1',
      'steps_completed': 5,
      'time_taken': 300, // seconds
      'tutorial_skipped': false,
    },
  ),
);

// Engagement events
iforevents.track(
  event: TrackEvent(
    eventName: 'daily_streak_achieved',
    properties: {
      'streak_days': 7,
      'streak_type': 'login',
      'achievement_date': DateTime.now().toIso8601String(),
    },
  ),
);

// Retention events
iforevents.track(
  event: TrackEvent(
    eventName: 'app_backgrounded',
    properties: {
      'session_duration': 450,
      'screens_viewed': 8,
      'actions_performed': 15,
    },
  ),
);
```

### Creating Custom CleverTap Integration

You can extend the CleverTap integration for custom behavior:

```dart
import 'package:iforevents/iforevents.dart';
import 'package:clevertap_plugin/clevertap_plugin.dart';

class CustomClevertapIntegration extends Integration {
  final bool enableDebugLogging;
  final List<String> sensitiveProperties;
  
  const CustomClevertapIntegration({
    this.enableDebugLogging = false,
    this.sensitiveProperties = const ['email', 'phone'],
  });

  static bool isFirstIdentification = true;

  @override
  Future<void> init() async {
    if (enableDebugLogging) {
      await CleverTapPlugin.setDebugLevel(3);
      print('Custom CleverTap Integration initialized with debug logging');
    }
  }

  @override
  Future<void> identify({required IdentifyEvent event}) async {
    // Filter sensitive properties if needed
    final filteredProperties = <String, dynamic>{};
    
    for (final entry in event.properties.entries) {
      if (sensitiveProperties.contains(entry.key) && !_isValidData(entry.value)) {
        continue; // Skip invalid sensitive data
      }
      
      // Map special properties to CleverTap profile fields
      switch (entry.key) {
        case 'email':
          filteredProperties['Email'] = entry.value;
          break;
        case 'name':
          filteredProperties['Name'] = entry.value;
          break;
        case 'phone':
          filteredProperties['Phone'] = entry.value;
          break;
        case 'birthday':
          filteredProperties['DOB'] = entry.value;
          break;
        default:
          filteredProperties[entry.key] = entry.value;
      }
    }

    // Use onUserLogin for first identification, profileSet for updates
    if (isFirstIdentification) {
      await CleverTapPlugin.onUserLogin(filteredProperties);
      isFirstIdentification = false;
      
      if (enableDebugLogging) {
        print('CleverTap user login: ${event.customID}');
      }
    } else {
      await CleverTapPlugin.profileSet(filteredProperties);
      
      if (enableDebugLogging) {
        print('CleverTap profile updated: ${event.customID}');
      }
    }
  }

  @override
  Future<void> track({required TrackEvent event}) async {
    switch (event.eventName) {
      case 'Order Completed':
        await _trackRevenue(event);
        break;
      default:
        await _trackEvent(event);
    }
  }

  Future<void> _trackRevenue(TrackEvent event) async {
    final properties = Map<String, dynamic>.from(event.properties);
    final products = List<Map<String, dynamic>>.from(
      properties.remove('products') ?? [],
    );

    await CleverTapPlugin.recordChargedEvent(properties, products);
    
    if (enableDebugLogging) {
      print('CleverTap charged event: ${event.eventName}');
    }
  }

  Future<void> _trackEvent(TrackEvent event) async {
    await CleverTapPlugin.recordEvent(event.eventName, event.properties);
    
    if (enableDebugLogging) {
      print('CleverTap event: ${event.eventName}');
    }
  }

  @override
  Future<void> reset() async {
    await CleverTapPlugin.clearInAppResources(false);
    isFirstIdentification = true;
    
    if (enableDebugLogging) {
      print('CleverTap data cleared');
    }
  }

  bool _isValidData(dynamic value) {
    if (value == null) return false;
    if (value is String && value.trim().isEmpty) return false;
    return true;
  }
}
```

Then use your custom integration:

```dart
await iforevents.init(integrations: [
  const CustomClevertapIntegration(
    enableDebugLogging: true, // Enable for debugging
    sensitiveProperties: ['email', 'phone', 'ssn'],
  ),
]);
```

### Push Notification Integration

CleverTap supports push notifications. Here's how to set them up:

#### Android Push Setup

1. **Add Firebase to your project** and download `google-services.json`

2. **Configure FCM in CleverTap Dashboard**:
   - Go to Settings → Channels → Mobile Push → Android
   - Upload your FCM Server Key

3. **Handle push notifications in your app**:

```dart
import 'package:clevertap_plugin/clevertap_plugin.dart';

class PushNotificationHandler {
  static void initialize() {
    CleverTapPlugin.createNotificationChannel(
      "your_channel_id",
      "Channel Name", 
      "Channel Description",
      5,
      true
    );
    
    // Set up notification handlers
    CleverTapPlugin.setCleverTapPushNotificationClickedHandler(
      _onPushNotificationClicked
    );
  }
  
  static void _onPushNotificationClicked(Map<String, dynamic> message) {
    print("Push notification clicked: $message");
    // Handle notification click
  }
}
```

#### iOS Push Setup

1. **Enable Push Notifications** in Xcode:
   - Go to your target → Capabilities → Push Notifications → ON

2. **Upload APNs Certificate** to CleverTap Dashboard:
   - Go to Settings → Channels → Mobile Push → iOS
   - Upload your APNs certificate

## Best Practices

### 1. User Profile Properties
- Use CleverTap's special properties: `Email`, `Name`, `Phone`, `DOB`
- Keep profile properties consistent and updated
- Use appropriate data types for each property

### 2. Event Naming
- Use clear, consistent event names
- Follow CleverTap's event naming conventions
- Group related events with consistent prefixes

### 3. Revenue Tracking
- Always use "Order Completed" for revenue events
- Include product details in the `products` array
- Track both transaction-level and product-level data

### 4. Campaign Optimization
- Track events that can trigger campaigns
- Include relevant properties for segmentation
- Use consistent property names across events

## CleverTap Dashboard Features

### Real-time Analytics
1. Go to CleverTap Dashboard → Analytics
2. View real-time event streams
3. Monitor user activity and engagement

### User Segmentation
1. Create segments based on user properties and behavior
2. Use events and properties for targeting
3. Test different segment criteria

### Campaign Management
1. Create campaigns triggered by events
2. Use user properties for personalization
3. Track campaign performance and engagement

### Funnel Analysis
1. Create funnels using tracked events
2. Analyze conversion rates and drop-offs
3. Optimize user journeys based on data

## Troubleshooting

### Common Issues

1. **Events not appearing in CleverTap Dashboard**
   - Check Account ID and Token configuration
   - Verify native setup for Android/iOS
   - Events may take a few minutes to appear

2. **Push notifications not working**
   - Verify FCM/APNs configuration
   - Check certificate uploads in CleverTap dashboard
   - Test with CleverTap's push notification testing tools

3. **User profiles not updating**
   - Ensure proper user identification flow
   - Check property name mapping (Email, Name, Phone)
   - Verify data types and formats

### Debug Mode

Enable debug logging to troubleshoot:

```dart
await CleverTapPlugin.setDebugLevel(3); // Maximum debug level
```

## Creating Custom Integrations

You can extend the `Integration` class to create your own custom integrations:

```dart
import 'package:iforevents/iforevents.dart';

class CustomClevertapIntegration extends Integration {
  final String accountId;
  final String token;
  final String region;
  
  const CustomClevertapIntegration({
    required this.accountId,
    required this.token,
    required this.region,
  });

  @override
  Future<void> init() async {
    // IMPORTANT: Always call super.init() first due to @mustCallSuper
    await super.init();
    
    // Custom initialization logic
    CleverTapPlugin.initialize(
      accountId: accountId,
      token: token,
      region: region,
    );
    print('Custom CleverTap Integration initialized');
  }

  @override
  Future<void> identify({required IdentifyEvent event}) async {
    // IMPORTANT: Always call super.identify() first due to @mustCallSuper
    await super.identify(event: event);
    
    // Custom user profile setup
    final profile = <String, dynamic>{
      'Identity': event.customID,
      'Name': event.properties['name'],
      'Email': event.properties['email'],
      'Phone': event.properties['phone'],
      'custom_user_type': event.properties['user_type'] ?? 'standard',
    };
    
    // Remove null values
    profile.removeWhere((key, value) => value == null);
    
    await CleverTapPlugin.profileSet(profile);
    print('User profile set: ${event.customID}');
  }

  @override
  Future<void> track({required TrackEvent event}) async {
    // IMPORTANT: Always call super.track() first due to @mustCallSuper
    await super.track(event: event);
    
    // Custom event tracking with enhanced properties
    final enhancedProperties = <String, dynamic>{
      'timestamp': DateTime.now().toIso8601String(),
      'app_version': '1.0.0', // Add your app version
      ...event.properties,
    };
    
    // Handle special CleverTap events
    if (event.eventName == 'Charged') {
      await _handleChargedEvent(enhancedProperties);
    } else {
      await CleverTapPlugin.recordEvent(event.eventName, enhancedProperties);
    }
    
    print('Event tracked: ${event.eventName}');
  }

  Future<void> _handleChargedEvent(Map<String, dynamic> properties) async {
    // CleverTap requires specific structure for charged events
    final chargeDetails = <String, dynamic>{
      'Amount': properties['amount'] ?? 0,
      'Currency': properties['currency'] ?? 'USD',
      'Payment Mode': properties['payment_method'] ?? 'Unknown',
      'Charged ID': properties['transaction_id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
    };
    
    final items = properties['items'] as List<dynamic>? ?? [];
    
    await CleverTapPlugin.recordChargedEvent(chargeDetails, items);
  }

  @override
  Future<void> reset() async {
    // IMPORTANT: Always call super.reset() first due to @mustCallSuper
    await super.reset();
    
    // Custom reset logic
    await CleverTapPlugin.profileRemoveValueForKey('Identity');
    print('CleverTap profile reset');
  }

  @override
  Future<void> pageView({required PageViewEvent event}) async {
    // IMPORTANT: Always call super.pageView() first due to @mustCallSuper
    await super.pageView(event: event);
    
    // Custom page view tracking
    if (event.toRoute?.name != null) {
      await CleverTapPlugin.recordEvent('Page View', {
        'Page Name': event.toRoute!.name,
        'Navigation Type': event.navigationType.toString(),
        'Previous Page': event.previousRoute?.name ?? 'Unknown',
        'Timestamp': DateTime.now().toIso8601String(),
      });
      print('Page view tracked: ${event.toRoute!.name}');
    }
  }
}
```

## Package Dependencies

This package uses the following dependencies:

- [`clevertap_plugin`](https://pub.dev/packages/clevertap_plugin) ^3.5.0 - Official CleverTap SDK for Flutter
- [`iforevents`](https://pub.dev/packages/iforevents) - Core IforEvents package

## CleverTap Documentation

For more information about CleverTap:

- [CleverTap Documentation](https://docs.clevertap.com/)
- [CleverTap Flutter SDK](https://docs.clevertap.com/docs/flutter)
- [CleverTap Push Notifications](https://docs.clevertap.com/docs/flutter-push-notifications)

## Support

- 📧 Email: [support@innovafour.com](mailto:support@innovafour.com)
- 🐛 Issues: [GitHub Issues](https://github.com/innovafour/flutter_iforevents/issues)
- 📖 Documentation: [API Documentation](https://pub.dev/documentation/iforevents_clevertap/latest/)

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

Made with ❤️ by [Innovafour](https://innovafour.com)
