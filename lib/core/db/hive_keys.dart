/// Constants for Hive box keys
class HiveKeys {
  // API Cache keys
  static const String apiCachePrefix = 'api_';

  // App Config keys
  static const String themeMode = 'theme_mode';
  static const String language = 'language';
  static const String firstTimeUser = 'first_time_user';

  // Cache metadata keys
  static const String cacheTimestamp = '_timestamp';
  static const String cacheExpiry = '_expiry';

  /// Generate cache key for API endpoint
  static String apiCacheKey(String endpoint, [Map<String, dynamic>? params]) {
    final paramString =
        params?.entries.map((e) => '${e.key}=${e.value}').join('&') ?? '';
    return '$apiCachePrefix$endpoint${paramString.isNotEmpty ? '?$paramString' : ''}';
  }
}
