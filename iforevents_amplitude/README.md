# IForEvents Amplitude Integration

[![pub package](https://img.shields.io/pub/v/iforevents_amplitude.svg)](https://pub.dev/packages/iforevents_amplitude)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Amplitude analytics integration for IForEvents. This package provides seamless integration with Amplitude's powerful product analytics platform, enabling you to track user behavior, create behavioral cohorts, and understand user journeys.

## Features

- 🎯 **Amplitude Analytics Integration**: Full support for Amplitude event tracking
- 📊 **Event Tracking**: Track custom events with properties
- 👤 **User Profiles**: Create and update user properties with Identify API
- 💰 **Revenue Tracking**: Track revenue events with the Revenue API
- 👥 **Group Analytics**: Support for user groups and group identify
- 🔄 **Session Tracking**: Automatic session tracking
- 📱 **Cross-platform**: Works on Android, iOS, Web, Windows, macOS, and Linux
- 🌍 **EU Data Residency**: Support for EU data residency
- 📦 **Batching**: Configurable event batching for performance
- 🔒 **Privacy Controls**: COPPA compliance and opt-out support

## Installation

### 1. Add Dependencies

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  iforevents: ^0.0.4
  iforevents_amplitude: ^0.0.1
```

Then run:

```bash
flutter pub get
```

### 2. Get Amplitude API Key

1. **Create an Amplitude account** at [amplitude.com](https://amplitude.com)
2. **Create a new project** or use an existing one
3. **Find your API Key** in Settings → Projects → [Your Project] → General

### 3. Platform-Specific Setup

#### iOS Setup

Add the following to your `ios/Podfile`:

```ruby
platform :ios, '13.0'
```

Then run:

```bash
cd ios && pod install
```

#### macOS Setup

Add the following to your `macos/Podfile`:

```ruby
platform :osx, '10.15'
```

Ensure your app has the `com.apple.security.network.client` entitlement. Edit `macos/Runner/Release.entitlements` and `macos/Runner/DebugProfile.entitlements`:

```xml
<key>com.apple.security.network.client</key>
<true/>
```

Then run:

```bash
cd macos && pod install
```

#### Web Setup (Optional)

Add the Amplitude Browser SDK snippet to `web/index.html` inside the `<head>` tag:

```html
<script type="text/javascript">
!function(){"use strict";!function(e,t){var r=e.amplitude||{_q:[],_iq:{}};if(r.invoked)e.console&&console.error&&console.error("Amplitude snippet has been loaded.");else{var n=function(e,t){e.prototype[t]=function(){return this._q.push({name:t,args:Array.prototype.slice.call(arguments,0)}),this}},s=function(e,t,r){return function(n){e._q.push({name:t,args:Array.prototype.slice.call(r,0),resolve:n})}},o=function(e,t,r){e._q.push({name:t,args:Array.prototype.slice.call(r,0)})},i=function(e,t,r){e[t]=function(){if(r)return{promise:new Promise(s(e,t,Array.prototype.slice.call(arguments)))};o(e,t,Array.prototype.slice.call(arguments))}},a=function(e){for(var t=0;t<g.length;t++)i(e,g[t],!1);for(var r=0;r<m.length;r++)i(e,m[r],!0)};r.invoked=!0;var c=t.createElement("script");c.type="text/javascript",c.integrity="sha384-R0H1kXlk6r2aEQMtwVcPolpk0NAuIqM/8NlxAv24Gr3/PBJPl+9elu0bc3o/FDjR",c.crossOrigin="anonymous",c.async=!0,c.src="https://cdn.amplitude.com/libs/analytics-browser-2.11.10-min.js.gz",c.onload=function(){e.amplitude.runQueuedFunctions||console.log("[Amplitude] Error: could not load SDK")};var l=t.getElementsByTagName("script")[0];l.parentNode.insertBefore(c,l);for(var u=function(){return this._q=[],this},p=["add","append","clearAll","prepend","set","setOnce","unset","preInsert","postInsert","remove","getUserProperties"],d=0;d<p.length;d++)n(u,p[d]);r.Identify=u;for(var f=function(){return this._q=[],this},v=["getEventProperties","setProductId","setQuantity","setPrice","setRevenue","setRevenueType","setEventProperties"],y=0;y<v.length;y++)n(f,v[y]);r.Revenue=f;var g=["getDeviceId","setDeviceId","getSessionId","setSessionId","getUserId","setUserId","setOptOut","setTransport","reset","extendSession"],m=["init","add","remove","track","logEvent","identify","groupIdentify","setGroup","revenue","flush"];a(r),r.createInstance=function(e){return r._iq[e]={_q:[]},a(r._iq[e]),r._iq[e]},e.amplitude=r}}(window,document)}();
</script>
```

## Usage

### Basic Setup

```dart
import 'package:iforevents/iforevents.dart';
import 'package:iforevents_amplitude/iforevents_amplitude.dart';

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
      const AmplitudeIntegration(
        apiKey: 'YOUR_AMPLITUDE_API_KEY',
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Amplitude Analytics Demo',
      home: HomeScreen(iforevents: iforevents),
    );
  }
}
```

### Advanced Configuration

```dart
import 'package:amplitude_flutter/configuration.dart';
import 'package:amplitude_flutter/default_tracking.dart';

