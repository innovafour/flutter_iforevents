# IForEvents Firebase Integration

[![pub package](https://img.shields.io/pub/v/iforevents_firebase.svg)](https://pub.dev/packages/iforevents_firebase)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Firebase Analytics integration for IForEvents. This package provides seamless integration with Google Firebase Analytics, allowing you to track user events, identify users, and monitor app usage through Firebase's powerful analytics platform.

## Features

- 🔥 **Firebase Analytics Integration**: Full support for Firebase Analytics
- 📊 **Event Tracking**: Track custom events with properties
- 👤 **User Identification**: Set user IDs and custom user properties
- 🚀 **Automatic Setup**: Easy initialization with minimal configuration
- 📱 **Cross-platform**: Works on Android, iOS, and Web
- 🔄 **Reset Support**: Clear analytics data when needed

## Installation

### 1. Add Dependencies

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  iforevents: ^0.0.1
  iforevents_firebase: ^0.0.1
```

Then run:

```bash
flutter pub get
```

### 2. Firebase Setup

Follow the official Firebase setup guide for Flutter:

#### Android Setup

1. **Create a Firebase project** at [Firebase Console](https://console.firebase.google.com/)

2. **Add Android app to your Firebase project**:
   - Package name: Your app's package name (found in `android/app/build.gradle`)
   - App nickname: Optional
   - Debug signing certificate SHA-1: Optional (required for some features)

3. **Download `google-services.json`** and place it in `android/app/`

4. **Add Firebase SDK** to your Android app:

   In `android/build.gradle` (project-level):
   ```gradle
   buildscript {
       dependencies {
           // Add this line
           classpath 'com.google.gms:google-services:4.4.0'
       }
   }
   ```

   In `android/app/build.gradle`:
   ```gradle
   // Add this at the bottom of the file
   apply plugin: 'com.google.gms.google-services'
   ```

#### iOS Setup

1. **Add iOS app to your Firebase project**:
   - Bundle ID: Your app's bundle ID (found in `ios/Runner.xcodeproj`)
   - App nickname: Optional
   - App Store ID: Optional

2. **Download `GoogleService-Info.plist`** and add it to your Xcode project:
   - Open `ios/Runner.xcworkspace` in Xcode
   - Right-click on `Runner` and select "Add Files to Runner"
   - Select the downloaded `GoogleService-Info.plist`
   - Make sure it's added to the `Runner` target

#### Web Setup

1. **Add Web app to your Firebase project**
2. **Copy the Firebase configuration** and add it to `web/index.html`:

```html
<script type="module">
  import { initializeApp } from "https://www.gstatic.com/firebasejs/10.7.0/firebase-app.js";
  import { getAnalytics } from "https://www.gstatic.com/firebasejs/10.7.0/firebase-analytics.js";

  const firebaseConfig = {
    // Your Firebase config
    apiKey: "your-api-key",
    authDomain: "your-project.firebaseapp.com",
    projectId: "your-project-id",
    storageBucket: "your-project.appspot.com",
    messagingSenderId: "123456789",
    appId: "your-app-id",
    measurementId: "your-measurement-id"
  };

  const app = initializeApp(firebaseConfig);
  const analytics = getAnalytics(app);
</script>
```

### 3. Initialize Firebase in your app

Add this to your `main.dart`:

```dart
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp();
  
  runApp(MyApp());
}
```

## Usage

### Basic Setup

```dart
import 'package:iforevents/iforevents.dart';
import 'package:iforevents_firebase/iforevents_firebase.dart';

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
      const FirebaseIntegration(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase Analytics Demo',
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
    },
  ),
);

// Track ecommerce events
iforevents.track(
  event: TrackEvent(
    eventName: 'purchase',
    properties: {
      'currency': 'USD',
      'value': 29.99,
      'items': [
        {
          'item_id': 'prod_123',
          'item_name': 'Premium Plan',
          'category': 'subscription',
          'quantity': 1,
          'price': 29.99,
        }
      ],
    },
  ),
);
```

### Reset Analytics

```dart
// Clear all analytics data and reset user identification
await iforevents.reset();
```

## Creating Custom Integrations

You can extend the `Integration` class to create your own custom integrations:

```dart
import 'package:iforevents/iforevents.dart';

class CustomFirebaseIntegration extends Integration {
  const CustomFirebaseIntegration();

  @override
  Future<void> init() async {
    // IMPORTANT: Always call super.init() first due to @mustCallSuper
    await super.init();
    
    // Custom initialization logic
    await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
    print('Custom Firebase Integration initialized');
  }

  @override
  Future<void> identify({required IdentifyEvent event}) async {
    // IMPORTANT: Always call super.identify() first due to @mustCallSuper
    await super.identify(event: event);
    
    // Custom user identification logic
    await FirebaseAnalytics.instance.setUserId(id: event.customID);
    
    // Set user properties with custom logic
    for (final key in event.properties.keys) {
      final value = event.properties[key];
      if (value != null && value.toString().isNotEmpty) {
        await FirebaseAnalytics.instance.setUserProperty(
          name: key,
          value: value.toString(),
        );
      }
    }
    
    print('User identified: ${event.customID}');
  }

  @override
  Future<void> track({required TrackEvent event}) async {
    // IMPORTANT: Always call super.track() first due to @mustCallSuper
    await super.track(event: event);
    
    // Custom event tracking logic
    final filteredProperties = <String, String>{};
    
    for (final entry in event.properties.entries) {
      if (entry.value != null) {
        filteredProperties[entry.key] = entry.value.toString();
      }
    }

    await FirebaseAnalytics.instance.logEvent(
      name: event.eventName,
      parameters: filteredProperties,
    );
    
    print('Event tracked: ${event.eventName}');
  }

  @override
  Future<void> reset() async {
    // IMPORTANT: Always call super.reset() first due to @mustCallSuper
    await super.reset();
    
    // Custom reset logic
    await FirebaseAnalytics.instance.resetAnalyticsData();
    print('Firebase Analytics data reset');
  }

  @override
  Future<void> pageView({required PageViewEvent event}) async {
    // IMPORTANT: Always call super.pageView() first due to @mustCallSuper
    await super.pageView(event: event);
    
    // Custom page view tracking
    if (event.toRoute?.name != null) {
      await FirebaseAnalytics.instance.logScreenView(
        screenName: event.toRoute!.name,
        screenClass: event.toRoute!.name,
      );
      print('Page view tracked: ${event.toRoute!.name}');
    }
  }
}
```

Then use your custom integration:

```dart
await iforevents.init(integrations: [
  const CustomFirebaseIntegration(),
]);
```

## Package Dependencies

This package uses the following dependencies:

- [`firebase_analytics`](https://pub.dev/packages/firebase_analytics) ^12.0.0 - Official Firebase Analytics plugin for Flutter
- [`iforevents`](https://pub.dev/packages/iforevents) - Core IforEvents package

## Support

- 📧 Email: [support@innovafour.com](mailto:support@innovafour.com)
- 🐛 Issues: [GitHub Issues](https://github.com/innovafour/flutter_iforevents/issues)
- 📖 Documentation: [API Documentation](https://pub.dev/documentation/iforevents_firebase/latest/)

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

Made with ❤️ by [Innovafour](https://innovafour.com)
