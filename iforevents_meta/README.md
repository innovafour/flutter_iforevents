# IForEvents Meta (Facebook) Integration

[![pub package](https://img.shields.io/pub/v/iforevents_meta.svg)](https://pub.dev/packages/iforevents_meta)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Meta (Facebook) App Events integration for IForEvents. This package provides seamless integration with Facebook Analytics and Meta's advertising platform, enabling you to track user events, measure ad campaign effectiveness, and optimize your Facebook marketing efforts.

## Features

- 📱 **Facebook App Events Integration**: Full support for Meta's App Events
- 📊 **Event Tracking**: Track custom events and standard Facebook events
- 👤 **User Identification**: Set user data for improved ad targeting
- 💰 **Purchase Tracking**: Track revenue and conversions for ROI measurement  
- 🎯 **Ad Campaign Optimization**: Optimize Facebook ad campaigns with conversion data
- 📈 **Conversion API Support**: Enhanced tracking with iOS 14.5+ privacy features
- 🔄 **Standard Event Mapping**: Automatic mapping to Facebook standard events
- 📱 **Cross-platform**: Works on Android and iOS

## Installation

### 1. Add Dependencies

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  iforevents: ^0.0.4
  iforevents_meta: ^0.0.3
```

Then run:

```bash
flutter pub get
```

### 2. Facebook App Setup

1. **Create a Facebook App** at [developers.facebook.com](https://developers.facebook.com)
2. **Add your app to Facebook App Dashboard**
3. **Get your App ID** from App Settings → Basic

### 3. Native Configuration

Meta integration requires native configuration for both Android and iOS platforms.

#### Android Setup

1. **Add Facebook App ID to Android**:

   In `android/app/src/main/res/values/strings.xml`:
   ```xml
   <resources>
       <string name="facebook_app_id">YOUR_FACEBOOK_APP_ID</string>
       <string name="facebook_client_token">YOUR_FACEBOOK_CLIENT_TOKEN</string>
   </resources>
   ```

2. **Add Facebook configuration**:

   In `android/app/src/main/AndroidManifest.xml`:
   ```xml
   <application
       android:name="com.facebook.FacebookApplication">
       
       <!-- Facebook App ID -->
       <meta-data
           android:name="com.facebook.sdk.ApplicationId"
           android:value="@string/facebook_app_id" />
       
       <!-- Facebook Client Token -->
       <meta-data
           android:name="com.facebook.sdk.ClientToken"
           android:value="@string/facebook_client_token" />
       
       <!-- Facebook Auto App Events -->
       <meta-data
           android:name="com.facebook.sdk.AutoAppLinkEnabled"
           android:value="true" />
   </application>
   ```

3. **Add Internet Permission**:
   ```xml
   <uses-permission android:name="android.permission.INTERNET" />
   ```

4. **Add ProGuard Rules** (if using ProGuard):

   In `android/app/proguard-rules.pro`:
   ```
   -keep class com.facebook.** { *; }
   -keep class com.facebook.unity.** { *; }
   -keep class * extends com.facebook.appevents.AppEventsLogger { *; }
   ```

#### iOS Setup

1. **Add Facebook App ID to iOS**:

   In `ios/Runner/Info.plist`:
   ```xml
   <dict>
       <!-- Facebook App ID and Display Name -->
       <key>FacebookAppID</key>
       <string>YOUR_FACEBOOK_APP_ID</string>
       <key>FacebookDisplayName</key>
       <string>Your App Name</string>
       <key>FacebookClientToken</key>
       <string>YOUR_FACEBOOK_CLIENT_TOKEN</string>
       
       <!-- URL Schemes for Facebook Login (if using) -->
       <key>CFBundleURLTypes</key>
       <array>
           <dict>
               <key>CFBundleURLName</key>
               <string>fbauth</string>
               <key>CFBundleURLSchemes</key>
               <array>
                   <string>fbYOUR_FACEBOOK_APP_ID</string>
               </array>
           </dict>
       </array>
       
       <!-- Facebook Auto App Events -->
       <key>FacebookAutoLogAppEventsEnabled</key>
       <true/>
   </dict>
   ```

2. **Initialize Facebook SDK in AppDelegate**:

   In `ios/Runner/AppDelegate.swift`:
   ```swift
   import UIKit
   import Flutter
   import FBSDKCoreKit

   @UIApplicationMain
   @objc class AppDelegate: FlutterAppDelegate {
     override func application(
       _ application: UIApplication,
       didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
     ) -> Bool {
       
       // Initialize Facebook SDK
       ApplicationDelegate.shared.application(
         application,
         didFinishLaunchingWithOptions: launchOptions
       )
       
       GeneratedPluginRegistrant.register(with: self)
       return super.application(application, didFinishLaunchingWithOptions: launchOptions)
     }
     
     override func application(
       _ app: UIApplication,
       open url: URL,
       options: [UIApplication.OpenURLOptionsKey : Any] = [:]
     ) -> Bool {
       
       return ApplicationDelegate.shared.application(
         app,
         open: url,
         sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
         annotation: options[UIApplication.OpenURLOptionsKey.annotation]
       )
     }
   }
   ```

## Usage

### Basic Setup

```dart
import 'package:iforevents/iforevents.dart';
import 'package:iforevents_meta/iforevents_meta.dart';

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
      const MetaIntegration(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meta Analytics Demo',
      home: HomeScreen(iforevents: iforevents),
    );
  }
}
```

### User Identification

```dart
// Identify a user with Facebook user data parameters
await iforevents.identify(
  event: IdentifyEvent(
    customID: 'user_123',
    properties: {
      'email': 'user@example.com',      // Used for Facebook user matching
      'first_name': 'John',            // Facebook parameter
      'last_name': 'Doe',              // Facebook parameter
      'phone': '+1234567890',          // Used for Facebook user matching
      'age': 28,
      'location': 'New York',
      'user_segment': 'premium',
    },
  ),
);
```

### Event Tracking

```dart
// Track simple events (automatically mapped to Facebook standard events)
iforevents.track(
  event: TrackEvent(
    eventName: 'sign_up',  // Mapped to Facebook 'Lead' event
    properties: {
      'method': 'email',
      'source': 'homepage',
    },
  ),
);

