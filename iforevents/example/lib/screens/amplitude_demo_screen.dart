import 'package:flutter/material.dart';
import 'package:iforevents/iforevents.dart';
import 'package:iforevents_amplitude/iforevents_amplitude.dart';

class AmplitudeDemoScreen extends StatefulWidget {
  final Iforevents iforevents;
  final AmplitudeIntegration amplitudeIntegration;

  const AmplitudeDemoScreen({
    super.key,
    required this.iforevents,
    required this.amplitudeIntegration,
  });

  @override
  State<AmplitudeDemoScreen> createState() => _AmplitudeDemoScreenState();
}

class _AmplitudeDemoScreenState extends State<AmplitudeDemoScreen> {
  int _eventCount = 0;
  int _revenueEventCount = 0;
  double _totalRevenue = 0.0;
  String _currentGroup = 'None';
  final List<Map<String, dynamic>> _recentEvents = [];

  @override
  void initState() {
    super.initState();
    // Track screen view
    _trackScreenView();
  }

  void _trackScreenView() {
    widget.iforevents.track(
      event: TrackEvent(
        eventName: 'amplitude_demo_screen_viewed',
        properties: {
          'screen_name': 'amplitude_demo',
          'screen_class': 'AmplitudeDemoScreen',
          'timestamp': DateTime.now().toIso8601String(),
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Amplitude Demo'),
        backgroundColor: const Color(0xFF2B2D42),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showAmplitudeInfo,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildHeaderCard(),
          const SizedBox(height: 16),
          _buildStatsCard(),
          const SizedBox(height: 16),
          _buildBasicEventsSection(),
          const SizedBox(height: 16),
          _buildUserPropertiesSection(),
          const SizedBox(height: 16),
          _buildRevenueTrackingSection(),
          const SizedBox(height: 16),
          _buildGroupAnalyticsSection(),
          const SizedBox(height: 16),
          _buildAdvancedFeaturesSection(),
          const SizedBox(height: 16),
          _buildRecentEventsCard(),
          const SizedBox(height: 16),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Card(
      elevation: 2,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [const Color(0xFF2B2D42), const Color(0xFF8D99AE)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.analytics,
                    color: Color(0xFF2B2D42),
                    size: 32,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Amplitude Analytics',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Advanced Product Analytics',
                        style: TextStyle(fontSize: 14, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(color: Colors.white24),
            const SizedBox(height: 8),
            const Text(
              'Amplitude provides powerful product analytics to help you understand user behavior, build better products, and grow your business.',
              style: TextStyle(fontSize: 13, color: Colors.white, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Session Statistics',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2B2D42),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  'Events',
                  _eventCount.toString(),
                  Icons.event,
                  const Color(0xFF8D99AE),
                ),
                _buildStatItem(
                  'Revenue Events',
                  _revenueEventCount.toString(),
                  Icons.attach_money,
                  const Color(0xFFEF233C),
                ),
                _buildStatItem(
                  'Total Revenue',
                  '\$${_totalRevenue.toStringAsFixed(2)}',
                  Icons.trending_up,
                  const Color(0xFF06D6A0),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 32),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildBasicEventsSection() {
    return _buildSection(
      title: 'Basic Events',
      icon: Icons.track_changes,
      children: [
        _buildEventButton(
          title: 'Simple Event',
          description: 'Track a basic event without properties',
          icon: Icons.play_arrow,
          color: const Color(0xFF8D99AE),
          onPressed: _trackSimpleEvent,
        ),
        const SizedBox(height: 8),
        _buildEventButton(
          title: 'Event with Properties',
          description: 'Track an event with custom properties',
          icon: Icons.format_list_bulleted,
          color: const Color(0xFF06D6A0),
          onPressed: _trackEventWithProperties,
        ),
        const SizedBox(height: 8),
        _buildEventButton(
          title: 'Button Click',
          description: 'Track user interaction with UI elements',
          icon: Icons.touch_app,
          color: const Color(0xFFFFD60A),
          onPressed: _trackButtonClick,
        ),
      ],
    );
  }

  Widget _buildUserPropertiesSection() {
    return _buildSection(
      title: 'User Properties',
      icon: Icons.person,
      children: [
        _buildEventButton(
          title: 'Set User Properties',
          description: 'Update user profile with custom properties',
          icon: Icons.person_add,
          color: const Color(0xFF8D99AE),
          onPressed: _setUserProperties,
        ),
        const SizedBox(height: 8),
        _buildEventButton(
          title: 'Update Subscription',
          description: 'Track subscription tier changes',
          icon: Icons.card_membership,
          color: const Color(0xFFEF233C),
          onPressed: _updateSubscription,
        ),
        const SizedBox(height: 8),
        _buildEventButton(
          title: 'Set User Location',
          description: 'Update user geographic information',
          icon: Icons.location_on,
          color: const Color(0xFF06D6A0),
          onPressed: _setUserLocation,
        ),
      ],
    );
  }

  Widget _buildRevenueTrackingSection() {
    return _buildSection(
      title: 'Revenue Tracking',
      icon: Icons.attach_money,
      children: [
        _buildEventButton(
          title: 'Track Purchase',
          description: 'Record a product purchase with revenue',
          icon: Icons.shopping_cart,
          color: const Color(0xFF06D6A0),
          onPressed: _trackPurchase,
        ),
        const SizedBox(height: 8),
        _buildEventButton(
          title: 'Track Subscription',
          description: 'Record subscription revenue',
          icon: Icons.subscriptions,
          color: const Color(0xFFEF233C),
          onPressed: _trackSubscription,
        ),
        const SizedBox(height: 8),
        _buildEventButton(
          title: 'Track In-App Purchase',
          description: 'Record in-app purchase revenue',
          icon: Icons.phone_android,
          color: const Color(0xFFFFD60A),
          onPressed: _trackInAppPurchase,
        ),
      ],
    );
  }

  Widget _buildGroupAnalyticsSection() {
    return _buildSection(
      title: 'Group Analytics',
      icon: Icons.group,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            'Current Group: $_currentGroup',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF2B2D42),
            ),
          ),
        ),
        _buildEventButton(
          title: 'Join Company',
          description: 'Add user to a company group',
          icon: Icons.business,
          color: const Color(0xFF8D99AE),
          onPressed: _joinCompany,
        ),
        const SizedBox(height: 8),
        _buildEventButton(
          title: 'Join Team',
          description: 'Add user to a team within company',
          icon: Icons.groups,
          color: const Color(0xFF06D6A0),
          onPressed: _joinTeam,
        ),
        const SizedBox(height: 8),
        _buildEventButton(
          title: 'Update Group Properties',
          description: 'Update properties for a group',
          icon: Icons.edit,
          color: const Color(0xFFFFD60A),
          onPressed: _updateGroupProperties,
        ),
      ],
    );
  }

  Widget _buildAdvancedFeaturesSection() {
    return _buildSection(
      title: 'Advanced Features',
      icon: Icons.settings_suggest,
      children: [
        _buildEventButton(
          title: 'Track User Journey',
          description: 'Track multi-step user flow',
          icon: Icons.route,
          color: const Color(0xFF8D99AE),
          onPressed: _trackUserJourney,
        ),
        const SizedBox(height: 8),
        _buildEventButton(
          title: 'A/B Test Event',
          description: 'Track experiment participation',
          icon: Icons.science,
          color: const Color(0xFFEF233C),
          onPressed: _trackABTest,
        ),
        const SizedBox(height: 8),
        _buildEventButton(
          title: 'Flush Events',
          description: 'Force send all pending events',
          icon: Icons.send,
          color: const Color(0xFF06D6A0),
          onPressed: _flushEvents,
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: const Color(0xFF2B2D42)),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2B2D42),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildEventButton({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          border: Border.all(color: color.withOpacity(0.2)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: color),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentEventsCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.history, color: Color(0xFF2B2D42)),
                SizedBox(width: 8),
                Text(
                  'Recent Events',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2B2D42),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_recentEvents.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(
                  child: Text(
                    'No events tracked yet.\nStart tracking events above!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _recentEvents.take(5).length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final event = _recentEvents[index];
                  return ListTile(
                    dense: true,
                    leading: Icon(
                      _getEventIcon(event['name']),
                      color: _getEventColor(event['name']),
                      size: 20,
                    ),
                    title: Text(
                      event['name'] ?? 'Unknown Event',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    subtitle: Text(
                      '${event['properties']?.length ?? 0} properties',
                      style: const TextStyle(fontSize: 11),
                    ),
                    trailing: Text(
                      event['timestamp'] ?? '',
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  );
                },
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
            icon: const Icon(Icons.clear_all, color: Colors.white),
            label: const Text(
              'Clear Statistics',
              style: TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF233C),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _generateRandomEvents,
            icon: const Icon(Icons.shuffle, color: Color(0xFF2B2D42)),
            label: const Text(
              'Generate Test Events',
              style: TextStyle(color: Color(0xFF2B2D42)),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFF2B2D42)),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Event tracking methods
  void _addToRecentEvents(String eventName, Map<String, dynamic> properties) {
    setState(() {
      _recentEvents.insert(0, {
        'name': eventName,
        'properties': properties,
        'timestamp': DateTime.now().toString().substring(11, 19),
      });
      if (_recentEvents.length > 20) {
        _recentEvents.removeLast();
      }
    });
  }

  void _trackSimpleEvent() {
    widget.iforevents.track(
      event: TrackEvent(eventName: 'amplitude_simple_event'),
    );
    _addToRecentEvents('amplitude_simple_event', {});
    setState(() => _eventCount++);
    _showSnackBar('Simple event tracked!');
  }

  void _trackEventWithProperties() {
    final properties = {
      'event_category': 'amplitude_demo',
      'interaction_type': 'button_click',
      'feature': 'properties_tracking',
      'timestamp': DateTime.now().toIso8601String(),
      'session_duration': '${DateTime.now().millisecondsSinceEpoch}ms',
    };

    widget.iforevents.track(
      event: TrackEvent(
        eventName: 'amplitude_event_with_properties',
        properties: properties,
      ),
    );
    _addToRecentEvents('amplitude_event_with_properties', properties);
    setState(() => _eventCount++);
    _showSnackBar('Event with properties tracked!');
  }

  void _trackButtonClick() {
    final properties = {
      'button_id': 'demo_button_${DateTime.now().millisecondsSinceEpoch}',
      'button_text': 'Button Click',
      'screen_name': 'amplitude_demo',
      'click_count': _eventCount + 1,
    };

    widget.iforevents.track(
      event: TrackEvent(
        eventName: 'amplitude_button_clicked',
        properties: properties,
      ),
    );
    _addToRecentEvents('amplitude_button_clicked', properties);
    setState(() => _eventCount++);
    _showSnackBar('Button click tracked!');
  }

  void _setUserProperties() {
    final properties = {
      'user_tier': 'premium',
      'account_age_days': 30,
      'preferred_language': 'en',
      'notifications_enabled': true,
      'last_login': DateTime.now().toIso8601String(),
    };

    widget.iforevents.identify(
      event: IdentifyEvent(
        customID: 'user_${DateTime.now().millisecondsSinceEpoch}',
        properties: properties,
      ),
    );
    _addToRecentEvents('user_properties_set', properties);
    setState(() => _eventCount++);
    _showSnackBar('User properties updated!');
  }

  void _updateSubscription() {
    final properties = {
      'subscription_tier': 'Pro',
      'subscription_price': 29.99,
      'subscription_interval': 'monthly',
      'trial_days_remaining': 7,
      'auto_renew': true,
    };

    widget.iforevents.track(
      event: TrackEvent(
        eventName: 'amplitude_subscription_updated',
        properties: properties,
      ),
    );
    _addToRecentEvents('amplitude_subscription_updated', properties);
    setState(() => _eventCount++);
    _showSnackBar('Subscription status updated!');
  }

  void _setUserLocation() {
    final properties = {
      'country': 'United States',
      'region': 'California',
      'city': 'San Francisco',
      'timezone': 'America/Los_Angeles',
      'latitude': 37.7749,
      'longitude': -122.4194,
    };

    widget.iforevents.identify(
      event: IdentifyEvent(
        customID: 'user_${DateTime.now().millisecondsSinceEpoch}',
        properties: properties,
      ),
    );
    _addToRecentEvents('user_location_set', properties);
    setState(() => _eventCount++);
    _showSnackBar('User location updated!');
  }

  void _trackPurchase() {
    final price = 99.99;
    final properties = {
      'product_id': 'prod_${DateTime.now().millisecondsSinceEpoch}',
      'product_name': 'Premium Widget',
      'product_category': 'Electronics',
      'price': price,
      'quantity': 1,
      'currency': 'USD',
      'payment_method': 'credit_card',
    };

    // Track event
    widget.iforevents.track(
      event: TrackEvent(
        eventName: 'amplitude_purchase_completed',
        properties: properties,
      ),
    );

    // Track revenue in Amplitude
    widget.amplitudeIntegration.trackRevenue(
      price: price,
      quantity: 1,
      productId: properties['product_id'] as String,
      revenueType: 'purchase',
    );

    _addToRecentEvents('amplitude_purchase_completed', properties);
    setState(() {
      _eventCount++;
      _revenueEventCount++;
      _totalRevenue += price;
    });
    _showSnackBar('Purchase tracked! Revenue: \$${price.toStringAsFixed(2)}');
  }

  void _trackSubscription() {
    final price = 29.99;
    final properties = {
      'subscription_id': 'sub_${DateTime.now().millisecondsSinceEpoch}',
      'subscription_plan': 'Pro Monthly',
      'price': price,
      'currency': 'USD',
      'billing_cycle': 'monthly',
      'start_date': DateTime.now().toIso8601String(),
    };

    // Track event
    widget.iforevents.track(
      event: TrackEvent(
        eventName: 'amplitude_subscription_started',
        properties: properties,
      ),
    );

    // Track revenue in Amplitude
    widget.amplitudeIntegration.trackRevenue(
      price: price,
      productId: properties['subscription_id'] as String,
      revenueType: 'subscription',
    );

    _addToRecentEvents('amplitude_subscription_started', properties);
    setState(() {
      _eventCount++;
      _revenueEventCount++;
      _totalRevenue += price;
    });
    _showSnackBar(
      'Subscription tracked! Revenue: \$${price.toStringAsFixed(2)}',
    );
  }

  void _trackInAppPurchase() {
    final price = 4.99;
    final properties = {
      'iap_id': 'iap_${DateTime.now().millisecondsSinceEpoch}',
      'iap_name': 'Extra Lives Pack',
      'price': price,
      'quantity': 5,
      'currency': 'USD',
      'platform': 'ios',
    };

    // Track event
    widget.iforevents.track(
      event: TrackEvent(
        eventName: 'amplitude_iap_completed',
        properties: properties,
      ),
    );

    // Track revenue in Amplitude
    widget.amplitudeIntegration.trackRevenue(
      price: price,
      quantity: 1,
      productId: properties['iap_id'] as String,
      revenueType: 'iap',
    );

    _addToRecentEvents('amplitude_iap_completed', properties);
    setState(() {
      _eventCount++;
      _revenueEventCount++;
      _totalRevenue += price;
    });
    _showSnackBar(
      'In-app purchase tracked! Revenue: \$${price.toStringAsFixed(2)}',
    );
  }

  void _joinCompany() {
    final companyId = 'company_${DateTime.now().millisecondsSinceEpoch}';
    widget.amplitudeIntegration.setGroup('company', companyId);

    final properties = {
      'company_id': companyId,
      'company_name': 'Acme Corp',
      'joined_at': DateTime.now().toIso8601String(),
    };

    widget.iforevents.track(
      event: TrackEvent(
        eventName: 'amplitude_company_joined',
        properties: properties,
      ),
    );

    _addToRecentEvents('amplitude_company_joined', properties);
    setState(() {
      _eventCount++;
      _currentGroup = 'Acme Corp';
    });
    _showSnackBar('Joined company group!');
  }

  void _joinTeam() {
    final teamId = 'team_${DateTime.now().millisecondsSinceEpoch}';
    widget.amplitudeIntegration.setGroup('team', teamId);

    final properties = {
      'team_id': teamId,
      'team_name': 'Engineering Team',
      'team_size': 15,
      'joined_at': DateTime.now().toIso8601String(),
    };

    widget.iforevents.track(
      event: TrackEvent(
        eventName: 'amplitude_team_joined',
        properties: properties,
      ),
    );

    _addToRecentEvents('amplitude_team_joined', properties);
    setState(() {
      _eventCount++;
      _currentGroup = 'Engineering Team';
    });
    _showSnackBar('Joined team group!');
  }

  void _updateGroupProperties() {
    // This would require the Amplitude Identify object
    final properties = {
      'group_type': 'company',
      'group_value': _currentGroup,
      'updated_at': DateTime.now().toIso8601String(),
    };

    widget.iforevents.track(
      event: TrackEvent(
        eventName: 'amplitude_group_properties_updated',
        properties: properties,
      ),
    );

    _addToRecentEvents('amplitude_group_properties_updated', properties);
    setState(() => _eventCount++);
    _showSnackBar('Group properties updated!');
  }

  void _trackUserJourney() {
    final steps = [
      'onboarding_started',
      'profile_created',
      'tutorial_completed',
      'first_action_taken',
    ];

    for (var i = 0; i < steps.length; i++) {
      final properties = {
        'step': i + 1,
        'total_steps': steps.length,
        'step_name': steps[i],
        'timestamp': DateTime.now().toIso8601String(),
      };

      widget.iforevents.track(
        event: TrackEvent(
          eventName: 'amplitude_journey_${steps[i]}',
          properties: properties,
        ),
      );

      _addToRecentEvents('amplitude_journey_${steps[i]}', properties);
    }

    setState(() => _eventCount += steps.length);
    _showSnackBar('User journey tracked (${steps.length} steps)!');
  }

  void _trackABTest() {
    final properties = {
      'experiment_id': 'exp_${DateTime.now().millisecondsSinceEpoch}',
      'experiment_name': 'button_color_test',
      'variant': 'blue_variant',
      'variant_group': 'A',
      'started_at': DateTime.now().toIso8601String(),
    };

    widget.iforevents.track(
      event: TrackEvent(
        eventName: 'amplitude_experiment_started',
        properties: properties,
      ),
    );

    _addToRecentEvents('amplitude_experiment_started', properties);
    setState(() => _eventCount++);
    _showSnackBar('A/B test participation tracked!');
  }

  void _flushEvents() {
    widget.amplitudeIntegration.flush();
    _showSnackBar('Flushing all pending events to Amplitude!');
  }

  void _clearStats() {
    setState(() {
      _eventCount = 0;
      _revenueEventCount = 0;
      _totalRevenue = 0.0;
      _currentGroup = 'None';
      _recentEvents.clear();
    });

    widget.iforevents.track(
      event: TrackEvent(
        eventName: 'amplitude_stats_cleared',
        properties: {'cleared_at': DateTime.now().toIso8601String()},
      ),
    );

    _showSnackBar('Statistics cleared!');
  }

  void _generateRandomEvents() {
    final eventTypes = [
      ('amplitude_random_action_1', 'Random user action'),
      ('amplitude_random_action_2', 'Feature exploration'),
      ('amplitude_random_action_3', 'Content interaction'),
    ];

    for (var i = 0; i < eventTypes.length; i++) {
      final properties = {
        'random_property': 'value_$i',
        'generated_at': DateTime.now().toIso8601String(),
        'batch_id': DateTime.now().millisecondsSinceEpoch,
        'description': eventTypes[i].$2,
      };

      widget.iforevents.track(
        event: TrackEvent(eventName: eventTypes[i].$1, properties: properties),
      );
      _addToRecentEvents(eventTypes[i].$1, properties);
    }

    setState(() => _eventCount += eventTypes.length);
    _showSnackBar('Generated ${eventTypes.length} test events!');
  }

  void _showAmplitudeInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About Amplitude'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Amplitude Analytics Features:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 12),
              Text('• Event tracking with properties'),
              Text('• User identification and properties'),
              Text('• Revenue and conversion tracking'),
              Text('• Group analytics for B2B'),
              Text('• User journey analysis'),
              Text('• A/B testing support'),
              Text('• Real-time event flushing'),
              Text('• Automatic session tracking'),
              SizedBox(height: 12),
              Text(
                'This demo showcases Amplitude integration with IforEvents.',
                style: TextStyle(fontSize: 13, fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  IconData _getEventIcon(String eventName) {
    if (eventName.contains('purchase') || eventName.contains('revenue')) {
      return Icons.shopping_cart;
    } else if (eventName.contains('subscription')) {
      return Icons.subscriptions;
    } else if (eventName.contains('user') || eventName.contains('identify')) {
      return Icons.person;
    } else if (eventName.contains('group') ||
        eventName.contains('company') ||
        eventName.contains('team')) {
      return Icons.group;
    } else if (eventName.contains('journey')) {
      return Icons.route;
    } else if (eventName.contains('experiment')) {
      return Icons.science;
    }
    return Icons.event;
  }

  Color _getEventColor(String eventName) {
    if (eventName.contains('purchase') || eventName.contains('revenue')) {
      return const Color(0xFF06D6A0);
    } else if (eventName.contains('subscription')) {
      return const Color(0xFFEF233C);
    } else if (eventName.contains('user') || eventName.contains('identify')) {
      return const Color(0xFF8D99AE);
    } else if (eventName.contains('group') ||
        eventName.contains('company') ||
        eventName.contains('team')) {
      return const Color(0xFFFFD60A);
    }
    return const Color(0xFF2B2D42);
  }
}