await iforevents.init(integrations: [
  const AmplitudeIntegration(
    apiKey: 'YOUR_AMPLITUDE_API_KEY',
    flushQueueSize: 30,
    flushIntervalMillis: 30000,
    optOut: false,
    minIdLength: 5,
    defaultTracking: DefaultTrackingOptions(),
    useBatch: false,
    serverZone: ServerZone.us,
  ),
]);
```

#### Configuration Options

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `apiKey` | String | Required | Your Amplitude project API key |
| `flushQueueSize` | int | 30 | Number of events to queue before sending |
| `flushIntervalMillis` | int | 30000 | Time in milliseconds between event uploads |
| `optOut` | bool | false | Opt the user out of tracking |
| `minIdLength` | int? | null | Minimum length for user ID or device ID |
| `defaultTracking` | DefaultTrackingOptions | DefaultTrackingOptions() | Default event tracking configuration |
| `useBatch` | bool | false | Use batch API endpoint |
| `serverZone` | ServerZone | ServerZone.us | Server zone (US or EU) |

### User Identification

```dart
await iforevents.identify(
  event: IdentifyEvent(
    customID: 'user_123',
    properties: {
      'email': 'user@example.com',
      'name': 'John Doe',
      'plan': 'premium',
      'signup_date': '2023-01-15',
      'age': 28,
      'location': 'San Francisco',
    },
  ),
);
```

### Event Tracking

```dart
iforevents.track(
  event: TrackEvent(
    eventName: 'button_clicked',
    properties: {
      'button_name': 'signup',
      'screen': 'home',
      'timestamp': DateTime.now().toIso8601String(),
    },
  ),
);

iforevents.track(
  event: TrackEvent(
    eventName: 'product_viewed',
    properties: {
      'product_id': 'prod_123',
      'product_name': 'Premium Plan',
      'price': 29.99,
      'currency': 'USD',
      'category': 'subscription',
    },
  ),
);
```

### Revenue Tracking

Amplitude provides a specialized Revenue API for tracking monetary events:

```dart
final amplitudeIntegration = AmplitudeIntegration.amplitude;

await amplitudeIntegration?.trackRevenue(
  price: 29.99,
  quantity: 1,
  productId: 'premium_monthly',
  revenueType: 'purchase',
);
```

Or track revenue through the standard track method:

```dart
iforevents.track(
  event: TrackEvent(
    eventName: 'purchase_completed',
    properties: {
      'revenue': 29.99,
      'product_id': 'premium_monthly',
      'quantity': 1,
      'price': 29.99,
      'revenue_type': 'purchase',
    },
  ),
);
```

### Group Analytics

Amplitude supports assigning users to groups for organizational analysis:

```dart
final amplitudeIntegration = AmplitudeIntegration.amplitude;