// Track content views
iforevents.track(
  event: TrackEvent(
    eventName: 'view_item',  // Mapped to Facebook 'ViewContent' event
    properties: {
      'content_id': 'product_123',
      'content_type': 'product',
      'content_name': 'Flutter Course',
      'currency': 'USD',
      'value': 99.99,
    },
  ),
);

// Track add to cart
iforevents.track(
  event: TrackEvent(
    eventName: 'add_to_cart',  // Mapped to Facebook 'AddToCart' event
    properties: {
      'content_id': 'product_123',
      'content_type': 'product',
      'currency': 'USD',
      'value': 99.99,
      'quantity': 1,
    },
  ),
);

// Track searches
iforevents.track(
  event: TrackEvent(
    eventName: 'search',  // Mapped to Facebook 'Search' event
    properties: {
      'search_string': 'flutter tutorial',
      'content_category': 'education',
    },
  ),
);
```

### Purchase Tracking

Facebook has special handling for purchase events to track revenue and conversions:

```dart
// Track purchases (automatically uses Facebook's logPurchase method)
iforevents.track(
  event: TrackEvent(
    eventName: 'Order Completed', // Special event name for purchases
    properties: {
      'order_id': 'order_123',
      'total_amount': 149.98,      // Will be used as purchase amount
      'currency': 'USD',           // Will be used as purchase currency
      'payment_method': 'credit_card',
      'num_items': 2,
      'content_ids': ['prod_123', 'prod_456'],
      'content_type': 'product',
    },
  ),
);
```

### Standard E-commerce Events

```dart
// Initiate checkout
iforevents.track(
  event: TrackEvent(
    eventName: 'begin_checkout',  // Mapped to 'InitiateCheckout'
    properties: {
      'currency': 'USD',
      'value': 149.98,
      'content_ids': ['prod_123', 'prod_456'],
      'content_type': 'product',
      'num_items': 2,
    },
  ),
);

// Complete registration
iforevents.track(
  event: TrackEvent(
    eventName: 'sign_up',  // Mapped to 'Lead'
    properties: {
      'registration_method': 'email',
      'currency': 'USD',
      'value': 0, // Lead value
    },
  ),
);
```

### Reset User Data

```dart
// Clear Facebook user ID and user data
await iforevents.reset();
```

## Advanced Usage

### Custom Event Mapping

The Meta integration includes automatic mapping for common events:

```dart
// Built-in event mappings:
// 'home_view' → 'HomeView'
// 'login' → 'login'  
// 'register_address' → 'RegisterAddress'
// 'begin_checkout' → 'InitiateCheckout'
// 'purchase' → 'Purchase'
// 'add_to_cart' → 'AddToCart'
// 'sign_up' → 'Lead'
// 'search' → 'Search'
// 'view_item' → 'ViewContent'
```

### Creating Custom Meta Integration

You can extend the Meta integration for custom behavior:

```dart
import 'package:iforevents/iforevents.dart';
import 'package:facebook_app_events/facebook_app_events.dart';

