# IForevents API Integration

A complete and robust integration for the IForevents API that includes:

- ✅ **User identification** and session management
- ✅ **Event tracking** individual and batch
- ✅ **Completely customizable configuration**
- ✅ **Offline event queue** with automatic re## 🔒 Security

### Security Best Practices

1. **Don't hardcode credentials**: Use environment variables
2. **Use HTTPS**: Always configure URLs with `https://`
3. **Validate data**: Sanitize data before sending
4. **Control logs**: Don't log sensitive information

### Secure ExampleRobust error handling** and retry logic
- ✅ **Detailed logging** for debugging
- ✅ **High performance** with HTTP/2 using Dio

## 🚀 Installation

The integration is included by default in the `iforevents` package. You just need to make sure you have `dio` in your dependencies:

```yaml
dependencies:
  iforevents: ^0.0.1
  dio: ^5.9.0
```

## 📖 Basic Usage

### 1. Configuration

```dart
import 'package:iforevents/iforevents.dart';
import 'package:iforevents/integration/iforevents.dart';

// Basic configuration
final config = IForeventsAPIConfig(
  projectKey: 'your-project-key',
  projectSecret: 'your-project-secret',
  baseUrl: 'https://your-api-domain.com',
  batchSize: 10, // Events per batch
  enableLogging: false, // Only for development
);

// Create the integration
final apiIntegration = IForeventsAPIIntegration(config: config);

// Initialize IForevents
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
      'age': 30,
      'plan': 'premium',
      'country': 'ES',
    },
  ),
);
```

### 3. Event Tracking

```dart
// Individual event
iforevents.track(
  event: TrackEvent(
    eventName: 'button_click',
    properties: {
      'button_id': 'signup_btn',
      'page': 'homepage',
      'timestamp': DateTime.now().toIso8601String(),
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

## ⚙️ Advanced Configuration

### Predefined Configurations

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

// Offline-first (for apps with limited connectivity)
final offlineConfig = IForeventsConfigExamples.offlineFirst(
  projectKey: 'your-key',
  projectSecret: 'your-secret',
  baseUrl: 'https://api.iforevents.com',
);
```

### Custom Configuration

```dart
final customConfig = IForeventsAPIConfig(
  projectKey: 'your-project-key',
  projectSecret: 'your-project-secret',
  baseUrl: 'https://your-api-domain.com',
  
  // Batching configuration
  batchSize: 25,                    // Events per batch (1 = no batching)
  batchIntervalMs: 8000,            // Batch review interval
  
  // HTTP timeouts
  connectTimeoutMs: 15000,          // Connection timeout
  receiveTimeoutMs: 15000,          // Receive timeout
  sendTimeoutMs: 15000,             // Send timeout
  
  // Retry configuration
  enableRetry: true,                // Enable automatic retries
  maxRetries: 3,                    // Maximum number of retries
  retryDelayMs: 2000,              // Delay between retries
  
  // Behavior
  enableLogging: false,             // Detailed logs (development only)
  throwOnError: false,              // Throw exceptions on errors
  requireIdentifyBeforeTrack: true, // Require identify before tracking
  requeueFailedEvents: true,        // Re-queue failed events
);
```

## 🔄 State Management

### Check Queue Status

```dart
final integration = apiIntegration as IForeventsAPIIntegration;
final status = integration.getQueueStatus();

print('Queued events: ${status.queuedEvents}');
print('User identified: ${status.isIdentified}');
print('Session UUID: ${status.sessionUUID}');
```

### Manual Queue Flush

```dart
// Send all queued events immediately
await apiIntegration.flush();
```

### Integration Reset

```dart
// Complete reset (sends pending events and clears state)
await iforevents.reset();
```

## 📊 Event Batching

The batching system groups events to send them efficiently:

### Recommended Configuration by App Type

| App Type | batchSize | batchIntervalMs | Description |
|-------------|-----------|-----------------|-------------|
| **E-commerce** | 15-20 | 5000 | Balance between real-time and efficiency |
| **Gaming** | 50-100 | 10000 | High volume of events |
| **Analytics** | 10-15 | 3000 | Fast response |
| **Offline-first** | 100+ | 30000 | For limited connectivity |
| **Real-time** | 1 | N/A | No batching, immediate sending |

### Batching Behavior

- Events accumulate in an internal queue
- They are sent when `batchSize` is reached or every `batchIntervalMs`
- Failed events are automatically re-queued (configurable)
- The queue is completely flushed when calling `reset()` or `flush()`

## 🛠️ Error Handling

### Error Strategies

