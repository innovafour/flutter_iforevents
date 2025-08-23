import 'package:flutter/material.dart';
import 'package:iforevents/iforevents.dart';

class HomeScreen extends StatefulWidget {
  final Iforevents iforevents;

  const HomeScreen({super.key, required this.iforevents});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
            _NavigationButton(
              iforevents: widget.iforevents,
              context: context,
              title: 'Profile Screen',
              route: '/profile',
              icon: Icons.person,
              color: Colors.green,
            ),
            SizedBox(height: 12),
            _NavigationButton(
              iforevents: widget.iforevents,
              context: context,
              title: 'Settings Screen',
              route: '/settings',
              icon: Icons.settings,
              color: Colors.orange,
            ),
            SizedBox(height: 12),
            _NavigationButton(
              iforevents: widget.iforevents,
              context: context,
              title: 'Analytics Demo',
              route: '/analytics',
              icon: Icons.analytics,
              color: Colors.purple,
            ),
            SizedBox(height: 12),
            _ActionButton(
              title: 'IForevents API',
              icon: Icons.event,
              color: Colors.blueGrey,
              onPressed: () {
                Navigator.pushNamed(context, '/iforevents');
              },
            ),
            SizedBox(height: 12),
            _ActionButton(
              title: 'IForevents API 2',
              icon: Icons.event,
              color: Colors.blueAccent,
              onPressed: () {
                Navigator.pushNamed(context, '/iforevents/2');
              },
            ),
            SizedBox(height: 24),
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 16),
            _ActionButton(
              title: 'Track Button Click',
              icon: Icons.touch_app,
              color: Colors.blue,
              onPressed: () => _trackButtonClick(),
            ),
            SizedBox(height: 12),
            _ActionButton(
              title: 'Track Custom Event',
              icon: Icons.event,
              color: Colors.red,
              onPressed: () => _trackCustomEvent(),
            ),
          ],
        ),
      ),
    );
  }

  void _trackButtonClick() {
    widget.iforevents.track(
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
    widget.iforevents.track(
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

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.title,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
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
}

class _NavigationButton extends StatelessWidget {
  const _NavigationButton({
    required this.iforevents,
    required this.context,
    required this.title,
    required this.route,
    required this.icon,
    required this.color,
  });

  final Iforevents iforevents;
  final BuildContext context;
  final String title;
  final String route;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
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
}
