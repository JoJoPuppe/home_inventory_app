import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/models/settings_model.dart';

class SettingsProvider with ChangeNotifier {
  final Settings _currentSettings = Settings();

  Settings get currentSettings => _currentSettings;

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _currentSettings.someSetting = prefs.getBool('someSetting') ?? false;
    _currentSettings.serverURL = prefs.getString('serverURL') ?? "http://127.0.0.1:8000";
    notifyListeners();
  }

  Future<void> updateSetting(bool newSetting) async {
    _currentSettings.someSetting = newSetting;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('someSetting', newSetting);
  }
  Future<void> updateServerURL(String newURL) async {
    _currentSettings.serverURL = newURL;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('serverURL', newURL);
  }

}
