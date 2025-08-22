import 'package:flutter/material.dart';
import 'package:iforevents/iforevents.dart';

class HomeScreen extends StatelessWidget {
  final Iforevents iforevents;

  const HomeScreen({super.key, required this.iforevents});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('IforEvents Example'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome to IforEvents!',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'This example app demonstrates the core features of the IforEvents analytics package.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Navigation Examples',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 16),
            _buildNavigationButton(
              context,
              'Profile Screen',
              '/profile',
              Icons.person,
              Colors.green,
            ),
            SizedBox(height: 12),
            _buildNavigationButton(
              context,
              'Settings Screen',
              '/settings',
              Icons.settings,
              Colors.orange,
            ),
            SizedBox(height: 12),
            _buildNavigationButton(
              context,
              'Analytics Demo',
              '/analytics',
              Icons.analytics,
              Colors.purple,
            ),
            SizedBox(height: 24),
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 16),
            _buildActionButton(
              'Track Button Click',
              Icons.touch_app,
              Colors.blue,
              () => _trackButtonClick(),
            ),
            SizedBox(height: 12),
            _buildActionButton(
              'Track Custom Event',
              Icons.event,
              Colors.red,
              () => _trackCustomEvent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationButton(
    BuildContext context,
    String title,
    String route,
    IconData icon,
    Color color,
  ) {
    return ElevatedButton.icon(
      onPressed: () {
        iforevents.track(
          event: TrackEvent(
            eventName: 'navigation_button_clicked',
            properties: {'target_screen': route, 'button_title': title},
          ),
        );
        Navigator.pushNamed(context, route);
      },
      icon: Icon(icon, color: Colors.white),
      label: Text(title, style: TextStyle(color: Colors.white)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildActionButton(
    String title,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white),
      label: Text(title, style: TextStyle(color: Colors.white)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _trackButtonClick() {
    iforevents.track(
      event: TrackEvent(
        eventName: 'button_clicked',
        properties: {
          'button_name': 'track_button_click',
          'screen': 'home',
          'timestamp': DateTime.now().toIso8601String(),
        },
      ),
    );
  }

  void _trackCustomEvent() {
    iforevents.track(
      event: TrackEvent(
        eventName: 'custom_event_triggered',
        properties: {
          'event_type': 'user_interaction',
          'feature': 'quick_actions',
          'user_engagement': 'high',
          'session_time': DateTime.now().millisecondsSinceEpoch,
        },
      ),
    );
  }
}
