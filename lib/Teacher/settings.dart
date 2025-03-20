import 'package:flutter/material.dart';

import 'Admindashboard.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _darkMode = false;
  double _fontSize = 16.0;
  String _language = 'English';
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return
      WillPopScope(
        onWillPop: () async {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => AdminDashboard()),
            (route) => false,
      );
      return false; // Prevent default back action
    },
    child:Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Dark Mode Toggle
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: SwitchListTile(
                title: const Text("Dark Mode", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                value: _darkMode,
                onChanged: (value) => setState(() => _darkMode = value),
                activeColor: Colors.blueAccent,
              ),
            ),

            // Font Size Slider
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                title: const Text("Font Size", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Current: ${_fontSize.toStringAsFixed(1)}"),
                    Slider(
                      value: _fontSize,
                      min: 12.0,
                      max: 24.0,
                      divisions: 12,
                      onChanged: (value) => setState(() => _fontSize = value),
                      activeColor: Colors.blueAccent,
                    ),
                  ],
                ),
              ),
            ),

            // Language Dropdown
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                title: const Text("Language", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                subtitle: Text("Selected: $_language"),
                trailing: DropdownButton<String>(
                  value: _language,
                  onChanged: (String? newValue) {
                    if (newValue != null) setState(() => _language = newValue);
                  },
                  items: ['English', 'Spanish', 'French', 'German'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
            ),

            // Notifications Toggle
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: SwitchListTile(
                title: const Text("Notifications", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                value: _notificationsEnabled,
                onChanged: (value) => setState(() => _notificationsEnabled = value),
                activeColor: Colors.blueAccent,
              ),
            ),

            const SizedBox(height: 20),

            // Save Button
            Center(
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Settings Saved')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("Save Settings"),
              ),
            ),
          ],
        ),
      ),
    )
      );
  }
}

