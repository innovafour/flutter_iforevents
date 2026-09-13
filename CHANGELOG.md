# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.2.0] - 2026-09-13

### Added

- Core: typed API errors (`IForeventsQuotaExceededException`,
  `IForeventsAuthException`, `IForeventsRateLimitedException`),
  `IForeventsAPIConfig.onQuotaExceeded`, `isQuotaExceeded`, `Retry-After`
  support on rate limits.

### Changed

- Core: events refused for an exhausted quota or a bad key are dropped instead
  of re-queued; transient failures still re-queue.
- All seven integration packages released as 0.2.0 pinning `iforevents: ^0.2.0`.

## [0.1.0]

All eight packages are released together at 0.1.0. The integration packages
previously pinned `iforevents: ^0.0.5`, which cannot resolve against this core —
they would have silently kept users on the old core and its credential model.

### Fixed
- **Events from identified users were recorded as anonymous.** The SDK sent the
  user id in `X-User-UUID`; the API reads `X-Custom-UUID`. On web the header was
  also absent from the CORS allowlist, so preflight failed and ingestion stopped
  entirely.
- **`identify` discarded the uuid the server returned**, writing it to storage
  but never to the in-memory field, so attribution only began after a restart.
- **Single-event tracking omitted `event_type`**, so with `batchSize: 1` the
  server filed every page view as an ordinary event.
- **CleverTap mutated the shared event map**, deleting `products` for every
  integration that ran after it, and threw when `products` was absent.
- **Meta crashed on a non-double `total_amount`** in `Order Completed`.
- **Page views never reached Firebase, Mixpanel, Meta, CleverTap or Amplitude.**
  None overrode `pageView`, and five did not accept `onPageView` at all.
- **Mixpanel stalled every `identify` for one second** on a `Future.delayed`.
- **`identify` propagated platform-plugin failures into the host app.**

### Removed (breaking)
- **`IForeventsAPIConfig.projectSecret` is gone.** The SDK no longer sends
  `X-Project-Secret`. A credential compiled into a mobile binary can be
  extracted with `strings`, so it was never actually secret, and the API now
  treats the project key as a public write-only credential. Reading analytics
  requires a dashboard session.

  Migration: delete the `projectSecret:` argument from your
  `IForeventsAPIConfig`. Nothing else changes. Rotate any project secret that
  shipped inside a released build.

### Changed (breaking)
- The public IP lookup is now **opt in**. Previously every session called
  `api.ipify.org`, disclosing the user's address to a third party. Set
  `collectPublicIP: true` to restore the old behaviour. The API records the
  request's source IP server-side either way.
- `iforevents_amplitude` replaces `defaultTracking` with `autocapture`, matching
  the upstream deprecation. The default is behaviourally identical.

### Added
- Pub workspace, so integration packages build against the core in this repo.
- CI analyzes, format-checks and dry-run-publishes all eight packages, and fails
  if an integration pins a stale core.
- `iforevents_segment` is published for the first time.
- `test/` suite covering the retry backoff, the pending-event queue round trip,
  the configuration object, and the bytes the API integration puts on the wire.
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
  iforevents: ^0.0.5
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