class CustomMetaIntegration extends Integration {
  final bool enableAutoTracking;
  final bool enableLogging;
  final Map<String, String> customEventMappings;
  
  const CustomMetaIntegration({
    this.enableAutoTracking = true,
    this.enableLogging = false,
    this.customEventMappings = const {},
  });

  static final facebookAppEvents = FacebookAppEvents();

  @override
  Future<void> init() async {
    // Configure Facebook App Events
    await facebookAppEvents.setAutoLogAppEventsEnabled(enableAutoTracking);
    
    if (enableLogging) {
      print('Custom Meta Integration initialized');
      print('Auto tracking: $enableAutoTracking');
    }
  }

  @override
  Future<void> identify({required IdentifyEvent event}) async {
    await facebookAppEvents.setUserID(event.customID);
    
    // Set user data with validation
    await facebookAppEvents.setUserData(
      email: _validateEmail(event.properties['email']),
      firstName: event.properties['first_name']?.toString(),
      lastName: event.properties['last_name']?.toString(),
      phone: _validatePhone(event.properties['phone']),
      dateOfBirth: event.properties['date_of_birth']?.toString(),
      gender: event.properties['gender']?.toString(),
      city: event.properties['city']?.toString(),
      state: event.properties['state']?.toString(),
      country: event.properties['country']?.toString(),
      zip: event.properties['zip']?.toString(),
    );
    
    if (enableLogging) {
      print('Meta user identified: ${event.customID}');
    }
  }

  @override
  Future<void> track({required TrackEvent event}) async {
    final eventName = _mapEventName(event.eventName);
    
    // Filter out invalid properties (Lists are not supported)
    final filteredProperties = <String, dynamic>{};
    for (final entry in event.properties.entries) {
      if (entry.value is! List) {
        filteredProperties[entry.key] = entry.value;
      }
    }

    // Handle purchase events specially
    if (event.eventName == 'Order Completed') {
      await _trackPurchase(event, filteredProperties);
    } else {
      await facebookAppEvents.logEvent(
        name: eventName,
        parameters: filteredProperties,
      );
    }
    
    if (enableLogging) {
      print('Meta event tracked: ${event.eventName} → $eventName');
    }
  }

  Future<void> _trackPurchase(
    TrackEvent event,
    Map<String, dynamic> properties,
  ) async {
    final amount = (properties['total_amount'] ?? 0.0) as num;
    final currency = properties['currency']?.toString() ?? 'USD';

    await facebookAppEvents.logPurchase(
      amount: amount.toDouble(),
      currency: currency,
      parameters: properties,
    );
  }

  @override
  Future<void> reset() async {
    await facebookAppEvents.clearUserID();
    await facebookAppEvents.clearUserData();
    
    if (enableLogging) {
      print('Meta user data cleared');
    }
  }

  String _mapEventName(String eventName) {
    // Check custom mappings first
    if (customEventMappings.containsKey(eventName)) {
      return customEventMappings[eventName]!;
    }
    
    // Use built-in mappings
    const builtInMappings = {
      'home_view': 'HomeView',
      'login': 'login',
      'register_address': 'RegisterAddress',
      'begin_checkout': 'InitiateCheckout',
      'purchase': 'Purchase',
      'add_to_cart': 'AddToCart',
      'sign_up': 'Lead',
      'search': 'Search',
      'view_item': 'ViewContent',
    };
    
    return builtInMappings[eventName] ?? eventName;
  }

  String? _validateEmail(dynamic email) {
    if (email == null) return null;
    final emailStr = email.toString();
    return emailStr.contains('@') ? emailStr : null;
  }

