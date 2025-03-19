import 'package:flutter/material.dart';

class StudentSettings extends StatefulWidget {
  const StudentSettings({super.key});

  @override
  State<StudentSettings> createState() => _StudentSettingsState();
}

class _StudentSettingsState extends State<StudentSettings> {
  bool _darkMode = false;
  double _fontSize = 16.0;
  String _language = 'English';
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Settings'),
        backgroundColor: Colors.lightBlue[300],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              title: const Text('Dark Mode'),
              trailing: Switch(
                value: _darkMode,
                onChanged: (value) {
                  setState(() {
                    _darkMode = value;
                  });
                  debugPrint('Dark mode: $_darkMode');
                },
                activeColor: Colors.lightBlue,
              ),
            ),
            ListTile(
              title: const Text('Font Size'),
              subtitle: Text('Current: ${_fontSize.toStringAsFixed(1)}'),
              trailing: Slider(
                value: _fontSize,
                min: 12.0,
                max: 24.0,
                divisions: 12,
                onChanged: (value) {
                  setState(() {
                    _fontSize = value;
                  });
                  debugPrint('Font size: $_fontSize');
                },
                activeColor: Colors.lightBlue,
              ),
            ),
            ListTile(
              title: const Text('Language'),
              subtitle: Text('Selected: $_language'),
              trailing: DropdownButton<String>(
                value: _language,
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _language = newValue;
                    });
                    debugPrint('Language: $_language');
                  }
                },
                items: <String>['English', 'Spanish', 'French', 'German']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
            ListTile(
              title: const Text('Notifications'),
              trailing: Switch(
                value: _notificationsEnabled,
                onChanged: (value) {
                  setState(() {
                    _notificationsEnabled = value;
                  });
                  debugPrint('Notifications: $_notificationsEnabled');
                },
                activeColor: Colors.lightBlue,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                debugPrint(
                    'Settings saved: Dark mode: $_darkMode, Font size: $_fontSize, Language: $_language, Notifications: $_notificationsEnabled');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Settings Saved')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlue,
                foregroundColor: Colors.white,
              ),
              child: const Text('Save Settings'),
            ),
          ],
        ),
      ),
    );
  }
}