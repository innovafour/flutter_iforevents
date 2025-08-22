import 'package:flutter/material.dart';
import 'package:iforevents/iforevents.dart';

class AnalyticsDemoScreen extends StatefulWidget {
  final Iforevents iforevents;

  const AnalyticsDemoScreen({super.key, required this.iforevents});

  @override
  State<AnalyticsDemoScreen> createState() => _AnalyticsDemoScreenState();
}

class _AnalyticsDemoScreenState extends State<AnalyticsDemoScreen> {
  int _buttonClickCount = 0;
  int _customEventCount = 0;
  final List<Map<String, dynamic>> _recentEvents = [];

  @override
  void initState() {
    super.initState();
    // Track screen view
    widget.iforevents.track(
      event: TrackEvent(
        eventName: 'screen_viewed',
        properties: {
          'screen_name': 'analytics_demo',
          'screen_class': 'AnalyticsDemoScreen',
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Analytics Demo'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Analytics Demo',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Explore different types of events and see how IforEvents tracks them across your analytics platforms.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16),
          _buildEventTypeSection('Basic Events', [
            _buildEventButton(
              'Simple Track Event',
              'Track a basic event without properties',
              Colors.blue,
              Icons.track_changes,
              () => _trackSimpleEvent(),
            ),
            _buildEventButton(
              'Event with Properties',
              'Track an event with custom properties',
              Colors.green,
              Icons.list,
              () => _trackEventWithProperties(),
            ),
            _buildEventButton(
              'Screen Event',
              'Track a screen view event',
              Colors.orange,
              Icons.screen_lock_portrait,
              () => _trackScreenEvent(),
            ),
          ]),
          SizedBox(height: 16),
          _buildEventTypeSection('E-commerce Events', [
            _buildEventButton(
              'Product Viewed',
              'Track when a user views a product',
              Colors.cyan,
              Icons.shopping_bag,
              () => _trackProductViewed(),
            ),
            _buildEventButton(
              'Add to Cart',
              'Track when a product is added to cart',
              Colors.indigo,
              Icons.add_shopping_cart,
              () => _trackAddToCart(),
            ),
            _buildEventButton(
              'Purchase Completed',
              'Track a completed purchase',
              Colors.teal,
              Icons.payment,
              () => _trackPurchase(),
            ),
          ]),
          SizedBox(height: 16),
          _buildEventTypeSection('User Engagement', [
            _buildEventButton(
              'Feature Used',
              'Track feature usage with details',
              Colors.deepPurple,
              Icons.star,
              () => _trackFeatureUsage(),
            ),
            _buildEventButton(
              'Content Shared',
              'Track content sharing behavior',
              Colors.pink,
              Icons.share,
              () => _trackContentShared(),
            ),
            _buildEventButton(
              'Tutorial Completed',
              'Track tutorial or onboarding completion',
              Colors.amber,
              Icons.school,
              () => _trackTutorialCompleted(),
            ),
          ]),
          SizedBox(height: 16),
          _buildStatsCard(),
          SizedBox(height: 16),
          _buildRecentEventsCard(),
          SizedBox(height: 16),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildEventTypeSection(String title, List<Widget> buttons) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Colors.purple.shade700,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        ...buttons,
      ],
    );
  }