  String? _validatePhone(dynamic phone) {
    if (phone == null) return null;
    final phoneStr = phone.toString();
    return phoneStr.replaceAll(RegExp(r'[^\d+]'), '');
  }
}
```

Then use your custom integration:

```dart
await iforevents.init(integrations: [
  const CustomMetaIntegration(
    enableAutoTracking: true,
    enableLogging: true, // Enable for debugging
    customEventMappings: {
      'custom_signup': 'Lead',
      'premium_upgrade': 'Subscribe',
    },
  ),
]);
```

### Facebook Conversion API

For improved tracking with iOS 14.5+ privacy features, consider implementing Facebook's Conversion API on your server side. The Meta integration provides the necessary client-side tracking that can be complemented with server-side events.

## Best Practices

### 1. User Data Collection
- Collect user data responsibly and with proper consent
- Use hashed email and phone for user matching
- Include first_name and last_name for better matching

### 2. Event Naming
- Use Facebook standard event names when possible
- Map custom events to standard Facebook events
- Be consistent with event naming across your app

### 3. Purchase Tracking
- Always track purchase events for ROI measurement
- Include currency and amount for accurate revenue tracking
- Use consistent currency codes (USD, EUR, etc.)

### 4. Content Parameters
- Include content_id, content_type for better optimization
- Use content_ids array for multiple items
- Include value parameter for optimization

### 5. Privacy Compliance
- Respect user privacy preferences
- Implement proper consent mechanisms
- Consider server-side tracking for enhanced privacy

## Facebook Dashboard Features

### Events Manager
1. Go to Facebook Events Manager
2. View real-time event data
3. Test events with Event Debugging

### Custom Conversions
1. Create custom conversions based on events
2. Use conversions for ad optimization
3. Track conversion values and counts

### Ad Campaign Optimization
1. Use tracked events as conversion objectives
2. Optimize campaigns for specific actions
3. Measure return on ad spend (ROAS)

### Audience Creation
1. Create custom audiences based on events
2. Build lookalike audiences from converters
3. Retarget users based on specific actions

## Troubleshooting

### Common Issues

1. **Events not appearing in Facebook Events Manager**
   - Check App ID configuration in native code
   - Verify internet connection
   - Events may take up to 20 minutes to appear

2. **User matching not working**
   - Ensure email and phone are properly formatted
   - Check that user data is set before tracking events
   - Verify user consent for data collection

3. **Purchase events not tracking revenue**
   - Use "Order Completed" as the event name
   - Include total_amount and currency properties
   - Check currency code format (3-letter ISO codes)

### Test Your Implementation

1. **Facebook Analytics Debugger**:
   - Use Facebook's App Events Testing tool
   - Verify events are being sent correctly
   - Check event parameters and user data

2. **Enable Debug Logging**:
   ```dart
   const CustomMetaIntegration(enableLogging: true);
   ```

## Creating Custom Integrations

You can extend the `Integration` class to create your own custom integrations:

```dart
import 'package:iforevents/iforevents.dart';
import 'package:facebook_app_events/facebook_app_events.dart';

class CustomMetaIntegration extends Integration {
  final bool enableLogging;
  final Map<String, String> eventMapping;
  
  const CustomMetaIntegration({
    this.enableLogging = false,
    this.eventMapping = const {},
  });

  @override
  Future<void> init() async {
    // IMPORTANT: Always call super.init() first due to @mustCallSuper
    await super.init();
    
    // Custom initialization logic
    await FacebookAppEvents.setAdvertiserTracking(enabled: true);
    
    if (enableLogging) {
      print('Custom Meta Integration initialized');
    }
  }

  @override
  Future<void> identify({required IdentifyEvent event}) async {
    // IMPORTANT: Always call super.identify() first due to @mustCallSuper
    await super.identify(event: event);
    
    // Custom user data setup with validation
    final userData = <String, String>{};
    
    // Validate and format email
    final email = event.properties['email']?.toString();
    if (email != null && _isValidEmail(email)) {
      userData['em'] = email.toLowerCase().trim();
    }
    
    // Validate and format phone number
    final phone = event.properties['phone']?.toString();
    if (phone != null && _isValidPhone(phone)) {
      userData['ph'] = _normalizePhoneNumber(phone);
    }
    
    // Add other user data
    final firstName = event.properties['first_name']?.toString();
    if (firstName != null && firstName.isNotEmpty) {
      userData['fn'] = firstName.toLowerCase().trim();
    }
    
    final lastName = event.properties['last_name']?.toString();
    if (lastName != null && lastName.isNotEmpty) {
      userData['ln'] = lastName.toLowerCase().trim();
    }
    
    if (userData.isNotEmpty) {
      await FacebookAppEvents.setUserData(userData);
    }
    
    if (enableLogging) {
      print('Meta user identified: ${event.customID}');
    }
  }

