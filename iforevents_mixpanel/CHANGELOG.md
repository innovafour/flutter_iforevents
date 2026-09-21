## 0.2.0

* **Requires `iforevents` ^0.2.0.** Picks up the typed API errors and the
  quota-aware queue of the core; no changes to this integration's own API.

## 0.1.0

### 💥 Breaking

* **Requires `iforevents` ^0.1.0.** The previous `^0.0.5` constraint could not
  resolve against the current core, so this package silently held users back on
  the old core that still carried a project secret. Upgrade both together.

### 🐛 Fixes

* **Screen views now reach Mixpanel.** `pageView` was never overridden, so route
  changes were dropped.
* **Removed a hardcoded 1 second delay from `identify`.** Every login stalled for
  a full second waiting on a `Future.delayed` that guarded nothing; the
  following `flush()` already does the work.
* `onPageView` is accepted by the constructor and forwarded to the caller.

## 0.0.3

**Multi-Platform Support** 🌐

### ✨ Improvements

* **Complete Platform Coverage**: Added support for Web, macOS, Linux, and Windows platforms
* **Enhanced Compatibility**: Updated to work with IForEvents 0.0.3 multi-platform support

---

## 0.0.1

**Initial Release** 🎛️

This is the first release of IForEvents Mixpanel Integration, providing comprehensive user analytics and behavioral tracking through the Mixpanel platform.

### ✨ Features

* **Mixpanel Analytics Integration**: Full support for Mixpanel's advanced analytics platform
* **User Identity Management**: Comprehensive user identification, aliasing, and profile management
* **Event Tracking**: Custom event tracking with detailed properties and parameters
* **User Profiles**: Advanced user profile management with property setting and updates
* **Data Flushing**: Controlled data flushing and synchronization with Mixpanel servers
* **Privacy Controls**: Complete user data reset and privacy management
* **Automatic Events Disabled**: Clean integration without automatic event noise

### 🔌 Integration Capabilities

* **User Aliasing**: Smart user aliasing to connect anonymous and identified users
* **Profile Management**: Comprehensive user profile property management
* **Property Handling**: Intelligent property filtering and data cleaning
* **Distinct ID Management**: Robust distinct ID handling and user user management
* **Data Validation**: Automatic data validation and cleaning for reliable analytics
* **Batch Processing**: Efficient event batching and flushing for optimal performance

### 🎯 Advanced Features

* **Property Unset/Set**: Dynamic property management with unset and set operations
* **Data Cleaning**: Automatic removal of empty and unknown values
* **User Deletion**: Complete user profile deletion for privacy compliance
* **Super Properties**: Management of super properties for consistent tracking
* **Delayed Flushing**: Strategic data flushing with timing controls

### 🚀 Key Components

* **MixpanelIntegration**: Main integration class with Mixpanel SDK configuration
* **People Management**: Advanced user profile and people analytics
* **Event Handler**: Robust event tracking with property validation
* **Identity Manager**: Comprehensive user identity and aliasing management

### 📱 Platform Support

* **Android**: Full Mixpanel SDK support
* **iOS**: Complete iOS Mixpanel integration
* **Cross-platform**: Unified API across all supported platforms

### 🔧 Usage

```dart
import 'package:iforevents_mixpanel/iforevents_mixpanel.dart';

// Add Mixpanel integration to IForEvents
final mixpanelIntegration = MixpanelIntegration(
  token: 'YOUR_MIXPANEL_TOKEN',
);
```

### 📦 Dependencies

* Mixpanel Flutter 2.4.4+
* IForEvents 0.0.1+
* Flutter SDK 3.8.1+

This integration provides powerful user analytics and behavioral insights through Mixpanel's comprehensive platform, enabling advanced user segmentation, funnel analysis, and retention tracking for data-driven product decisions.
