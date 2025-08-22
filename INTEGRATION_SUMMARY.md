# 🎯 IForevents API Integration - Implementation Complete

## ✅ What has been implemented?

I've created a **complete and robust integration** for the IForevents API directly in the `iforevents` package, with the following features:

### 🚀 Main Features
- ✅ **User identification** with session management
- ✅ **Event tracking** individual and batch
- ✅ **Intelligent batching system** configurable
- ✅ **Offline event queue** with persistence
- ✅ **Automatic retries** with exponential backoff
- ✅ **Robust error handling** with detailed logging
- ✅ **HTTP/2 with Dio** for maximum performance
- ✅ **Completely customizable configuration**

### 📁 Created Files

1. **`/lib/integration/iforevents.dart`** - Main integration with all classes:
   - `IForeventsAPIIntegration` - Main integration class
   - `IForeventsAPIConfig` - Customizable configuration
   - `IForeventsQueuedEvent` - Model for queued events
   - `IForeventsQueueStatus` - Queue status
   - `IForeventsAPIException` - Specific exceptions
   - `_IForeventsRetryInterceptor` - Retry interceptor

2. **`/example/lib/api_integration_main.dart`** - Complete usage example

3. **`/README_API_INTEGRATION.md`** - Comprehensive documentation

## 🔧 How to use the integration

### 1. Basic Configuration

```dart
import 'package:iforevents/iforevents.dart';

// Configure the integration
final config = IForeventsAPIConfig(
  projectKey: 'your-project-key',
  projectSecret: 'your-project-secret',
  baseUrl: 'https://your-api-domain.com',
  batchSize: 10, // Events per batch
  enableLogging: false, // Only for development
);

// Create and initialize
final apiIntegration = IForeventsAPIIntegration(config: config);
final iforevents = Iforevents();
await iforevents.init(integrations: [apiIntegration]);
```

### 2. Identify User

```dart
await iforevents.identify(
  event: IdentifyEvent(
    customID: 'user_123',
  properties: {
    'email': 'user@example.com',
    'name': 'Juan Pérez',
    'phone_number': '+34612345678',
  },
),
);
```

### 3. Event Tracking```dart
// Individual event
iforevents.track(
  event: TrackEvent(
    eventName: 'button_click',
    properties: {
      'button_id': 'signup_btn',
      'page': 'homepage',
    },
  ),
);

// Page view
await iforevents.pageViewed(
  event: PageViewEvent(
    navigationType: 'push',
    toRoute: RouteSettings(name: '/dashboard'),
    previousRoute: RouteSettings(name: '/home'),
  ),
);
```

## ⚙️ Predefined Configurations

The integration includes optimized configurations for different use cases:

```dart
// Production (recommended)
final prodConfig = IForeventsConfigExamples.production(
  projectKey: 'your-key',
  projectSecret: 'your-secret',
  baseUrl: 'https://api.iforevents.com',
);

// Development/Testing
final devConfig = IForeventsConfigExamples.development(
  projectKey: 'your-key',
  projectSecret: 'your-secret',
  baseUrl: 'https://api-dev.iforevents.com',
);

// Real time (no batching)
final realtimeConfig = IForeventsConfigExamples.realTime(
  projectKey: 'your-key',
  projectSecret: 'your-secret',
  baseUrl: 'https://api.iforevents.com',
);

// Offline-first
final offlineConfig = IForeventsConfigExamples.offlineFirst(
  projectKey: 'your-key',
  projectSecret: 'your-secret',
  baseUrl: 'https://api.iforevents.com',
);
```

## 🎛️ Advanced Control

### Queue Management

```dart
// Check status
final status = apiIntegration.getQueueStatus();
print('Queued events: ${status.queuedEvents}');
print('User identified: ${status.isIdentified}');

// Manually flush queue
await apiIntegration.flush();

// Complete reset
await iforevents.reset();
```

### Custom Configuration

```dart
final customConfig = IForeventsAPIConfig(
  projectKey: 'your-key',
  projectSecret: 'your-secret',
  baseUrl: 'https://your-api.com',
  
  // Batching
  batchSize: 25,                    // Events per batch
  batchIntervalMs: 8000,            // Review interval
  
  // Timeouts
  connectTimeoutMs: 15000,
  receiveTimeoutMs: 15000,
  sendTimeoutMs: 15000,
  
  // Retries
  enableRetry: true,
  maxRetries: 3,
  retryDelayMs: 2000,
  
  // Behavior
  enableLogging: false,
  throwOnError: false,
  requireIdentifyBeforeTrack: true,
  requeueFailedEvents: true,
);
```

## 🔄 Batching System

The batching system is completely configurable:

- **batchSize**: Number of events per batch (1 = no batching)
- **batchIntervalMs**: Queue review frequency
- **Automatic sending**: Triggered when reaching batchSize or by time
- **Re-queuing**: Failed events are automatically re-queued

### Recommendations by App Type

| Type | batchSize | batchIntervalMs | Usage |
|------|-----------|-----------------|-------|
| E-commerce | 15-20 | 5000 | Balance efficiency/real-time |
| Gaming | 50-100 | 10000 | High volume |
| Analytics | 10-15 | 3000 | Fast response |
| Offline-first | 100+ | 30000 | Limited connectivity |
| Real-time | 1 | N/A | No batching |

## 🛠️ Debugging

### Enable Logs

```dart
final debugConfig = IForeventsAPIConfig(
  // ...
  enableLogging: true, // Detailed logs
  throwOnError: true,  // Exceptions for debugging
);
```

Logs include:
- Complete HTTP requests
- Responses with status codes
- Detailed errors
- Queue status
- Retry information

## 🔒 Security

### Best Practices

```dart
// ✅ Use environment variables
final config = IForeventsAPIConfig(
  projectKey: const String.fromEnvironment('IFOREVENTS_PROJECT_KEY'),
  projectSecret: const String.fromEnvironment('IFOREVENTS_PROJECT_SECRET'),
  baseUrl: 'https://api.iforevents.com', // Always HTTPS
  enableLogging: false, // Don't log in production
);
```

## 📊 Integration with Other Tools

The integration works perfectly with other integrations:

```dart
await iforevents.init(integrations: [
  IForeventsAPIIntegration(config: apiConfig),     // Your API
  IForeventsFirebaseIntegration(),                 // Firebase
  IForeventsMetaIntegration(pixelId: 'pixel'),     // Meta
  IForeventsAlgoliaIntegration(appId: 'app'),      // Algolia
]);
```

## 🚀 Next Steps

1. **Configure your credentials**: Replace demo credentials
2. **Adjust configuration**: According to your performance needs
3. **Test in development**: Use enableLogging: true for debugging
4. **Deploy to production**: With optimized configuration
5. **Monitor**: Review logs and sending metrics

## 📞 Support

- **Complete documentation**: `README_API_INTEGRATION.md`
- **Functional example**: `example/lib/api_integration_main.dart`
- **Predefined configurations**: `IForeventsConfigExamples`

## 🎉 Highlighted Features

✅ **Completely optional**: Can be easily disabled
✅ **No external dependencies**: Only uses Dio (already included)
✅ **Highly configurable**: More than 15 configuration parameters
✅ **Robust**: Error handling, retries, and offline queue
✅ **Efficient**: Intelligent batching and HTTP/2
✅ **Secure**: Authentication headers, HTTPS, validation

The integration is **production ready** and follows all IForevents API documentation best practices.
