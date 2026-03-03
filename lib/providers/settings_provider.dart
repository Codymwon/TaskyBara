import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  final SharedPreferences _prefs;

  late String _themeMode;
  late String _sortOrder;

  String get themeMode => _themeMode;
  String get sortOrder => _sortOrder;

  SettingsProvider(this._prefs) {
    _themeMode = _prefs.getString('themeMode') ?? 'system';
    _sortOrder = _prefs.getString('sortOrder') ?? 'priority';
  }

  Future<void> setThemeMode(String mode) async {
    _themeMode = mode;
    await _prefs.setString('themeMode', mode);
    notifyListeners();
  }

  Future<void> setSortOrder(String order) async {
    _sortOrder = order;
    await _prefs.setString('sortOrder', order);
    notifyListeners();
  }
}
