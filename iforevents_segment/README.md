# IForEvents Segment

Segment analytics integration for IForEvents - A powerful customer data platform for unified data collection and routing to multiple destinations.

## Features

- **User Identification**: Track and identify users with custom traits
- **Event Tracking**: Track custom events with properties
- **Screen/Page Tracking**: Track page views and screen navigation
- **Group Analytics**: Associate users with groups or organizations
- **User Aliasing**: Connect anonymous users to identified users
- **Reset Functionality**: Clear user data on logout
- **Automatic Event Tracking**: Optional tracking of application lifecycle events
- **Deep Link Tracking**: Optional tracking of deep link navigation
- **Debug Mode**: Enable detailed logging for development

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  iforevents_segment: ^0.0.1
```

## Usage

### Basic Setup

```dart
import 'package:iforevents/iforevents.dart';
import 'package:iforevents_segment/iforevents_segment.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await IForEvents.init(
    integrations: [
      SegmentIntegration(
        writeKey: 'YOUR_SEGMENT_WRITE_KEY',
        debug: true, // Enable in development
      ),
    ],
  );
  
  runApp(MyApp());
}
```

### Advanced Configuration

```dart
const segmentIntegration = SegmentIntegration(
  writeKey: 'YOUR_SEGMENT_WRITE_KEY',
  debug: false,
  onInit: () => print('Segment initialized'),
  onIdentify: (event) => print('User identified: ${event.customID}'),
  onTrack: (event) => print('Event tracked: ${event.eventName}'),
  onPageView: (event) => print('Page viewed: ${event.name}'),
  onReset: () => print('Segment reset'),
);
```

### Identify Users

```dart
IForEvents.identify(
  customID: 'user_123',
  properties: {
    'email': 'user@example.com',
    'name': 'John Doe',
    'plan': 'premium',
    'signup_date': '2024-01-01',
  },
);
```

### Track Events

```dart
IForEvents.track(
  eventName: 'Product Purchased',
  properties: {
    'product_id': 'prod_123',
    'product_name': 'Premium Plan',
    'price': 29.99,
    'currency': 'USD',
  },
);
```

### Track Page Views

```dart
IForEvents.pageView(
  name: 'Home Screen',
  properties: {
    'category': 'main',
    'path': '/home',
  },
);
```

### Group Users

```dart
final integration = IForEvents.getIntegration<SegmentIntegration>();
await integration?.group(
  groupId: 'company_123',
  traits: {
    'name': 'Acme Corporation',
    'plan': 'enterprise',
    'employees': 500,
  },
);
```

### Alias Users

```dart
final integration = IForEvents.getIntegration<SegmentIntegration>();
await integration?.alias(alias: 'user_123');
```

### Reset on Logout

```dart
IForEvents.reset();
```

### Manual Flush

```dart
final integration = IForEvents.getIntegration<SegmentIntegration>();
await integration?.flush();
```

## Configuration Options

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `writeKey` | String | required | Your Segment write key from the Segment dashboard |
| `debug` | bool | false | Enable debug logging |
| `onInit` | Function? | null | Callback when integration initializes |
| `onIdentify` | Function? | null | Callback when user is identified |
| `onTrack` | Function? | null | Callback when event is tracked |
| `onPageView` | Function? | null | Callback when page view is tracked |
| `onReset` | Function? | null | Callback when reset is called |

## Best Practices

1. **User Identification**: Always identify users after login to connect their actions
2. **Event Naming**: Use clear, consistent event names (e.g., "Product Purchased" not "purchase")
3. **Properties**: Include relevant context in event properties for better insights
4. **Reset on Logout**: Call `IForEvents.reset()` when users log out to clear data
5. **Production Keys**: Use different write keys for development and production
6. **Flush Strategically**: Manually flush before critical moments (e.g., before app termination)

## Segment Destinations

Segment acts as a customer data platform that can route your events to 300+ destinations including:
- Google Analytics
- Mixpanel
- Amplitude
- Firebase
- Facebook Pixel
- And many more...

Configure your destinations in the Segment dashboard without changing your code.

## Learn More

- [Segment Documentation](https://segment.com/docs/)
- [segment_analytics Package](https://pub.dev/packages/segment_analytics)
- [IForEvents Documentation](https://pub.dev/packages/iforevents)

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
