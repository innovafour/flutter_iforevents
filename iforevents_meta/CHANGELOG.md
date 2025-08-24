## 0.0.3

**Multi-Platform Support** 🌐

### ✨ Improvements

* **Complete Platform Coverage**: Added support for Web, macOS, Linux, and Windows platforms
* **Enhanced Compatibility**: Updated to work with IForEvents 0.0.3 multi-platform support

---

## 0.0.1

**Initial Release** 📘

This is the first release of IForEvents Meta Integration, providing comprehensive Facebook Analytics and Marketing integration for the IForEvents tracking platform.

### ✨ Features

* **Facebook App Events Integration**: Full support for Facebook Analytics and marketing pixel tracking
* **User Data Management**: Comprehensive user identification and data collection
* **Purchase Tracking**: Advanced e-commerce and revenue tracking capabilities
* **Event Mapping**: Intelligent event name mapping for Facebook standard events
* **Custom Events**: Support for custom events with flexible properties
* **User Privacy**: Complete user data reset and privacy management
* **Marketing Analytics**: Deep integration with Facebook's marketing and advertising platforms

### 🔌 Integration Capabilities

* **User Identification**: Set user ID and detailed user data for Facebook Analytics
* **Personal Data Tracking**: Manage email, name, phone, and other user attributes
* **Purchase Events**: Special handling for purchase events with amount and currency
* **Standard Events**: Automatic mapping to Facebook standard events for better insights
* **Custom Parameters**: Flexible parameter handling for all event types
* **Data Privacy**: Complete user data clearing and reset functionality

### 🎯 Supported Events

* **E-commerce Events**: Purchase, AddToCart, InitiateCheckout, ViewContent
* **User Actions**: Login, Lead generation, Search, Home views
* **Custom Events**: Any custom event with flexible property support
* **Revenue Tracking**: Purchase events with amount and currency support

### 🚀 Key Components

* **MetaIntegration**: Main integration class with Facebook App Events configuration
* **Event Mapping**: Smart mapping of common events to Facebook standard events
* **User Data Manager**: Comprehensive user data management and privacy controls
* **Purchase Handler**: Specialized purchase event handling with revenue tracking

### 📱 Platform Support

* **Android**: Full Facebook App Events support
* **iOS**: Complete iOS Facebook Analytics integration
* **Cross-platform**: Unified API across all supported platforms

### 🔧 Usage

```dart
import 'package:iforevents_meta/iforevents_meta.dart';

// Add Meta integration to IForEvents
final metaIntegration = MetaIntegration();
```

### 📦 Dependencies

* Facebook App Events 0.20.1+
* IForEvents 0.0.1+
* Flutter SDK 3.8.1+

This integration enables powerful marketing analytics and user behavior insights through Facebook's comprehensive analytics platform, helping optimize advertising campaigns and understand user engagement across the Facebook ecosystem.
