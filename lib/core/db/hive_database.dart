import 'package:hive_flutter/hive_flutter.dart';

/// Hive database configuration and box names
class HiveDatabase {
  // Box names
  static const String apiCacheBox = 'api_cache';
  static const String appConfigBox = 'app_config';

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
      Hive.openBox<dynamic>(apiCacheBox),
      Hive.openBox<dynamic>(appConfigBox),
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
    ]);
  }

  /// Clear specific box
  Future<void> clearBox(String boxName) async {
    await Hive.box(boxName).clear();
  }
}
