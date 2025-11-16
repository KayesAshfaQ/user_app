import 'package:hive_flutter/hive_flutter.dart';

/// Hive database configuration and box names
class HiveDatabase {
  // Box names
  static const String apiCacheBox = 'api_cache';
  static const String appConfigBox = 'app_config';
  static const String userSettingsBox = 'user_settings';

  // Singleton pattern
  static final HiveDatabase _instance = HiveDatabase._internal();
  factory HiveDatabase() => _instance;
  HiveDatabase._internal();

  /// Initialize Hive with all required boxes
  Future<void> initialize() async {
    await Hive.initFlutter();

    // Register type adapters here
    // Example: Hive.registerAdapter(YourModelAdapter());

    // Open all required boxes
    await Future.wait([
      Hive.openBox<Map<dynamic, dynamic>>(apiCacheBox),
      Hive.openBox<Map<dynamic, dynamic>>(appConfigBox),
      Hive.openBox<dynamic>(userSettingsBox),
    ]);
  }

  /// Get a box by name
  Box<T> getBox<T>(String boxName) {
    return Hive.box<T>(boxName);
  }

  /// Close all boxes and Hive
  Future<void> close() async {
    await Hive.close();
  }

  /// Clear all data (useful for logout or reset)
  Future<void> clearAll() async {
    await Future.wait([
      Hive.box(apiCacheBox).clear(),
      Hive.box(appConfigBox).clear(),
      Hive.box(userSettingsBox).clear(),
    ]);
  }

  /// Clear specific box
  Future<void> clearBox(String boxName) async {
    await Hive.box(boxName).clear();
  }
}
