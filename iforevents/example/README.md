# IforEvents Example App

This example app demonstrates the comprehensive features of the IforEvents analytics package for Flutter.

## Features Demonstrated

### 📊 Core Analytics Features
- **User Identification**: See how user data is tracked across analytics platforms
- **Event Tracking**: Various types of events with custom properties
- **Screen Navigation**: Automatic route tracking with navigator observer
- **Device Information**: Automatic collection of device and app data

### 🎯 Event Types Covered
- **Basic Events**: Simple tracking and events with properties
- **E-commerce Events**: Product views, add to cart, purchases
- **User Engagement**: Feature usage, content sharing, tutorial completion
- **Settings Changes**: Track user preference modifications
- **Form Interactions**: Profile updates and form field changes

### 🔗 Integration Examples
- **Amplitude**: Revenue tracking, group analytics, user journeys, A/B testing ⭐ NEW
- **Firebase Analytics**: (Commented out - requires Firebase setup)
- **Mixpanel**: User identification, event tracking, user properties
- **Device Data**: Automatic IP detection and device information collection

## Getting Started

### Prerequisites

1. **Flutter SDK** (latest stable version)
2. **Dart SDK** (latest stable version)

### Installation

1. Navigate to the example directory:
   ```bash
   cd iforevents/example
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. **Configure Analytics Platforms** (Optional):

   #### For Firebase Analytics:
   - Follow the [Firebase setup guide](https://firebase.google.com/docs/flutter/setup)
   - Uncomment Firebase-related code in `main.dart`
   - Add your `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)

   #### For Amplitude:
   - Get your API key from [Amplitude](https://amplitude.com)
   - Replace `'YOUR_AMPLITUDE_API_KEY'` in `main.dart` with your actual API key
   
   #### For Mixpanel:
   - Get your project token from [Mixpanel](https://mixpanel.com)
   - Replace `'YOUR_MIXPANEL_TOKEN_HERE'` in `main.dart` with your actual token

4. Run the example:
   ```bash
   flutter run
   ```

## App Structure

### Screens

1. **Home Screen** (`screens/home_screen.dart`)
   - Main navigation hub
   - Quick action buttons for basic event tracking
   - Navigation to other screens

2. **Profile Screen** (`screens/profile_screen.dart`)
   - User identification demo
   - Form field tracking
   - Profile update and reset functionality

3. **Settings Screen** (`screens/settings_screen.dart`)
   - Settings change tracking
   - Toggle and dropdown interactions
   - Preference management

4. **Analytics Demo Screen** (`screens/analytics_demo_screen.dart`)
   - Comprehensive event tracking examples
   - Different event types (basic, e-commerce, engagement)
   - Real-time event statistics
   - Recent events display

5. **Amplitude Demo Screen** (`screens/amplitude_demo_screen.dart`) ⭐ NEW
   - Basic events and properties
   - User identification and properties
   - Revenue tracking (purchases, subscriptions, IAPs)
   - Group analytics (B2B features)
   - Advanced features (user journeys, A/B testing)
   - Real-time statistics with revenue tracking
   - Professional UI with Amplitude branding

### Key Components

- **Navigator Observer**: Automatic screen tracking
- **Event Properties**: Rich metadata with each event
- **Device Data**: Automatic collection and inclusion
- **Error Handling**: Graceful failure management

## Example Usage Patterns

### Basic Event Tracking
```dart
iforevents.track(eventName: 'button_clicked');
```

### Event with Properties
```dart
iforevents.track(
  eventName: 'purchase_completed',
  properties: {
    'product_id': 'prod_123',
    'price': 29.99,
    'currency': 'USD',
  },
);
```

### User Identification
```dart
await iforevents.identify(
  id: 'user_123',
  data: {
    'email': 'user@example.com',
    'name': 'John Doe',
    'plan': 'premium',
  },
);
```

### Screen Tracking
```dart
// Automatic with NavigatorObserver
MaterialApp(
  navigatorObservers: [
    IforeventsNavigatorObserver(iforevents: iforevents),
  ],
  // ...
)
```

## Testing Analytics Integration

### 1. Amplitude Testing
1. Get your API key from Amplitude dashboard
2. Replace the API key in `main.dart`
3. Run the app and navigate to "Amplitude Demo"
4. Try different event types and features
5. Check your Amplitude dashboard for:
   - Events and properties
   - User properties
   - Revenue data
   - Group analytics
6. Features to test:
   - Basic event tracking
   - User identification
   - Revenue tracking (purchases, subscriptions)
   - Group analytics (company, team)
   - User journey tracking
   - A/B testing events

### 2. Mixpanel Testing
1. Replace the token in `main.dart`
2. Run the app
3. Navigate through screens and trigger events
4. Check your Mixpanel dashboard for events

### 3. Firebase Analytics Testing
1. Set up Firebase project
2. Uncomment Firebase code in `main.dart`
3. Run the app
4. Check Firebase Analytics dashboard

### 4. Debug Mode
Events are logged to the console in debug mode. Check the output for:
- Event names and properties
- User identification data
- Screen navigation events
- Error messages (if any)

## Key Learning Points

### Device Information Collection
- Automatic IP address detection
- Platform-specific device data (Android, iOS, Windows)
- App version and build information
- Unique device identifiers

### Event Property Best Practices
- Include relevant context with each event
- Use consistent naming conventions
- Add timestamps for time-based analysis
- Include user journey markers

### User Identification Strategy
- Identify users early in the app lifecycle
- Include both demographic and behavioral data
- Update user properties as they change
- Reset data when users log out

### Navigation Tracking
- Use the provided NavigatorObserver for automatic tracking
- Track both source and destination screens
- Include navigation context (button clicks, deep links, etc.)

## Troubleshooting

### Common Issues

1. **Analytics not initializing**:
   - Check your API keys/tokens
   - Verify network connectivity
   - Look for initialization errors in console

2. **Events not appearing in dashboard**:
   - Ensure proper API key configuration
   - Check for network issues
   - Verify event name formatting

3. **Build errors**:
   - Run `flutter clean && flutter pub get`
   - Check Flutter and Dart versions
   - Verify all dependencies are compatible

### Debug Tips

- Enable verbose logging in your analytics platforms
- Use the app's Analytics Demo screen to test different event types
- Check the Recent Events display for confirmation
- Monitor console output for error messages

## Next Steps

After exploring this example:

1. **Integrate into your app**: Copy the patterns that fit your use case
2. **Customize events**: Define events specific to your app's functionality
3. **Set up dashboards**: Configure analytics dashboards for your needs
4. **Add more integrations**: Explore additional analytics platforms

## Support

- 📧 **Email**: [innovafour@innovafour.com](mailto:innovafour@innovafour.com)
- 📖 **Documentation**: Check the main package README
- 🐛 **Issues**: [GitHub Issues](https://github.com/innovafour/flutter_iforevents/issues)

---

Happy tracking! 🎉
