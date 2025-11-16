import 'package:hive/hive.dart';

import '../db/hive_database.dart';
import '../db/hive_keys.dart';

/// Cached data wrapper with metadata
class CachedData {
  final dynamic data;
  final DateTime timestamp;
  final DateTime? expiry;

  CachedData({
    required this.data,
    required this.timestamp,
    this.expiry,
  });

  bool get isExpired {
    if (expiry == null) return false;
    return DateTime.now().isAfter(expiry!);
  }

  Map<String, dynamic> toJson() => {
        'data': data,
        'timestamp': timestamp.millisecondsSinceEpoch,
        'expiry': expiry?.millisecondsSinceEpoch,
      };

  factory CachedData.fromJson(Map<dynamic, dynamic> json) {
    return CachedData(
      data: json['data'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp'] as int),
      expiry: json['expiry'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['expiry'] as int)
          : null,
    );
  }
}

/// Service for caching API responses and managing cache lifecycle
class CacheService {
  final HiveDatabase _hiveDatabase;
  late final Box<dynamic> _cacheBox;

  CacheService({required HiveDatabase hiveDatabase})
      : _hiveDatabase = hiveDatabase {
    _cacheBox = _hiveDatabase.getBox(HiveDatabase.apiCacheBox);
  }

  /// Cache API response with optional expiry duration
  Future<void> cacheResponse(
    String endpoint, {
    required dynamic data,
    Map<String, dynamic>? params,
    Duration? expiryDuration,
  }) async {
    final key = HiveKeys.apiCacheKey(endpoint, params);
    final expiry =
        expiryDuration != null ? DateTime.now().add(expiryDuration) : null;

    final cachedData = CachedData(
      data: data,
      timestamp: DateTime.now(),
      expiry: expiry,
    );

    await _cacheBox.put(key, cachedData.toJson());
  }

  /// Get cached API response
  /// Returns null if cache doesn't exist or is expired
  Future<dynamic> getCachedResponse(
    String endpoint, {
    Map<String, dynamic>? params,
  }) async {
    final key = HiveKeys.apiCacheKey(endpoint, params);
    final cached = _cacheBox.get(key);

    if (cached == null) return null;

    final cachedData = CachedData.fromJson(cached as Map<dynamic, dynamic>);

    if (cachedData.isExpired) {
      await _cacheBox.delete(key);
      return null;
    }

    return cachedData.data;
  }

  /// Check if cache exists and is valid
  Future<bool> isCached(
    String endpoint, {
    Map<String, dynamic>? params,
  }) async {
    final key = HiveKeys.apiCacheKey(endpoint, params);
    final cached = _cacheBox.get(key);

    if (cached == null) return false;

    final cachedData = CachedData.fromJson(cached as Map<dynamic, dynamic>);
    return !cachedData.isExpired;
  }

  /// Clear specific cache entry
  Future<void> clearCache(
    String endpoint, {
    Map<String, dynamic>? params,
  }) async {
    final key = HiveKeys.apiCacheKey(endpoint, params);
    await _cacheBox.delete(key);
  }

  /// Clear all expired cache entries
  Future<void> clearExpiredCache() async {
    final keysToDelete = <dynamic>[];

    for (final key in _cacheBox.keys) {
      final cached = _cacheBox.get(key);
      if (cached != null) {
        final cachedData = CachedData.fromJson(cached as Map<dynamic, dynamic>);
        if (cachedData.isExpired) {
          keysToDelete.add(key);
        }
      }
    }

    await _cacheBox.deleteAll(keysToDelete);
  }

  /// Clear all cache
  Future<void> clearAllCache() async {
    await _cacheBox.clear();
  }

  /// Get cache metadata (timestamp, expiry) without data
  Future<CachedData?> getCacheMetadata(
    String endpoint, {
    Map<String, dynamic>? params,
  }) async {
    final key = HiveKeys.apiCacheKey(endpoint, params);
    final cached = _cacheBox.get(key);

    if (cached == null) return null;

    return CachedData.fromJson(cached as Map<dynamic, dynamic>);
  }
}