await amplitudeIntegration?.setGroup('company', 'acme_corp');

await amplitudeIntegration?.setGroup('role', ['admin', 'power_user']);
```

Event-level groups:

```dart
iforevents.track(
  event: TrackEvent(
    eventName: 'feature_used',
    properties: {
      'feature_name': 'export_data',
      'company': 'acme_corp',
      'role': 'admin',
    },
  ),
);
```

### Group Identify

Update group properties:

```dart
import 'package:amplitude_flutter/events/identify.dart' as amplitude_identify;

final amplitudeIntegration = AmplitudeIntegration.amplitude;
final identify = amplitude_identify.Identify()
  ..set('industry', 'technology')
  ..set('employee_count', 500)
  ..set('plan', 'enterprise');

await amplitudeIntegration?.groupIdentify('company', 'acme_corp', identify);
```

### Reset User Data

```dart
await iforevents.reset();
```

### Manual Flush

Force send all queued events immediately:

```dart
final amplitudeIntegration = AmplitudeIntegration.amplitude;
await amplitudeIntegration?.flush();
```

## Advanced Usage

### EU Data Residency

For GDPR compliance, you can configure Amplitude to use EU servers:

```dart
import 'package:amplitude_flutter/configuration.dart';

const AmplitudeIntegration(
  apiKey: 'YOUR_EU_API_KEY',
  serverZone: ServerZone.eu,
)
```

### Batch Configuration

For high-performance environments or poor network conditions:

```dart
const AmplitudeIntegration(
  apiKey: 'YOUR_API_KEY',
  flushQueueSize: 50,
  flushIntervalMillis: 60000,
  useBatch: true,
)
```

### Session Tracking

Amplitude automatically tracks sessions. You can configure session behavior:

```dart
import 'package:amplitude_flutter/default_tracking.dart';

const AmplitudeIntegration(
  apiKey: 'YOUR_API_KEY',
  defaultTracking: DefaultTrackingOptions(
    sessions: true,
    appLifecycles: false,
    deepLinks: false,
  ),
)
```

Session events tracked when `sessions: true`:
- Session start and end events are automatically tracked

### User Properties

Amplitude provides various operations for user properties:

```dart
await iforevents.identify(
  event: IdentifyEvent(
    customID: 'user_123',
    properties: {
      'plan': 'premium',
      'credits': 100,
      'interests': ['technology', 'design'],
      'last_login': DateTime.now().toIso8601String(),
    },
  ),
);
```

### Opt-Out Configuration

Respect user privacy by allowing opt-out:

```dart
const AmplitudeIntegration(
  apiKey: 'YOUR_API_KEY',
  optOut: true,
)
```

## Best Practices

### 1. Event Naming Convention
- Use clear, descriptive names in snake_case: `button_clicked`, `purchase_completed`
- Be consistent across your app
- Group related events with prefixes: `checkout_started`, `checkout_completed`

### 2. Property Guidelines
- Include context: `screen_name`, `feature_name`, `user_segment`
- Use consistent data types for the same property across events
- Avoid deeply nested objects
- Include timing when relevant: `time_spent`, `duration_seconds`

### 3. User Properties Best Practices
- Set user properties on identification
- Update properties when state changes
- Use meaningful property names
- Keep property values simple

### 4. Performance Optimization
- Use appropriate `flushQueueSize` and `flushIntervalMillis`
- Enable batching for high-volume scenarios
- Don't await track() calls unless necessary

### 5. Revenue Tracking
- Always include `product_id` and `revenue_type`
- Use consistent currency codes
- Track both successful and failed transactions
- Include relevant product metadata

## Amplitude Dashboard Features

### Real-time Event Stream
- View events as they occur
- Verify implementation
- Debug tracking issues

### User Lookup
- Search for specific users
- View user event history
- Inspect user properties

### Behavioral Cohorts
- Create cohorts based on user behavior
- Track cohort evolution over time
- Use cohorts in other analytics

### Funnel Analysis
- Build conversion funnels
- Identify drop-off points
- Optimize user flows

### Retention Analysis
- Track user retention over time
- Compare different cohorts
- Identify retention drivers

### Revenue Analytics
- Track revenue trends
- Analyze revenue by cohort
- LTV (Lifetime Value) analysis

## Troubleshooting

### Common Issues

1. **Events not appearing in Amplitude**
   - Check your API key
   - Verify internet connectivity
   - Wait a few minutes for events to process
   - Check the Amplitude status page

2. **Session tracking not working**
   - Ensure `trackingSessionEvents` is enabled
   - Verify app lifecycle handling
   - Check minimum session timeout

3. **User properties not updating**
   - Ensure you're calling `identify()` before tracking
   - Verify property names and types
   - Check for null or empty values

4. **Platform-specific issues**
   - **iOS**: Verify Podfile configuration and minimum version
   - **macOS**: Check entitlements for network access
   - **Web**: Ensure Browser SDK snippet is loaded

### Debug Mode

Monitor Amplitude events in development:

```dart
const AmplitudeIntegration(
  apiKey: 'YOUR_API_KEY',
)
```

Check Flutter logs for Amplitude SDK messages.

### Testing

Test your integration before production:

```dart
@override
void initState() {
  super.initState();
  _initializeAnalytics();
  _testTracking();
}

