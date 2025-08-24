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