```dart
// Error-tolerant configuration (recommended for production)
final tolerantConfig = IForeventsAPIConfig(
  // ... other configurations
  throwOnError: false,              // Don't throw exceptions
  enableRetry: true,                // Retry automatically
  requeueFailedEvents: true,        // Re-queue failed events
  maxRetries: 3,                    // Up to 3 retries
);

// Strict configuration (recommended for development)
final strictConfig = IForeventsAPIConfig(
  // ... other configurations
  throwOnError: true,               // Throw exceptions
  enableLogging: true,              // Detailed logs
  maxRetries: 1,                    // Few retries
);
```

### Error Types

- **Network errors**: Automatic retries
- **4xx errors**: Not retried (client error)
- **5xx errors**: Automatic retries
- **Timeouts**: Automatic retries

## 🔍 Debugging and Logging

### Enable Detailed Logs

```dart
final debugConfig = IForeventsAPIConfig(
  // ... other configurations
  enableLogging: true,
);
```

Logs include:
- HTTP requests with headers and body
- Responses with status codes
- Detailed errors with stack traces
- Event queue status
- Retry information

### Log Example

```
[IForeventsAPI] IForevents API Integration initialized successfully
[IForeventsAPI] IForevents API Request: POST /events/identify
[IForeventsAPI] IForevents API Response: 200
[IForeventsAPI] User identified successfully. Session: 550e8400-e29b-41d4-a716-446655440000
[IForeventsAPI] Event added to queue. Queue size: 1/10
[IForeventsAPI] Event added to queue. Queue size: 2/10
[IForeventsAPI] Batch of 10 events sent successfully
```

## 🚀 Performance Optimization

### Best Practices

1. **Use batching**: Configure `batchSize > 1` for better performance
2. **Adjust timeouts**: Reduce timeouts for apps with fast connectivity
3. **Optimize queue**: Use `requeueFailedEvents: false` if you don't need persistence
4. **Disable logs**: `enableLogging: false` in production

### High Performance Configuration

```dart
final highPerformanceConfig = IForeventsAPIConfig(
  projectKey: 'your-key',
  projectSecret: 'your-secret',
  baseUrl: 'https://api.iforevents.com',
  batchSize: 50,                    // Large batches
  batchIntervalMs: 15000,           // Long intervals
  connectTimeoutMs: 5000,           // Short timeouts
  receiveTimeoutMs: 5000,
  enableLogging: false,             // No logs
  enableRetry: true,
  maxRetries: 2,                    // Few retries
  requeueFailedEvents: false,       // No re-queuing
);
```

## 🔒 Seguridad

### Mejores Prácticas de Seguridad

1. **No hardcodees credenciales**: Usa variables de entorno
2. **Usa HTTPS**: Siempre configura URLs con `https://`
3. **Valida datos**: Sanitiza datos antes de enviarlos
4. **Controla logs**: No logees información sensible

### Ejemplo Seguro

```dart
// ❌ Don't do this
final config = IForeventsAPIConfig(
  projectKey: 'pk_live_abc123',      // Hardcoded!
  projectSecret: 'sk_live_xyz789',   // Dangerous!
  // ...
);

// ✅ Do this
final config = IForeventsAPIConfig(
  projectKey: const String.fromEnvironment('IFOREVENTS_PROJECT_KEY'),
  projectSecret: const String.fromEnvironment('IFOREVENTS_PROJECT_SECRET'),
  baseUrl: 'https://api.iforevents.com', // Always HTTPS
  enableLogging: false, // Don't log in production
  // ...
);
```

## 📱 Flutter Integration

### App Initialization

```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      home: FutureBuilder(
        future: _initializeIForevents(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return HomeScreen();
          }
          return SplashScreen();
        },
      ),
    );
  }

  Future<void> _initializeIForevents() async {
    final config = IForeventsConfigExamples.production(
      projectKey: const String.fromEnvironment('IFOREVENTS_PROJECT_KEY'),
      projectSecret: const String.fromEnvironment('IFOREVENTS_PROJECT_SECRET'),
      baseUrl: 'https://api.iforevents.com',
    );

    final apiIntegration = IForeventsAPIIntegration(config: config);
    final iforevents = Iforevents();
    
    await iforevents.init(integrations: [apiIntegration]);
  }
}
```

### Automatic Navigation Tracking

```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorObservers: [
        IForeventsNavigatorObserver(), // Included in the package
      ],
      // ...
    );
  }
}
```

## 📋 Common Use Cases

### E-commerce

```dart
// Product viewed
iforevents.track(
  event: TrackEvent(
    eventName: 'product_viewed',
    properties: {
      'product_id': 'prod_123',
      'product_name': 'iPhone 15',
      'category': 'electronics',
      'price': 999.99,
      'currency': 'EUR',
    },
  ),
);

// Add to cart
iforevents.track(
  event: TrackEvent(
    eventName: 'add_to_cart',
    properties: {
      'product_id': 'prod_123',
      'quantity': 1,
      'cart_total': 999.99,
    },
  ),
);

// Purchase completed
iforevents.track(
  event: TrackEvent(
    eventName: 'purchase_completed',
    properties: {
      'order_id': 'order_456',
      'total_amount': 999.99,
      'currency': 'EUR',
      'payment_method': 'credit_card',
      'products': [
        {'id': 'prod_123', 'quantity': 1, 'price': 999.99}
      ],
    },
  ),
);
```

