# IForEvents Segment - Usage Examples

This document provides comprehensive examples of using the Segment integration with IForEvents.

## Table of Contents

1. [Basic Setup](#basic-setup)
2. [Identification](#identification)
3. [Event Tracking](#event-tracking)
4. [Page/Screen Tracking](#pagescreen-tracking)
5. [Group Analytics](#group-analytics)
6. [Advanced Features](#advanced-features)
7. [E-commerce Examples](#e-commerce-examples)
8. [User Lifecycle](#user-lifecycle)

## Basic Setup

### Minimal Configuration

```dart
import 'package:flutter/material.dart';
import 'package:iforevents/iforevents.dart';
import 'package:iforevents_segment/iforevents_segment.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await IForEvents.init(
    integrations: [
      SegmentIntegration(
        writeKey: 'YOUR_WRITE_KEY',
      ),
    ],
  );
  
  runApp(MyApp());
}
```

### Full Configuration

```dart
await IForEvents.init(
  integrations: [
    SegmentIntegration(
      writeKey: 'YOUR_WRITE_KEY',
      debug: false,
      onInit: () => print('Segment initialized successfully'),
      onIdentify: (event) {
        print('User identified: ${event.customID}');
        print('Properties: ${event.properties}');
      },
      onTrack: (event) {
        print('Event tracked: ${event.eventName}');
        print('Properties: ${event.properties}');
      },
      onPageView: (event) {
        print('Screen viewed: ${event.name}');
      },
      onReset: () => print('User session reset'),
    ),
  ],
);
```

## Identification

### Basic User Identification

```dart
// Identify user after login
IForEvents.identify(
  customID: 'user_12345',
  properties: {
    'email': 'john.doe@example.com',
    'name': 'John Doe',
  },
);
```

### Complete User Profile

```dart
IForEvents.identify(
  customID: 'user_12345',
  properties: {
    'email': 'john.doe@example.com',
    'name': 'John Doe',
    'first_name': 'John',
    'last_name': 'Doe',
    'phone': '+1234567890',
    'age': 28,
    'gender': 'male',
    'plan': 'premium',
    'account_type': 'business',
    'signup_date': '2024-01-15',
    'company': 'Acme Inc',
    'industry': 'Technology',
    'employee_count': 50,
    'avatar_url': 'https://example.com/avatar.jpg',
  },
);
```

### Anonymous to Identified User

```dart
// First, track anonymous user
IForEvents.track(
  eventName: 'Product Viewed',
  properties: {'product_id': 'prod_123'},
);

// After login, identify the user
IForEvents.identify(
  customID: 'user_12345',
  properties: {
    'email': 'john.doe@example.com',
    'name': 'John Doe',
  },
);

// Alias anonymous user to identified user
final integration = IForEvents.getIntegration<SegmentIntegration>();
await integration?.alias(alias: 'user_12345');
```

## Event Tracking

### Simple Events

```dart
// Button click
IForEvents.track(
  eventName: 'Button Clicked',
  properties: {
    'button_name': 'Sign Up',
    'screen': 'Home',
  },
);

// Form submission
IForEvents.track(
  eventName: 'Form Submitted',
  properties: {
    'form_name': 'Contact Form',
    'success': true,
  },
);
```

### User Actions

```dart
// Search
IForEvents.track(
  eventName: 'Search Performed',
  properties: {
    'query': 'flutter packages',
    'results_count': 42,
    'filters': 'recent',
  },
);

// Share
IForEvents.track(
  eventName: 'Content Shared',
  properties: {
    'content_type': 'article',
    'content_id': 'article_789',
    'platform': 'twitter',
  },
);

// Download
IForEvents.track(
  eventName: 'File Downloaded',
  properties: {
    'file_name': 'report.pdf',
    'file_size': '2.5MB',
    'file_type': 'pdf',
  },
);
```

### Feature Usage

```dart
// Feature enabled
IForEvents.track(
  eventName: 'Feature Enabled',
  properties: {
    'feature_name': 'Dark Mode',
    'previous_state': false,
  },
);

// Settings changed
IForEvents.track(
  eventName: 'Settings Changed',
  properties: {
    'setting_name': 'Notifications',
    'old_value': 'enabled',
    'new_value': 'disabled',
  },
);
```

## Page/Screen Tracking

### Basic Screen Views

```dart
// Home screen
IForEvents.pageView(
  name: 'Home Screen',
  properties: {
    'tab': 'feed',
  },
);

// Product details
IForEvents.pageView(
  name: 'Product Details',
  properties: {
    'product_id': 'prod_123',
    'product_name': 'Premium Plan',
    'category': 'subscription',
  },
);
```

### Navigation Tracking

```dart
class MyScreen extends StatefulWidget {
  @override
  _MyScreenState createState() => _MyScreenState();
}

class _MyScreenState extends State<MyScreen> {
  @override
  void initState() {
    super.initState();
    
    // Track screen view
    IForEvents.pageView(
      name: 'My Screen',
      properties: {
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('My Screen')),
      body: Container(),
    );
  }
}
```

## Group Analytics

### Company/Organization Tracking

```dart
final integration = IForEvents.getIntegration<SegmentIntegration>();

// Associate user with a company
await integration?.group(
  groupId: 'company_123',
  traits: {
    'name': 'Acme Corporation',
    'plan': 'enterprise',
    'employees': 500,
    'industry': 'Technology',
    'website': 'https://acme.com',
    'founded': '2010',
    'monthly_spend': 5000,
  },
);
```

### Team Tracking

```dart
final integration = IForEvents.getIntegration<SegmentIntegration>();

await integration?.group(
  groupId: 'team_456',
  traits: {
    'name': 'Engineering Team',
    'members': 25,
    'department': 'Engineering',
    'manager': 'user_789',
  },
);
```

## Advanced Features

### Manual Flush

```dart
// Force send all queued events
final integration = IForEvents.getIntegration<SegmentIntegration>();
await integration?.flush();
```

### Reset on Logout

```dart
void logout() async {
  // Clear all user data
  await IForEvents.reset();
  
  // Navigate to login screen
  Navigator.pushReplacementNamed(context, '/login');
}
```

### Conditional Tracking

```dart
void trackEvent(String eventName, Map<String, dynamic> properties) {
  // Only track in production
  if (kReleaseMode) {
    IForEvents.track(
      eventName: eventName,
      properties: properties,
    );
  } else {
    print('Debug: Would track $eventName with $properties');
  }
}
```

## E-commerce Examples

### Product Interactions

```dart
// Product viewed
IForEvents.track(
  eventName: 'Product Viewed',
  properties: {
    'product_id': 'prod_123',
    'product_name': 'Premium Plan',
    'category': 'Subscription',
    'price': 29.99,
    'currency': 'USD',
    'brand': 'IForEvents',
  },
);

// Product added to cart
IForEvents.track(
  eventName: 'Product Added',
  properties: {
    'product_id': 'prod_123',
    'product_name': 'Premium Plan',
    'price': 29.99,
    'quantity': 1,
    'currency': 'USD',
  },
);

// Product removed from cart
IForEvents.track(
  eventName: 'Product Removed',
  properties: {
    'product_id': 'prod_123',
    'product_name': 'Premium Plan',
    'quantity': 1,
  },
);
```

### Checkout Flow

```dart
// Checkout started
IForEvents.track(
  eventName: 'Checkout Started',
  properties: {
    'order_id': 'order_456',
    'cart_value': 59.98,
    'currency': 'USD',
    'products': [
      {'product_id': 'prod_123', 'quantity': 2},
    ],
  },
);

// Payment info entered
IForEvents.track(
  eventName: 'Payment Info Entered',
  properties: {
    'order_id': 'order_456',
    'payment_method': 'credit_card',
  },
);

// Order completed
IForEvents.track(
  eventName: 'Order Completed',
  properties: {
    'order_id': 'order_456',
    'total': 59.98,
    'revenue': 59.98,
    'currency': 'USD',
    'products': [
      {
        'product_id': 'prod_123',
        'product_name': 'Premium Plan',
        'quantity': 2,
        'price': 29.99,
      },
    ],
  },
);
```

## User Lifecycle

### Onboarding

```dart
// App opened first time
IForEvents.track(
  eventName: 'App Installed',
  properties: {
    'platform': Platform.operatingSystem,
    'version': '1.0.0',
  },
);

// Tutorial started
IForEvents.track(
  eventName: 'Tutorial Started',
  properties: {
    'tutorial_name': 'Welcome Tour',
  },
);

// Tutorial step completed
IForEvents.track(
  eventName: 'Tutorial Step Completed',
  properties: {
    'tutorial_name': 'Welcome Tour',
    'step_number': 1,
    'step_name': 'Profile Setup',
  },
);

// Tutorial completed
IForEvents.track(
  eventName: 'Tutorial Completed',
  properties: {
    'tutorial_name': 'Welcome Tour',
    'completion_time': '2 minutes',
  },
);
```

### Engagement

```dart
// User became active
IForEvents.track(
  eventName: 'User Became Active',
  properties: {
    'days_since_signup': 7,
  },
);

// Feature discovered
IForEvents.track(
  eventName: 'Feature Discovered',
  properties: {
    'feature_name': 'Advanced Analytics',
    'discovery_method': 'navigation',
  },
);

// Achievement unlocked
IForEvents.track(
  eventName: 'Achievement Unlocked',
  properties: {
    'achievement_name': 'First Purchase',
    'points': 100,
  },
);
```

### Subscription Management

```dart
// Subscription started
IForEvents.track(
  eventName: 'Subscription Started',
  properties: {
    'plan': 'premium',
    'billing_cycle': 'monthly',
    'price': 29.99,
    'currency': 'USD',
    'trial': false,
  },
);

// Trial started
IForEvents.track(
  eventName: 'Trial Started',
  properties: {
    'plan': 'premium',
    'trial_days': 14,
  },
);

// Subscription cancelled
IForEvents.track(
  eventName: 'Subscription Cancelled',
  properties: {
    'plan': 'premium',
    'reason': 'too expensive',
    'feedback': 'Looking for a cheaper alternative',
  },
);

// Subscription renewed
IForEvents.track(
  eventName: 'Subscription Renewed',
  properties: {
    'plan': 'premium',
    'price': 29.99,
    'billing_cycle': 'monthly',
  },
);
```

## Best Practices

### Event Naming Convention

```dart
// Use consistent naming patterns
// Good: Object + Action
'Product Viewed'
'Cart Updated'
'Order Completed'
'User Registered'

// Avoid: Action + Object or unclear names
// Bad:
'Viewed Product'
'Update Cart'
'Buy'
'Register'
```

### Property Guidelines

```dart
// Use snake_case for property keys
IForEvents.track(
  eventName: 'Order Completed',
  properties: {
    'order_id': 'order_123',  // Good
    'total_amount': 99.99,    // Good
    // 'orderId': '...',      // Avoid camelCase
    // 'TotalAmount': ...,    // Avoid PascalCase
  },
);

// Include relevant context
IForEvents.track(
  eventName: 'Button Clicked',
  properties: {
    'button_name': 'Sign Up',
    'button_location': 'header',
    'screen_name': 'Home',
    'timestamp': DateTime.now().toIso8601String(),
  },
);
```

### Error Handling

```dart
try {
  IForEvents.track(
    eventName: 'Risky Operation',
    properties: {'status': 'started'},
  );
  
  // Perform operation
  await performRiskyOperation();
  
  IForEvents.track(
    eventName: 'Risky Operation',
    properties: {'status': 'completed'},
  );
} catch (e) {
  IForEvents.track(
    eventName: 'Risky Operation',
    properties: {
      'status': 'failed',
      'error': e.toString(),
    },
  );
}
```

## Testing

### Debug Mode

```dart
// Enable debug mode for development
const segmentIntegration = SegmentIntegration(
  writeKey: 'YOUR_WRITE_KEY',
  debug: true,  // Logs all events in console
);
```

### Test Different Environments

```dart
const writeKey = kReleaseMode 
  ? 'PRODUCTION_WRITE_KEY' 
  : 'DEVELOPMENT_WRITE_KEY';

const segmentIntegration = SegmentIntegration(
  writeKey: writeKey,
  debug: !kReleaseMode,
);
```
