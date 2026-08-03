## 0.1.0

### 💥 Breaking

* **`IForeventsAPIConfig.projectSecret` is gone.** The SDK no longer sends
  `X-Project-Secret`. A credential compiled into a mobile binary can be
  extracted with `strings`, so it was never actually secret; the API treats the
  project key as a public write-only credential. Reading analytics requires a
  dashboard session.

  Migration: delete the `projectSecret:` argument from your
  `IForeventsAPIConfig`. Rotate any project secret that shipped inside a
  released build.

* **The public IP lookup is opt in.** Every session used to call `api.ipify.org`,
  disclosing the user's address to a third party. Set `collectPublicIP: true` to
  restore it. The API records the request's source IP server-side either way.

### 🐛 Fixes

* **Events from identified users are no longer recorded as anonymous.** The SDK
  sent the user id in `X-User-UUID`; the API reads `X-Custom-UUID`. Nothing
  errored — every event was simply filed without a user. On web it was worse:
  `X-User-UUID` is not on the API's CORS allowlist, so the preflight failed and
  ingestion stopped entirely.

* **`identify` now keeps the uuid the server returns.** The response uuid was
  written to local storage but never assigned to the in-memory field, so user
  attribution only began working after the next app launch.

* **Single-event tracking sends `event_type`.** With `batchSize: 1` the type was
  omitted and the server defaulted every event to `track`, making page views
  indistinguishable from ordinary events. The batch path already sent it.

* **`identify` no longer propagates plugin failures to the host app.** Device
  probing goes through platform plugins; a missing one threw straight into the
  caller's login flow. `track`, `reset` and `pageViewed` already swallowed.

### 🧹 Housekeeping

* The repository is a pub workspace, so the integration packages compile against
  the core in this repo rather than the last release on pub.dev. CI analyzes,
  formats and dry-run-publishes all eight packages.
* Tests cover the retry backoff, the pending-event queue round trip, the
  configuration object, and the bytes the API integration puts on the wire.

## 0.0.5

**Amplitude Integration** 📊

### ✨ New Features

* **Amplitude Analytics**: Added official Amplitude analytics integration support
* **New Package**: Introduced `iforevents_amplitude` package for Amplitude integration
* **Unified API**: Consistent event tracking interface across all analytics platforms

### 🔧 Technical Improvements

* Enhanced integration factory to support Amplitude
* Added comprehensive Amplitude documentation and examples
* Improved modular architecture for third-party integrations

### 📦 New Packages

* `iforevents_amplitude`: Official Amplitude analytics integration

---

## 0.0.3

**Multi-Platform Support** 🌐

### ✨ New Features

* **Complete Platform Coverage**: Added support for Web, macOS, and Linux platforms
* **Enhanced Device Detection**: Improved device information collection across all platforms
* **Universal Device ID**: Added UUID fallback for platforms without native device IDs
* **Cross-Platform Compatibility**: Package now works on all Flutter-supported platforms

### 🔧 Technical Improvements

* Added `uuid` dependency for universal device ID generation
* Enhanced `deviceData` method with platform-specific information collection
* Added explicit platform declarations in `pubspec.yaml`
* Improved error handling for unsupported platform scenarios

### 📱 Platform Support

* **Web**: Browser detection and web-specific device information
* **macOS**: System GUID and macOS device details
* **Linux**: Machine ID and Linux distribution information
* **Android/iOS/Windows**: Enhanced existing platform support

### 🛠 Breaking Changes

None - maintains full backward compatibility.

---

## 0.0.1

**Initial Release** 🎉

This is the first release of IForEvents, a comprehensive Flutter package for event tracking and analytics integration.

### ✨ Core Features

* **Multi-platform Analytics Support**: Unified interface for multiple analytics platforms
* **Cross-platform Compatibility**: Works seamlessly on Android, iOS, and Windows
* **Automatic Device Information Collection**: Comprehensive device data collection including device ID, brand, model, OS version, and app version
* **Automatic IP Detection**: Both public and device IP address detection
* **User Identification**: Link events to specific users with custom properties
* **Event Tracking**: Track custom events with flexible properties
* **Route/Screen Tracking**: Monitor user navigation patterns
* **Modular Architecture**: Add only the integrations you need

### 🔌 Official Integrations

* **IForEvents API Integration**: Native backend integration with offline queuing, batching, and automatic retries
* **Firebase Analytics**: Google Firebase Analytics support
* **Mixpanel**: Mixpanel analytics integration
* **Algolia**: Search analytics integration
* **Meta (Facebook Pixel)**: Facebook marketing analytics
* **CleverTap**: Customer engagement and analytics platform

### 🚀 Advanced Capabilities

* **Offline Event Queue**: Robust event storage and retry mechanism for failed requests
* **Background Processing**: Automatic background event processing with configurable intervals
* **Batch Operations**: Efficient event batching to reduce network overhead
* **Configurable Retry Logic**: Customizable retry intervals and strategies
* **High Performance**: HTTP/2 support with Dio for optimal network performance
* **Comprehensive Logging**: Detailed logging for debugging and monitoring

### 🛠 Developer Experience

* **Navigator Observer**: Automatic route tracking with `IforeventsRouteObserver`
* **Custom Integration Support**: Easy-to-extend architecture for adding new analytics platforms
* **Type-safe API**: Strongly typed events and configurations
* **Error Handling**: Graceful error handling that doesn't crash your app
* **Privacy Focused**: Configurable data collection with privacy considerations

### 📱 Platform Support

* **Android**: Full support with Android ID collection and device information
* **iOS**: Complete iOS integration with Identifier for Vendor
* **Windows**: Native Windows support with device identification

### 🎯 Key Components

* **Event Types**: Support for track, identify, and page view events
* **Device Detection**: Automatic device information collection across platforms
* **Storage Service**: Local event storage with SQLite backend
* **Configuration Management**: Flexible configuration options with presets
* **Integration Factory**: Centralized integration management system

### 📦 Dependencies

* Flutter SDK 3.8.1+
* Dart 3.0+
* Core dependencies: `equatable`, `device_info_plus`, `package_info_plus`, `dio`, `get_storage`

### 🔧 Example Usage

The package includes a comprehensive example application demonstrating:
* Multi-integration setup
* User identification workflows
* Event tracking examples
* Navigation tracking implementation
* IForEvents API integration usage

This initial release provides a solid foundation for analytics tracking in Flutter applications with support for multiple platforms and analytics providers.
