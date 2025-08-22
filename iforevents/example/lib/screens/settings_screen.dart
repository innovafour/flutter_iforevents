import 'package:flutter/material.dart';
import 'package:iforevents/iforevents.dart';

class SettingsScreen extends StatefulWidget {
  final Iforevents iforevents;

  const SettingsScreen({super.key, required this.iforevents});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _analyticsEnabled = true;
  bool _crashReportingEnabled = true;
  bool _performanceMonitoring = false;
  String _selectedTheme = 'system';
  String _selectedLanguage = 'english';

  @override
  void initState() {
    super.initState();
    // Track screen view
    widget.iforevents.track(
      event: TrackEvent(
        eventName: 'screen_viewed',
        properties: {
          'screen_name': 'settings',
          'screen_class': 'SettingsScreen',
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        backgroundColor: Colors.orange,
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
                    'App Settings',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Configure your app preferences and see how settings changes are tracked.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16),
          _buildSectionTitle('Analytics & Privacy'),
          _buildSettingTile(
            title: 'Analytics Enabled',
            subtitle: 'Allow collection of usage analytics',
            value: _analyticsEnabled,
            onChanged: (value) {
              setState(() {
                _analyticsEnabled = value;
              });
              _trackSettingChange('analytics_enabled', value);
            },
          ),
          _buildSettingTile(
            title: 'Crash Reporting',
            subtitle: 'Help improve the app by sending crash reports',
            value: _crashReportingEnabled,
            onChanged: (value) {
              setState(() {
                _crashReportingEnabled = value;
              });
              _trackSettingChange('crash_reporting_enabled', value);
            },
          ),
          _buildSettingTile(
            title: 'Performance Monitoring',
            subtitle: 'Monitor app performance and optimization',
            value: _performanceMonitoring,
            onChanged: (value) {
              setState(() {
                _performanceMonitoring = value;
              });
              _trackSettingChange('performance_monitoring_enabled', value);
            },
          ),
          SizedBox(height: 16),
          _buildSectionTitle('Appearance'),
          _buildDropdownTile(
            title: 'Theme',
            subtitle: 'Choose your preferred theme',
            value: _selectedTheme,
            items: [
              {'value': 'light', 'label': 'Light Theme'},
              {'value': 'dark', 'label': 'Dark Theme'},
              {'value': 'system', 'label': 'System Default'},
            ],
            onChanged: (value) {
              setState(() {
                _selectedTheme = value;
              });
              _trackSettingChange('theme_selected', value);
            },
          ),
          SizedBox(height: 16),
          _buildSectionTitle('Localization'),
          _buildDropdownTile(
            title: 'Language',
            subtitle: 'Select your preferred language',
            value: _selectedLanguage,
            items: [
              {'value': 'english', 'label': 'English'},
              {'value': 'spanish', 'label': 'Español'},
              {'value': 'french', 'label': 'Français'},
              {'value': 'german', 'label': 'Deutsch'},
            ],
            onChanged: (value) {
              setState(() {
                _selectedLanguage = value;
              });
              _trackSettingChange('language_selected', value);
            },
          ),
          SizedBox(height: 24),
          _buildActionButtons(),
          SizedBox(height: 24),
          _buildInfoCard(),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: Colors.orange.shade700,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 4),
      child: SwitchListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        value: value,
        onChanged: onChanged,
        activeColor: Colors.orange,
      ),
    );
  }

  Widget _buildDropdownTile({
    required String title,
    required String subtitle,
    required String value,
    required List<Map<String, String>> items,
    required ValueChanged<String> onChanged,
  }) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: DropdownButton<String>(
          value: value,
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item['value'],
              child: Text(item['label']!),
            );
          }).toList(),
          onChanged: (newValue) {
            if (newValue != null) {
              onChanged(newValue);
            }
          },
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
            onPressed: _saveSettings,
            icon: Icon(Icons.save, color: Colors.white),
            label: Text('Save Settings', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
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
            onPressed: _resetToDefaults,
            icon: Icon(Icons.restore, color: Colors.orange),
            label: Text(
              'Reset to Defaults',
              style: TextStyle(color: Colors.orange),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.orange),
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

  Widget _buildInfoCard() {
    return Card(
      color: Colors.orange.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info, color: Colors.orange),
                SizedBox(width: 8),
                Text(
                  'Settings Tracking',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade800,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              'Every setting change is tracked using IforEvents. This helps understand user preferences and app usage patterns.',
              style: TextStyle(color: Colors.orange.shade700),
            ),
          ],
        ),
      ),
    );
  }

  void _trackSettingChange(String settingName, dynamic value) {
    widget.iforevents.track(
      event: TrackEvent(
        eventName: 'setting_changed',
        properties: {
          'setting_name': settingName,
          'setting_value': value.toString(),
          'screen': 'settings',
          'timestamp': DateTime.now().toIso8601String(),
        },
      ),
    );
  }

  void _saveSettings() {
    widget.iforevents.track(
      event: TrackEvent(
        eventName: 'settings_saved',
        properties: {
          'analytics_enabled': _analyticsEnabled,
          'crash_reporting_enabled': _crashReportingEnabled,
          'performance_monitoring': _performanceMonitoring,
          'selected_theme': _selectedTheme,
          'selected_language': _selectedLanguage,
          'save_timestamp': DateTime.now().toIso8601String(),
        },
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Settings saved successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _resetToDefaults() {
    widget.iforevents.track(
      event: TrackEvent(
        eventName: 'settings_reset_to_defaults',
        properties: {
          'previous_analytics_enabled': _analyticsEnabled,
          'previous_crash_reporting': _crashReportingEnabled,
          'previous_performance_monitoring': _performanceMonitoring,
          'previous_theme': _selectedTheme,
          'previous_language': _selectedLanguage,
          'reset_timestamp': DateTime.now().toIso8601String(),
        },
      ),
    );

    setState(() {
      _analyticsEnabled = true;
      _crashReportingEnabled = true;
      _performanceMonitoring = false;
      _selectedTheme = 'system';
      _selectedLanguage = 'english';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Settings reset to defaults!'),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
