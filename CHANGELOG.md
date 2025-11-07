# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Initial open-source release preparation
- Comprehensive documentation and examples

## [0.0.1] - 2025-08-21

### Added
- Initial release of IforEvents package
- Core analytics functionality with multi-platform support
- Device information collection for Android, iOS, and Windows
- Automatic IP address detection
- User identification with custom data
- Event tracking with custom properties
- Screen/route navigation tracking
- Integration support for multiple analytics platforms

### Features
- **Cross-platform Device Detection**: Automatic collection of device information including:
  - Device brand, model, and OS version
  - Unique device identifiers
  - App version and build information
  - Physical device detection
  - IP address (both local and public)

- **Event Tracking System**:
  - Simple event tracking with custom properties
  - Different event types (track, screen, identify)
  - Automatic device data inclusion
  - Timestamp and user tracking

- **User Identification**:
  - Unique user identification across platforms
  - Custom user properties and data
  - Automatic device data enrichment
  - User data persistence and management

- **Navigation Tracking**:
  - Automatic screen/route tracking
  - Navigator observer for Flutter apps
  - Route transition tracking
  - Custom screen event properties

- **Integration Architecture**:
  - Modular integration system
  - Support for multiple analytics platforms simultaneously
  - Easy integration addition and removal
  - Consistent API across all integrations

### Integrations
- **Firebase Analytics Integration** (`iforevents_firebase`)
  - User identification with Firebase
  - Event tracking with custom parameters
  - Analytics collection management
  - User property setting

- **Mixpanel Integration** (`iforevents_mixpanel`)
  - User identification and aliasing
  - Event tracking with properties
  - User profile management
  - Data persistence and flushing

- **Algolia Integration** (`iforevents_algolia`)
  - Search analytics tracking
  - Query and result tracking
  - User behavior analysis

### Developer Experience
- **Comprehensive Example App**: Full-featured example demonstrating all features
- **Documentation**: Complete API documentation and usage guides
- **Type Safety**: Full Dart type safety with proper error handling
- **Testing Support**: Unit tests and integration testing examples

### Platform Support
- **Android**: Full support with Android ID and device information
- **iOS**: Complete iOS support with identifier for vendor
- **Windows**: Windows platform support with device identification
- **Web**: Partial support (where applicable)

### Dependencies
- `flutter`: Flutter framework support
- `equatable`: Object equality and comparison
- `android_id`: Android device identification
- `dart_ipify`: IP address detection
- `device_info_plus`: Cross-platform device information
- `package_info_plus`: App package and version information
- `dio`: HTTP client for network requests

### Technical Details
- **Minimum Dart SDK**: 3.8.1
- **Minimum Flutter**: 1.17.0
- **License**: MIT License
- **Repository**: https://github.com/innovafour/flutter_iforevents

### Breaking Changes
- None (initial release)

### Deprecated
- None (initial release)

### Removed
- None (initial release)

### Fixed
- None (initial release)

### Security
- Secure device identification without exposing sensitive information
- Safe IP address detection with fallback mechanisms
- Privacy-conscious data collection

---

## Release Notes

### Version 0.0.1 - Initial Release

This is the first public release of IforEvents, a comprehensive Flutter package for event tracking and analytics integration. The package provides a unified interface for multiple analytics platforms while automatically collecting device information and user data.

**Key Highlights:**
- 🚀 **Multi-platform Support**: Works seamlessly on Android, iOS, and Windows
- 📊 **Multiple Analytics Integrations**: Firebase, Mixpanel, and Algolia support
- 🔍 **Automatic Data Collection**: Device info, IP address, and app details
- 🎯 **Simple API**: Easy-to-use interface for all analytics needs
- 📱 **Navigation Tracking**: Automatic screen and route tracking
- 🏗️ **Modular Design**: Add only the integrations you need

**Getting Started:**
```yaml
dependencies:
  iforevents: ^0.0.4
  iforevents_firebase: ^0.0.3  # Optional
  iforevents_mixpanel: ^0.0.3  # Optional
```

**Quick Example:**
```dart
final iforevents = Iforevents();

await iforevents.init(integrations: [
  const FirebaseIntegration(),
  const MixpanelIntegration(key: 'YOUR_KEY'),
]);

await iforevents.identify(
  id: 'user123',
  data: {'email': 'user@example.com'},
);

iforevents.track(
  eventName: 'button_clicked',
  properties: {'button_name': 'signup'},
);
```

For detailed documentation and examples, visit our [GitHub repository](https://github.com/innovafour/flutter_iforevents).

---

*For more information about releases and updates, follow our [GitHub repository](https://github.com/innovafour/flutter_iforevents) or check [pub.dev](https://pub.dev/packages/iforevents).*