Future<void> _testTracking() async {
  await Future.delayed(Duration(seconds: 2));
  
  await iforevents.identify(
    event: IdentifyEvent(
      customID: 'test_user_${DateTime.now().millisecondsSinceEpoch}',
      properties: {'test': true},
    ),
  );
  
  iforevents.track(
    event: TrackEvent(
      eventName: 'test_event',
      properties: {'timestamp': DateTime.now().toIso8601String()},
    ),
  );
  
  await Future.delayed(Duration(seconds: 1));
  await AmplitudeIntegration.amplitude?.flush();
}
```

## Migration Guide

### From Amplitude SDK Direct Usage

If you're currently using Amplitude SDK directly:

**Before:**
```dart
import 'package:amplitude_flutter/amplitude.dart';

final amplitude = Amplitude(Configuration(apiKey: 'YOUR_API_KEY'));
await amplitude.isBuilt;
amplitude.track(BaseEvent(eventType: 'button_clicked'));
```

**After:**
```dart
import 'package:iforevents/iforevents.dart';
import 'package:iforevents_amplitude/iforevents_amplitude.dart';

final iforevents = const Iforevents();
await iforevents.init(integrations: [
  const AmplitudeIntegration(apiKey: 'YOUR_API_KEY'),
]);
iforevents.track(event: TrackEvent(eventName: 'button_clicked'));
```

## Package Dependencies

This package uses the following dependencies:

- [`amplitude_flutter`](https://pub.dev/packages/amplitude_flutter) ^4.2.0 - Official Amplitude SDK for Flutter
- [`iforevents`](https://pub.dev/packages/iforevents) - Core IForEvents package

## Amplitude Documentation

For more information about Amplitude:

- [Amplitude Documentation](https://amplitude.com/docs)
- [Amplitude Flutter SDK](https://amplitude.com/docs/sdks/analytics/flutter/flutter-sdk-4)
- [Amplitude HTTP API](https://amplitude.com/docs/apis/analytics/http-v2)
- [Amplitude Best Practices](https://amplitude.com/docs/data/sources/instrument-track-unique-users)

## Support

- 📧 Email: [support@innovafour.com](mailto:support@innovafour.com)
- 🐛 Issues: [GitHub Issues](https://github.com/innovafour/flutter_iforevents/issues)
- 📖 Documentation: [API Documentation](https://pub.dev/documentation/iforevents_amplitude/latest/)

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

Made with ❤️ by [Innovafour](https://innovafour.com)
