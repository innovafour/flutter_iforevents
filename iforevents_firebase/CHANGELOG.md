## 0.0.1

**Initial Release** 🔥

This is the first release of IForEvents Firebase Integration, providing seamless Firebase Analytics integration for the IForEvents tracking platform.

### ✨ Features

* **Firebase Analytics Integration**: Full support for Firebase Analytics event tracking and user identification
* **User Identification**: Automatic user ID and user property setting in Firebase Analytics
* **Event Tracking**: Custom event logging with parameters and properties
* **Analytics Collection Control**: Enable/disable analytics collection as needed
* **Data Reset**: Complete analytics data reset functionality for user privacy
* **Auto-initialization**: Automatic Firebase Analytics setup with analytics collection enabled

### 🔌 Integration Capabilities

* **User Properties**: Set custom user properties for advanced user segmentation
* **Event Parameters**: Send custom event parameters with Firebase Analytics events
* **User ID Mapping**: Map IForEvents user IDs to Firebase Analytics user identification
* **Global Call Options**: Configure analytics calls with global options for consistent behavior

### 🚀 Key Components

* **FirebaseIntegration**: Main integration class extending IForEvents Integration base
* **User Management**: Complete user lifecycle management (identify, reset)
* **Event Handling**: Robust event tracking with property conversion and parameter mapping
* **Error Handling**: Graceful error handling that doesn't affect app performance

### 📱 Platform Support

* **Android**: Full Firebase Analytics support
* **iOS**: Complete iOS Firebase Analytics integration
* **Web**: Firebase Analytics web support

### 🔧 Usage

```dart
import 'package:iforevents_firebase/iforevents_firebase.dart';

// Add Firebase integration to IForEvents
final firebaseIntegration = FirebaseIntegration();
```

### 📦 Dependencies

* Firebase Analytics 12.0.0+
* IForEvents 0.0.1+
* Flutter SDK 3.8.1+

This integration provides a robust foundation for Firebase Analytics tracking within the IForEvents ecosystem, enabling comprehensive user behavior analysis and app performance insights.