  @override
  Future<void> track({required TrackEvent event}) async {
    // IMPORTANT: Always call super.track() first due to @mustCallSuper
    await super.track(event: event);
    
    // Apply custom event mapping
    final mappedEventName = eventMapping[event.eventName] ?? _mapToStandardEvent(event.eventName);
    
    // Filter and prepare properties for Facebook
    final facebookProperties = <String, dynamic>{};
    
    for (final entry in event.properties.entries) {
      if (entry.value != null && _isValidFacebookProperty(entry.key, entry.value)) {
        facebookProperties[entry.key] = entry.value;
      }
    }
    
    // Add custom timestamp if not present
    if (!facebookProperties.containsKey('_eventTime')) {
      facebookProperties['_eventTime'] = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    }
    
    await FacebookAppEvents.logEvent(
      name: mappedEventName,
      parameters: facebookProperties,
    );
    
    if (enableLogging) {
      print('Meta event tracked: ${event.eventName} -> $mappedEventName');
    }
  }

  @override
  Future<void> reset() async {
    // IMPORTANT: Always call super.reset() first due to @mustCallSuper
    await super.reset();
    
    // Custom reset logic
    await FacebookAppEvents.clearUserData();
    
    if (enableLogging) {
      print('Meta user data cleared');
    }
  }

  @override
  Future<void> pageView({required PageViewEvent event}) async {
    // IMPORTANT: Always call super.pageView() first due to @mustCallSuper
    await super.pageView(event: event);
    
    // Custom page view tracking
    if (event.toRoute?.name != null) {
      await FacebookAppEvents.logEvent(
        name: 'ViewContent',
        parameters: {
          'content_type': 'page',
          'content_name': event.toRoute!.name,
          'navigation_type': event.navigationType.toString(),
          'previous_page': event.previousRoute?.name ?? 'unknown',
        },
      );
      
      if (enableLogging) {
        print('Meta page view tracked: ${event.toRoute!.name}');
      }
    }
  }

  String _mapToStandardEvent(String eventName) {
    const standardEvents = <String, String>{
      'purchase': 'Purchase',
      'add_to_cart': 'AddToCart',
      'view_content': 'ViewContent',
      'search': 'Search',
      'lead': 'Lead',
      'complete_registration': 'CompleteRegistration',
      'add_payment_info': 'AddPaymentInfo',
      'add_to_wishlist': 'AddToWishlist',
      'initiate_checkout': 'InitiateCheckout',
      'rate': 'Rate',
      'share': 'Share',
      'spend_credits': 'SpentCredits',
      'tutorial_complete': 'TutorialCompletion',
      'level_achieved': 'AchieveLevel',
      'unlock_achievement': 'UnlockAchievement',
    };
    
    return standardEvents[eventName.toLowerCase()] ?? eventName;
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  bool _isValidPhone(String phone) {
    final normalizedPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');
    return normalizedPhone.isNotEmpty && normalizedPhone.length >= 7;
  }

  String _normalizePhoneNumber(String phone) {
    return phone.replaceAll(RegExp(r'[^\d+]'), '');
  }

  bool _isValidFacebookProperty(String key, dynamic value) {
    // Facebook has restrictions on property names and values
    if (key.length > 40) return false;
    if (value.toString().length > 100) return false;
    
    // Reserved parameter names to avoid
    const reservedParams = {'_eventTime', '_eventTimeZone', '_userData'};
    if (reservedParams.contains(key)) return false;
    
    return true;
  }
}
```

## Package Dependencies

This package uses the following dependencies:

- [`facebook_app_events`](https://pub.dev/packages/facebook_app_events) ^0.20.1 - Official Facebook App Events SDK for Flutter
- [`iforevents`](https://pub.dev/packages/iforevents) - Core IforEvents package

## Facebook Documentation

For more information about Facebook App Events:

- [Facebook App Events Documentation](https://developers.facebook.com/docs/app-events)
- [Facebook Analytics for Apps](https://developers.facebook.com/docs/analytics)
- [Facebook Conversion API](https://developers.facebook.com/docs/marketing-api/conversions-api)

## Support

- 📧 Email: [support@innovafour.com](mailto:support@innovafour.com)
- 🐛 Issues: [GitHub Issues](https://github.com/innovafour/flutter_iforevents/issues)
- 📖 Documentation: [API Documentation](https://pub.dev/documentation/iforevents_meta/latest/)

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

Made with ❤️ by [Innovafour](https://innovafour.com)
