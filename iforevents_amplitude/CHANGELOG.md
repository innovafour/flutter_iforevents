## 0.1.0

### 💥 Breaking

* **Requires `iforevents` ^0.1.0.** The previous `^0.0.5` constraint could not
  resolve against the current core, so this package silently held users back on
  the old core that still carried a project secret. Upgrade both together.

### 💥 Also breaking

* **`defaultTracking` is replaced by `autocapture`.** `DefaultTrackingOptions` is
  deprecated upstream in `amplitude_flutter`. The new default,
  `const AutocaptureOptions()`, resolves to exactly what the old default
  produced, so behaviour is unchanged unless you set the field explicitly.

  Migration: `defaultTracking: DefaultTrackingOptions(...)` becomes
  `autocapture: AutocaptureOptions(...)`.

### 🐛 Fixes

* **Screen views now reach Amplitude.** `onPageView` was accepted but `pageView`
  was never overridden, so route changes were dropped.

## 0.0.1

* Initial release of IForEvents Amplitude integration
* Full support for Amplitude Flutter SDK 4.x
* Event tracking with custom properties
* User identification with Identify API
* Revenue tracking support
* Group analytics support
* Session tracking
* EU data residency support
* Configurable batching behavior
* Cross-platform support (Android, iOS, Web, Windows, macOS, Linux)
* COPPA compliance and privacy controls
