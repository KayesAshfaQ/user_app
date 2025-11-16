import 'package:hive/hive.dart';

import '../db/hive_database.dart';
import '../db/hive_keys.dart';

/// Service for managing app configuration and settings
class AppConfigService {
  final HiveDatabase _hiveDatabase;
  late final Box<dynamic> _configBox;
  late final Box<dynamic> _settingsBox;

  AppConfigService({required HiveDatabase hiveDatabase})
      : _hiveDatabase = hiveDatabase {
    _configBox = _hiveDatabase.getBox(HiveDatabase.appConfigBox);
    _settingsBox = _hiveDatabase.getBox(HiveDatabase.userSettingsBox);
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

  /// Check if onboarding is completed
  bool isOnboardingCompleted() {
    return _configBox.get(HiveKeys.onboardingCompleted, defaultValue: false);
  }

  /// Mark onboarding as completed
  Future<void> setOnboardingCompleted(bool completed) async {
    await _configBox.put(HiveKeys.onboardingCompleted, completed);
  }

  // ========== User Settings Methods ==========

  /// Get default currency
  String getDefaultCurrency() {
    return _settingsBox.get(HiveKeys.defaultCurrency, defaultValue: 'USD');
  }

  /// Set default currency
  Future<void> setDefaultCurrency(String currency) async {
    await _settingsBox.put(HiveKeys.defaultCurrency, currency);
  }

  /// Check if notifications are enabled
  bool areNotificationsEnabled() {
    return _settingsBox.get(HiveKeys.notificationsEnabled, defaultValue: true);
  }

  /// Set notifications enabled/disabled
  Future<void> setNotificationsEnabled(bool enabled) async {
    await _settingsBox.put(HiveKeys.notificationsEnabled, enabled);
  }

  /// Check if user is first time user
  bool isFirstTimeUser() {
    return _settingsBox.get(HiveKeys.firstTimeUser, defaultValue: true);
  }

  /// Mark user as not first time
  Future<void> setFirstTimeUser(bool isFirstTime) async {
    await _settingsBox.put(HiveKeys.firstTimeUser, isFirstTime);
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

  /// Get value from settings box
  T? getSettingsValue<T>(String key, {T? defaultValue}) {
    return _settingsBox.get(key, defaultValue: defaultValue);
  }

  /// Set value in settings box
  Future<void> setSettingsValue(String key, dynamic value) async {
    await _settingsBox.put(key, value);
  }

  /// Clear all config
  Future<void> clearConfig() async {
    await _configBox.clear();
  }

  /// Clear all settings
  Future<void> clearSettings() async {
    await _settingsBox.clear();
  }

  /// Reset to defaults
  Future<void> resetToDefaults() async {
    await clearConfig();
    await clearSettings();
  }
}
