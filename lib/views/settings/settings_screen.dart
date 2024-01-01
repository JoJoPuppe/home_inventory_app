import 'package:flutter/material.dart';
import '/provider/settings_provider.dart';
import 'package:provider/provider.dart';


class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: ListView(
        children: <Widget>[
          ListTile(
            title: const Text('Switch Setting'),
            subtitle: const Text('This is a switch setting'),
            trailing: Switch(
              value: settingsProvider.currentSettings.someSetting,
              onChanged: (newValue) {
                  settingsProvider.updateSetting(newValue);
              },
            ),
          ),
          ListTile(
            title: const Text('Server URL'),
            subtitle: Text(settingsProvider.currentSettings.serverURL),
            trailing: IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                _showEditDialog(context, settingsProvider);
              },
            ),
          ),
        ],
      )
    );
  }
  void _showEditDialog(BuildContext context, SettingsProvider settingsProvider) {
    TextEditingController textEditingController = TextEditingController(text: settingsProvider.currentSettings.serverURL);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit URL'),
          content: TextField(
            controller: textEditingController,
            onChanged: (value) {
              textEditingController.text = value;
            },
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () {
                settingsProvider.updateServerURL(textEditingController.text);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

