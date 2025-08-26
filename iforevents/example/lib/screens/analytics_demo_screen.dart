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
          _EventTypeSection(
            context: context,
            title: 'Basic Events',
            buttons: [
              _EventButton(
                title: 'Simple Track Event',
                description: 'Track a basic event without properties',
                color: Colors.blue,
                icon: Icons.track_changes,
                onPressed: () => _trackSimpleEvent(),
              ),
              _EventButton(
                title: 'Event with Properties',
                description: 'Track an event with custom properties',
                color: Colors.green,
                icon: Icons.list,
                onPressed: () => _trackEventWithProperties(),
              ),
              _EventButton(
                title: 'Screen Event',
                description: 'Track a screen view event',
                color: Colors.orange,
                icon: Icons.screen_lock_portrait,
                onPressed: () => _trackScreenEvent(),
              ),
            ],
          ),
          SizedBox(height: 16),
          _EventTypeSection(
            context: context,
            title: 'E-commerce Events',
            buttons: [
              _EventButton(
                title: 'Product Viewed',
                description: 'Track when a user views a product',
                color: Colors.cyan,
                icon: Icons.shopping_bag,
                onPressed: () => _trackProductViewed(),
              ),
              _EventButton(
                title: 'Add to Cart',
                description: 'Track when a product is added to cart',
                color: Colors.indigo,
                icon: Icons.add_shopping_cart,
                onPressed: () => _trackAddToCart(),
              ),
              _EventButton(
                title: 'Purchase Completed',
                description: 'Track a completed purchase',
                color: Colors.teal,
                icon: Icons.payment,
                onPressed: () => _trackPurchase(),
              ),
            ],
          ),
          SizedBox(height: 16),
          _EventTypeSection(
            context: context,
            title: 'User Engagement',
            buttons: [
              _EventButton(
                title: 'Feature Used',
                description: 'Track feature usage with details',
                color: Colors.deepPurple,
                icon: Icons.star,
                onPressed: () => _trackFeatureUsage(),
              ),
              _EventButton(
                title: 'Content Shared',
                description: 'Track content sharing behavior',
                color: Colors.pink,
                icon: Icons.share,
                onPressed: () => _trackContentShared(),
              ),
              _EventButton(
                title: 'Tutorial Completed',
                description: 'Track tutorial or onboarding completion',
                color: Colors.amber,
                icon: Icons.school,
                onPressed: () => _trackTutorialCompleted(),
              ),
            ],
          ),
          SizedBox(height: 16),
          _StatsCard(
            buttonClickCount: _buttonClickCount,
            customEventCount: _customEventCount,
          ),
          SizedBox(height: 16),
          _RecentEventsCard(recentEvents: _recentEvents),
          SizedBox(height: 16),
          Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _clearStats,
                  icon: Icon(Icons.clear_all, color: Colors.white),
                  label: Text(
                    'Clear Stats',
                    style: TextStyle(color: Colors.white),
                  ),
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
          ),
        ],
      ),
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

class _StatsCard extends StatelessWidget {
  const _StatsCard({
    required this.buttonClickCount,
    required this.customEventCount,
  });

  final int buttonClickCount;
  final int customEventCount;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.purple.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'User Stats',
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
                _StatItem(
                  label: 'Button Clicks',
                  value: buttonClickCount.toString(),
                  icon: Icons.touch_app,
                ),
                _StatItem(
                  label: 'Custom Events',
                  value: customEventCount.toString(),
                  icon: Icons.event,
                ),
                _StatItem(
                  label: 'Total Events',
                  value: (buttonClickCount + customEventCount).toString(),
                  icon: Icons.analytics,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentEventsCard extends StatelessWidget {
  const _RecentEventsCard({required this.recentEvents});

  final List<Map<String, dynamic>> recentEvents;

  @override
  Widget build(BuildContext context) {
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
            if (recentEvents.isEmpty)
              Text(
                'No events tracked yet. Try tracking some events above!',
                style: TextStyle(color: Colors.grey.shade600),
              )
            else
              Column(
                children: recentEvents.take(5).map((event) {
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
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
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
}

class _EventButton extends StatelessWidget {
  const _EventButton({
    required this.title,
    required this.description,
    required this.color,
    required this.icon,
    required this.onPressed,
  });

  final String title;
  final String description;
  final Color color;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
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
}

class _EventTypeSection extends StatelessWidget {
  const _EventTypeSection({
    required this.context,
    required this.title,
    required this.buttons,
  });

  final BuildContext context;
  final String title;
  final List<Widget> buttons;

  @override
  Widget build(BuildContext context) {
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
}