### Gaming

```dart
// Level completed
iforevents.track(
  event: TrackEvent(
    eventName: 'level_completed',
    properties: {
      'level': 5,
      'score': 12500,
      'time_taken': 180, // seconds
      'difficulty': 'medium',
    },
  ),
);

// In-app purchase
iforevents.track(
  event: TrackEvent(
    eventName: 'in_app_purchase',
    properties: {
      'item_id': 'coins_pack_large',
      'item_name': 'Large Coin Pack',
      'price': 4.99,
      'currency': 'EUR',
    },
  ),
);
```

### General Analytics

```dart
// Feature used
iforevents.track(
  event: TrackEvent(
    eventName: 'feature_used',
    properties: {
      'feature_name': 'export_data',
      'export_format': 'pdf',
      'user_plan': 'premium',
    },
  ),
);

// Application error
iforevents.track(
  event: TrackEvent(
    eventName: 'app_error',
    properties: {
      'error_code': 'NETWORK_ERROR',
      'error_message': 'Failed to load data',
      'screen': 'dashboard',
      'user_action': 'refresh',
    },
  ),
);
```

## 🤝 Integration with Other Tools

The integration works perfectly together with other IForevents integrations:

```dart
await iforevents.init(integrations: [
  IForeventsAPIIntegration(config: apiConfig),     // Your custom API
  IForeventsFirebaseIntegration(),                 // Firebase Analytics
  IForeventsMetaIntegration(pixelId: 'pixel_id'),  // Meta Pixel
  IForeventsGoogleIntegration(),                   // Google Analytics
]);
```

## 🔧 Troubleshooting

### Common Issues

**1. Events not being sent**
```dart
// Check integration status
final status = apiIntegration.getQueueStatus();
print('Initialized: ${status.isInitialized}');
print('User identified: ${status.isIdentified}');
print('Queued events: ${status.queuedEvents}');
```

**2. Authentication errors**
```dart
// Check credentials
final config = IForeventsAPIConfig(
  projectKey: 'your-key',    // Is it correct?
  projectSecret: 'your-secret', // Is it correct?
  baseUrl: 'https://correct-domain.com', // Correct URL?
  enableLogging: true, // Enable logs for debugging
);
```

**3. Events are lost**
```dart
// Make sure to flush the queue before closing the app
@override
void dispose() {
  apiIntegration.flush(); // Send pending events
  super.dispose();
}
```

**4. Slow performance**
```dart
// Optimize configuration
final fastConfig = IForeventsAPIConfig(
  // ...
  batchSize: 1,         // Immediate sending
  connectTimeoutMs: 3000, // Short timeout
  enableRetry: false,   // No retries
);
```

## 📊 Monitoring and Metrics

### Important Metrics

- **Send success rate**: Events sent vs failed
- **Average queue time**: Time events spend in queue
- **Average batch size**: Batching efficiency
- **Errors by type**: Network, auth, server, etc.

### Implement Metrics

```dart
class IForeventsMetrics {
  static int _eventsSent = 0;
  static int _eventsFailed = 0;
  static int _batchesSent = 0;

  static void trackEventSent() => _eventsSent++;
  static void trackEventFailed() => _eventsFailed++;
  static void trackBatchSent() => _batchesSent++;

  static Map<String, dynamic> getMetrics() {
    return {
      'events_sent': _eventsSent,
      'events_failed': _eventsFailed,
      'batches_sent': _batchesSent,
      'success_rate': _eventsSent / (_eventsSent + _eventsFailed),
    };
  }
}
```

## 🎯 Roadmap

### Upcoming Features

- [ ] **Offline persistence**: Save events when no connection
- [ ] **Automatic compression**: Compress large payloads
- [ ] **Integrated metrics**: Real-time metrics dashboard
- [ ] **A/B Testing**: Support for experiments
- [ ] **Segmentation**: Conditional sending based on user properties
- [ ] **Rate limiting**: Send speed control
- [ ] **Webhook support**: Callbacks for specific events

---

## 📄 License

MIT License - See [LICENSE](LICENSE) for more details.

## 🤝 Contributing

Contributions are welcome! Please read [CONTRIBUTING.md](CONTRIBUTING.md) for more information.

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/innovafour/flutter_iforevents/issues)
- **Email**: support@iforevents.com
- **Documentation**: [docs.iforevents.com](https://docs.iforevents.com)
