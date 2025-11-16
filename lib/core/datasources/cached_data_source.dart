import '../error/exceptions.dart';
import '../network/network_info.dart';
import '../services/cache_service.dart';

/// Generic cached data source implementation
/// Handles the logic of fetching from cache or network based on cache validity
abstract class CachedDataSource<T> {
  final CacheService cacheService;
  final NetworkInfo networkInfo;

  CachedDataSource({
    required this.cacheService,
    required this.networkInfo,
  });

  /// The endpoint identifier for caching
  String get endpoint;

  /// Default cache expiry duration (can be overridden)
  Duration get cacheExpiry => const Duration(hours: 1);

  /// Whether to allow stale cache when offline (default: true)
  bool get allowStaleCache => true;

  /// Fetch from remote source (must be implemented by concrete classes)
  Future<T> fetchFromRemote({Map<String, dynamic>? params});

  /// Parse cached data to model (must be implemented by concrete classes)
  T parseFromCache(dynamic cachedData);

  /// Convert model to cache data (must be implemented by concrete classes)
  dynamic convertToCache(T data);

  /// Fetch data with cache strategy
  /// 1. Check if online and cache is valid -> return cache
  /// 2. If online but cache invalid/missing -> fetch from remote and cache
  /// 3. If offline and cache exists -> return stale cache (if allowed)
  /// 4. If offline and no cache -> throw NetworkException
  Future<T> fetchWithCache({
    Map<String, dynamic>? params,
    bool forceRefresh = false,
  }) async {
    final isConnected = await networkInfo.isConnected;

    // If force refresh, skip cache and fetch from remote
    if (forceRefresh && isConnected) {
      return await _fetchAndCache(params);
    }

    // Check cache first
    final cachedData = await cacheService.getCachedResponse(
      endpoint,
      params: params,
    );

    if (cachedData != null) {
      // Return cached data if valid
      return parseFromCache(cachedData);
    }

    // Cache miss or expired
    if (isConnected) {
      // Fetch from remote and cache
      return await _fetchAndCache(params);
    } else {
      // Offline and no valid cache
      if (allowStaleCache && cachedData != null) {
        return parseFromCache(cachedData);
      }
      throw const NetworkException(
        message: 'No internet connection and no cached data available',
      );
    }
  }

  /// Fetch from remote and cache the result
  Future<T> _fetchAndCache(Map<String, dynamic>? params) async {
    try {
      final data = await fetchFromRemote(params: params);

      // Cache the result
      await cacheService.cacheResponse(
        endpoint,
        data: convertToCache(data),
        params: params,
        expiryDuration: cacheExpiry,
      );

      return data;
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: e.toString());
    }
  }

  /// Clear cache for this data source
  Future<void> clearCache({Map<String, dynamic>? params}) async {
    await cacheService.clearCache(endpoint, params: params);
  }

  /// Check if cache exists and is valid
  Future<bool> isCached({Map<String, dynamic>? params}) async {
    return await cacheService.isCached(endpoint, params: params);
  }
}
