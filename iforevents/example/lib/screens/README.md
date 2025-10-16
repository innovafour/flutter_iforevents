# Screens - Example App

This folder contains the demo screens for the IforEvents example application.

## Available Screens

### 1. HomeScreen (`home_screen.dart`)
Main application screen with navigation to all demos.

**Features:**
- Navigation to other screens
- Navigation event tracking
- Quick tracking actions

### 2. ProfileScreen (`profile_screen.dart`)
User profile screen.

**Features:**
- User information display
- Screen view tracking

### 3. SettingsScreen (`settings_screen.dart`)
Application settings screen.

**Features:**
- Configuration settings
- Configuration change tracking

### 4. AnalyticsDemoScreen (`analytics_demo_screen.dart`)
General analytics features demo.

**Features:**
- Basic events
- E-commerce events
- User engagement tracking
- Real-time statistics

### 5. AmplitudeDemoScreen (`amplitude_demo_screen.dart`) ⭐ NEW
Specific demo for Amplitude integration.

**Features:**
- **Basic Events**: Simple event tracking and events with properties
- **User Properties**: User identification and profile updates
- **Revenue Tracking**: Purchases, subscriptions, and in-app purchases
- **Group Analytics**: B2B analysis with companies and teams
- **Advanced Features**: User journeys, A/B testing, manual flush
- **Real-Time Statistics**: 
  - Event counter
  - Total revenue
  - Recent events
- **Professional UI**: Modern design with Amplitude color scheme

#### How to Use AmplitudeDemoScreen

```dart
// In main.dart
import 'package:example/screens/amplitude_demo_screen.dart';
import 'package:iforevents_amplitude/iforevents_amplitude.dart';

final amplitudeIntegration = const AmplitudeIntegration(
  apiKey: 'YOUR_AMPLITUDE_API_KEY',
);

// In routes
routes: {
  '/amplitude': (context) => AmplitudeDemoScreen(
    iforevents: iforevents,
    amplitudeIntegration: amplitudeIntegration,
  ),
}
```

#### Amplitude Demo Features

1. **Basic Events Section**
   - Simple Event: Event without properties
   - Event with Properties: Event with multiple properties
   - Button Click: UI interaction tracking

2. **User Properties Section**
   - Set User Properties: Update complete profile
   - Update Subscription: Change subscription tier
   - Set User Location: Geographic information

3. **Revenue Tracking Section**
   - Track Purchase: Product purchase with revenue
   - Track Subscription: Recurring subscription
   - Track In-App Purchase: In-app purchases

4. **Group Analytics Section**
   - Join Company: Add user to company
   - Join Team: Add user to team
   - Update Group Properties: Update group properties

5. **Advanced Features Section**
   - Track User Journey: Multi-step flow
   - A/B Test Event: Experiment tracking
   - Flush Events: Force event sending

6. **Statistics Card**
   - Events: Total tracked events
   - Revenue Events: Events with revenue
   - Total Revenue: Total revenue sum

7. **Recent Events Card**
   - Shows last 5 events
   - Timestamp of each event
   - Number of properties

8. **Action Buttons**
   - Clear Statistics: Clear counters
   - Generate Test Events: Generate test events

### 6. IForevents Screens (`iforevents_1.dart`, `iforevents_2.dart`)
Specific demos of the IForevents API.

## Adding a New Screen

1. Create a new file in this folder
2. Extend `StatefulWidget` or `StatelessWidget`
3. Accept `Iforevents` as constructor parameter
4. Add appropriate tracking in `initState()` or `build()`
5. Register the route in `main.dart`

### Screen Template

```dart
import 'package:flutter/material.dart';
import 'package:iforevents/iforevents.dart';

class MyNewScreen extends StatefulWidget {
  final Iforevents iforevents;

  const MyNewScreen({super.key, required this.iforevents});

  @override
  State<MyNewScreen> createState() => _MyNewScreenState();
}

class _MyNewScreenState extends State<MyNewScreen> {
  @override
  void initState() {
    super.initState();
    // Track screen view
    widget.iforevents.track(
      event: TrackEvent(
        eventName: 'my_new_screen_viewed',
        properties: {
          'screen_name': 'my_new_screen',
          'timestamp': DateTime.now().toIso8601String(),
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My New Screen'),
      ),
      body: Center(
        child: Text('Content'),
      ),
    );
  }
}
```

## Navigation

To navigate to any screen from another screen:

```dart
// Simple navigation
Navigator.pushNamed(context, '/amplitude');

// Navigation with tracking
widget.iforevents.track(
  event: TrackEvent(
    eventName: 'navigation_button_clicked',
    properties: {
      'target_screen': '/amplitude',
      'source_screen': 'home',
    },
  ),
);
Navigator.pushNamed(context, '/amplitude');
```

## Best Practices

1. **Always track screen views** in `initState()`
2. **Use consistent names** for events
3. **Include relevant properties** in each event
4. **Handle state** correctly with StatefulWidget
5. **Show feedback** to user with SnackBars
6. **Responsive design** that works on different sizes

## Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [IforEvents Documentation](../../README.md)
- [Amplitude Integration Examples](../../../iforevents_amplitude/EXAMPLES.md)
