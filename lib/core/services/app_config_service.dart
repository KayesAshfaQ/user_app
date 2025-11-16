import 'package:hive/hive.dart';

import '../db/hive_database.dart';
import '../db/hive_keys.dart';

/// Service for managing app configuration and settings
class AppConfigService {
  final HiveDatabase _hiveDatabase;
  late final Box<dynamic> _configBox;

  AppConfigService({required HiveDatabase hiveDatabase})
      : _hiveDatabase = hiveDatabase {
    _configBox = _hiveDatabase.getBox(HiveDatabase.appConfigBox);
  }

  // ========== App Config Methods ==========

  /// Get theme mode (light, dark, system)
  String getThemeMode() {
    return _configBox.get(HiveKeys.themeMode, defaultValue: 'system');
  }

  /// Set theme mode
  Future<void> setThemeMode(String mode) async {
    await _configBox.put(HiveKeys.themeMode, mode);
  }

  /// Get language code
  String getLanguage() {
    return _configBox.get(HiveKeys.language, defaultValue: 'en');
  }

  /// Set language code
  Future<void> setLanguage(String languageCode) async {
    await _configBox.put(HiveKeys.language, languageCode);
  }

  /// Check if user is first time user
  bool isFirstTimeUser() {
    return _configBox.get(HiveKeys.firstTimeUser, defaultValue: true);
  }

  /// Mark user as not first time
  Future<void> setFirstTimeUser(bool isFirstTime) async {
    await _configBox.put(HiveKeys.firstTimeUser, isFirstTime);
  }

  // ========== Generic Methods ==========

  /// Get value from config box
  T? getConfigValue<T>(String key, {T? defaultValue}) {
    return _configBox.get(key, defaultValue: defaultValue);
  }

  /// Set value in config box
  Future<void> setConfigValue(String key, dynamic value) async {
    await _configBox.put(key, value);
  }

  /// Clear all config
  Future<void> clearConfig() async {
    await _configBox.clear();
  }
}