  Widget _buildEventButton(
    String title,
    String description,
    Color color,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Icon(icon, color: color, size: 32),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(description),
        trailing: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: Text('Track', style: TextStyle(color: Colors.white)),
        ),
        onTap: onPressed,
      ),
    );
  }

  Widget _buildStatsCard() {
    return Card(
      color: Colors.purple.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Session Stats',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.purple.shade800,
              ),
            ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  'Button Clicks',
                  _buttonClickCount.toString(),
                  Icons.touch_app,
                ),
                _buildStatItem(
                  'Custom Events',
                  _customEventCount.toString(),
                  Icons.event,
                ),
                _buildStatItem(
                  'Total Events',
                  (_buttonClickCount + _customEventCount).toString(),
                  Icons.analytics,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.purple.shade600, size: 32),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.purple.shade800,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.purple.shade600),
        ),
      ],
    );
  }

  Widget _buildRecentEventsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Events',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.purple.shade800,
              ),
            ),
            SizedBox(height: 12),
            if (_recentEvents.isEmpty)
              Text(
                'No events tracked yet. Try tracking some events above!',
                style: TextStyle(color: Colors.grey.shade600),
              )
            else
              Column(
                children: _recentEvents.take(5).map((event) {
                  return ListTile(
                    dense: true,
                    leading: Icon(Icons.circle, color: Colors.purple, size: 8),
                    title: Text(
                      event['name'] ?? 'Unknown Event',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '${event['properties']?.length ?? 0} properties',
                    ),
                    trailing: Text(
                      event['timestamp'] ?? '',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _clearStats,
            icon: Icon(Icons.clear_all, color: Colors.white),
            label: Text('Clear Stats', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _generateRandomEvents,
            icon: Icon(Icons.shuffle, color: Colors.purple),
            label: Text(
              'Generate Random Events',
              style: TextStyle(color: Colors.purple),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.purple),
              padding: EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _addToRecentEvents(String eventName, Map<String, dynamic> properties) {
    setState(() {
      _recentEvents.insert(0, {
        'name': eventName,
        'properties': properties,
        'timestamp': DateTime.now().toString().substring(11, 19),
      });
      if (_recentEvents.length > 10) {
        _recentEvents.removeLast();
      }
    });
  }

  void _trackSimpleEvent() {
    widget.iforevents.track(
      event: TrackEvent(eventName: 'simple_event_tracked'),
    );
    _addToRecentEvents('simple_event_tracked', {});
    setState(() {
      _buttonClickCount++;
    });
  }

  void _trackEventWithProperties() {
    final properties = {
      'event_category': 'demo',
      'interaction_type': 'button_click',
      'feature': 'analytics_demo',
      'timestamp': DateTime.now().toIso8601String(),
    };

    widget.iforevents.track(
      event: TrackEvent(
        eventName: 'event_with_properties',
        properties: properties,
      ),
    );
    _addToRecentEvents('event_with_properties', properties);
    setState(() {
      _buttonClickCount++;
    });
  }

  void _trackScreenEvent() {
    final properties = {
      'screen_name': 'analytics_demo',
      'screen_class': 'AnalyticsDemoScreen',
      'view_duration': '${DateTime.now().millisecondsSinceEpoch}ms',
    };

    widget.iforevents.track(
      event: TrackEvent(
        eventName: 'screen_event_tracked',
        eventType: EventType.screen,
        properties: properties,
      ),
    );
    _addToRecentEvents('screen_event_tracked', properties);
    setState(() {
      _customEventCount++;
    });
  }

  void _trackProductViewed() {
    final properties = {
      'product_id': 'prod_${DateTime.now().millisecondsSinceEpoch}',
      'product_name': 'Demo Product',
      'product_category': 'Electronics',
      'product_price': 99.99,
      'currency': 'USD',
    };

    widget.iforevents.track(
      event: TrackEvent(eventName: 'product_viewed', properties: properties),
    );
    _addToRecentEvents('product_viewed', properties);
    setState(() {
      _customEventCount++;
    });
  }

  void _trackAddToCart() {
    final properties = {
      'product_id': 'prod_cart_${DateTime.now().millisecondsSinceEpoch}',
      'product_name': 'Cart Demo Product',
      'quantity': 2,
      'price': 49.99,
      'cart_total': 99.98,
      'currency': 'USD',
    };

    widget.iforevents.track(
      event: TrackEvent(eventName: 'add_to_cart', properties: properties),
    );
    _addToRecentEvents('add_to_cart', properties);
    setState(() {
      _customEventCount++;
    });
  }

  void _trackPurchase() {
    final properties = {
      'order_id': 'order_${DateTime.now().millisecondsSinceEpoch}',
      'total_amount': 149.97,
      'currency': 'USD',
      'payment_method': 'credit_card',
      'items_count': 3,
      'discount_applied': 10.00,
    };

    widget.iforevents.track(
      event: TrackEvent(
        eventName: 'purchase_completed',
        properties: properties,
      ),
    );
    _addToRecentEvents('purchase_completed', properties);
    setState(() {
      _customEventCount++;
    });
  }

  void _trackFeatureUsage() {
    final properties = {
      'feature_name': 'analytics_tracking',
      'feature_category': 'core',
      'usage_count': _customEventCount + 1,
      'user_level': 'advanced',
    };

    widget.iforevents.track(
      event: TrackEvent(eventName: 'feature_used', properties: properties),
    );
    _addToRecentEvents('feature_used', properties);
    setState(() {
      _customEventCount++;
    });
  }

  void _trackContentShared() {
    final properties = {
      'content_type': 'analytics_demo',
      'content_id': 'demo_screen',
      'share_method': 'social_media',
      'platform': 'twitter',
    };

    widget.iforevents.track(
      event: TrackEvent(eventName: 'content_shared', properties: properties),
    );
    _addToRecentEvents('content_shared', properties);
    setState(() {
      _customEventCount++;
    });
  }

  void _trackTutorialCompleted() {
    final properties = {
      'tutorial_name': 'analytics_demo',
      'completion_time': '${DateTime.now().millisecondsSinceEpoch}ms',
      'steps_completed': 5,
      'total_steps': 5,
      'completion_rate': 100,
    };

    widget.iforevents.track(
      event: TrackEvent(
        eventName: 'tutorial_completed',
        properties: properties,
      ),
    );
    _addToRecentEvents('tutorial_completed', properties);
    setState(() {
      _customEventCount++;
    });
  }

  void _clearStats() {
    setState(() {
      _buttonClickCount = 0;
      _customEventCount = 0;
      _recentEvents.clear();
    });

    widget.iforevents.track(
      event: TrackEvent(
        eventName: 'stats_cleared',
        properties: {
          'cleared_at': DateTime.now().toIso8601String(),
          'screen': 'analytics_demo',
        },
      ),
    );
  }

  void _generateRandomEvents() {
    final eventNames = [
      'random_action_1',
      'random_action_2',
      'random_action_3',
      'user_interaction',
      'feature_discovered',
    ];

    for (int i = 0; i < 3; i++) {
      final eventName = eventNames[i % eventNames.length];
      final properties = {
        'random_property': 'value_$i',
        'generated_at': DateTime.now().toIso8601String(),
        'batch_id': DateTime.now().millisecondsSinceEpoch,
      };

      widget.iforevents.track(
        event: TrackEvent(eventName: eventName, properties: properties),
      );
      _addToRecentEvents(eventName, properties);
    }

    setState(() {
      _customEventCount += 3;
    });
  }
}
