import 'package:flutter/material.dart';
import 'package:iforevents/iforevents.dart';

class ProfileScreen extends StatefulWidget {
  final Iforevents iforevents;

  const ProfileScreen({super.key, required this.iforevents});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  String _selectedPlan = 'free';

  @override
  void initState() {
    super.initState();
    // Track screen view
    widget.iforevents.track(
      event: TrackEvent(
        eventName: 'screen_viewed',
        properties: {'screen_name': 'profile', 'screen_class': 'ProfileScreen'},
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        backgroundColor: Colors.green,
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
                      'User Profile',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Update your profile information and see how user identification works with IforEvents.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Full Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              onChanged: (value) {
                widget.iforevents.track(
                  event: TrackEvent(
                    eventName: 'form_field_edited',
                    properties: {
                      'field_name': 'name',
                      'field_length': value.length,
                      'screen': 'profile',
                    },
                  ),
                );
              },
            ),
            SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email Address',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
              onChanged: (value) {
                widget.iforevents.track(
                  event: TrackEvent(
                    eventName: 'form_field_edited',
                    properties: {
                      'field_name': 'email',
                      'field_length': value.length,
                      'screen': 'profile',
                    },
                  ),
                );
              },
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedPlan,
              decoration: InputDecoration(
                labelText: 'Subscription Plan',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.card_membership),
              ),
              items: [
                DropdownMenuItem(value: 'free', child: Text('Free Plan')),
                DropdownMenuItem(value: 'basic', child: Text('Basic Plan')),
                DropdownMenuItem(value: 'premium', child: Text('Premium Plan')),
                DropdownMenuItem(
                  value: 'enterprise',
                  child: Text('Enterprise Plan'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedPlan = value;
                  });
                  widget.iforevents.track(
                    event: TrackEvent(
                      eventName: 'plan_selected',
                      properties: {
                        'selected_plan': value,
                        'previous_plan': _selectedPlan,
                        'screen': 'profile',
                      },
                    ),
                  );
                }
              },
            ),
            SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _updateProfile,
              icon: Icon(Icons.save, color: Colors.white),
              label: Text(
                'Update Profile',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _resetUserData,
              icon: Icon(Icons.refresh, color: Colors.red),
              label: Text(
                'Reset User Data',
                style: TextStyle(color: Colors.red),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.red),
                padding: EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            SizedBox(height: 24),
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info, color: Colors.blue),
                        SizedBox(width: 8),
                        Text(
                          'About User Identification',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade800,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      'When you update your profile, IforEvents will automatically identify you across all integrated analytics platforms. Device information is collected automatically.',
                      style: TextStyle(color: Colors.blue.shade700),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _updateProfile() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();

    if (name.isEmpty || email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill in all required fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Track the update attempt
    widget.iforevents.track(
      event: TrackEvent(
        eventName: 'profile_update_attempted',
        properties: {
          'has_name': name.isNotEmpty,
          'has_email': email.isNotEmpty,
          'selected_plan': _selectedPlan,
          'name_length': name.length,
          'email_domain': email.contains('@')
              ? email.split('@').last
              : 'invalid',
        },
      ),
    );

    try {
      // Update user identification
      await widget.iforevents.identify(
        event: IdentifyEvent(
          customID: 'user_${email.hashCode}',
          properties: {
            'name': name,
            'email': email,
            'plan': _selectedPlan,
            'profile_updated_at': DateTime.now().toIso8601String(),
            'profile_completion': 100,
          },
        ),
      );

      // Track successful update
      widget.iforevents.track(
        event: TrackEvent(
          eventName: 'profile_updated',
          properties: {
            'update_success': true,
            'plan': _selectedPlan,
            'update_timestamp': DateTime.now().toIso8601String(),
          },
        ),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      // Track failed update
      widget.iforevents.track(
        event: TrackEvent(
          eventName: 'profile_update_failed',
          properties: {
            'error_type': 'identification_failed',
            'update_success': false,
          },
        ),
      );

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update profile. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _resetUserData() async {
    try {
      await widget.iforevents.reset();

      widget.iforevents.track(
        event: TrackEvent(
          eventName: 'user_data_reset',
          properties: {
            'reset_timestamp': DateTime.now().toIso8601String(),
            'reset_source': 'profile_screen',
          },
        ),
      );

      setState(() {
        _nameController.clear();
        _emailController.clear();
        _selectedPlan = 'free';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('User data reset successfully!'),
          backgroundColor: Colors.blue,
        ),
      );
    } catch (e) {
      widget.iforevents.track(
        event: TrackEvent(
          eventName: 'user_data_reset_failed',
          properties: {'error_type': 'reset_failed', 'reset_success': false},
        ),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to reset user data. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
