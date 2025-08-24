## 0.0.3

**Multi-Platform Support** 🌐

### ✨ Improvements

* **Complete Platform Coverage**: Added support for Web, macOS, Linux, and Windows platforms
* **Enhanced Compatibility**: Updated to work with IForEvents 0.0.2 multi-platform support

---

## 0.0.1

**Initial Release** 📈

This is the first release of IForEvents CleverTap Integration, providing comprehensive customer engagement and analytics integration through CleverTap platform.

### ✨ Features

* **CleverTap Integration**: Full support for CleverTap customer engagement and analytics platform
* **User Profile Management**: Comprehensive user login and profile management
* **Event Tracking**: Custom event recording with properties and parameters
* **User Login Flow**: Smart user login detection and profile updates
* **Charged Events**: Special handling for purchase and revenue events
* **Profile Properties**: Automatic profile property management and updates
* **In-App Resource Management**: Control over in-app resources and notifications

### 🔌 Integration Capabilities

* **User Authentication**: Handle user login and registration flows
* **Profile Updates**: Real-time user profile property updates
* **Event Recording**: Record custom events with detailed properties
* **Revenue Tracking**: Special charged event handling for e-commerce tracking
* **Property Normalization**: Automatic property name formatting for CleverTap standards
* **Session Management**: User session tracking and management

### 🎯 Special Features

* **First-Time User Detection**: Automatic detection and handling of new vs. returning users
* **Order Completion Tracking**: Special handling for e-commerce order completion events
* **Property Capitalization**: Automatic capitalization of standard properties (email, name, phone)
* **Profile vs Login Events**: Intelligent switching between profile updates and login events

### 🚀 Key Components

* **ClevertapIntegration**: Main integration class with CleverTap plugin configuration
* **User State Management**: Track first-time vs. returning user states
* **Event Handlers**: Specialized handlers for different event types
* **Property Formatters**: Automatic property formatting for CleverTap compatibility

### 📱 Platform Support

* **Android**: Full CleverTap SDK support
* **iOS**: Complete iOS CleverTap integration
* **Cross-platform**: Unified API across all supported platforms

### 🔧 Usage

```dart
import 'package:iforevents_clevertap/iforevents_clevertap.dart';

// Add CleverTap integration to IForEvents
final clevertapIntegration = ClevertapIntegration();
```

### 📦 Dependencies

* CleverTap Plugin 3.5.0+
* IForEvents 0.0.1+
* Flutter SDK 3.8.1+

This integration provides powerful customer engagement capabilities through CleverTap's comprehensive platform, enabling advanced user segmentation, personalized messaging, and detailed analytics for improved user retention and engagement.
