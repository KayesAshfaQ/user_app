import '../../../../core/services/cache_service.dart';
import '../models/paginated_users_model.dart';

/// Local data source for cached users (Hive storage)
/// Handles ONLY cache operations - no remote data fetching
abstract class UserLocalDataSource {
  /// Get cached users for a specific page
  Future<PaginatedUsersModel?> getCachedUsers({
    required int page,
    required int perPage,
  });

  /// Cache users for a specific page
  Future<void> cacheUsers({
    required PaginatedUsersModel users,
    required int page,
    required int perPage,
  });

  /// Check if users are cached for a specific page
  Future<bool> isCached({
    required int page,
    required int perPage,
  });

  /// Clear cached users for a specific page
  Future<void> clearCache({
    required int page,
    required int perPage,
  });

  /// Clear all cached users
  Future<void> clearAllCache();
}

/// Implementation of local data source using Hive
class UserLocalDataSourceImpl implements UserLocalDataSource {
  final CacheService cacheService;
  static const String _endpoint = 'users';
  static const Duration _cacheExpiry = Duration(hours: 1);

  UserLocalDataSourceImpl({required this.cacheService});

  /// Generate cache key for specific page
  String _getCacheKey({required int page, required int perPage}) {
    return _endpoint;
  }

  /// Generate cache params for specific page
  Map<String, dynamic> _getCacheParams({
    required int page,
    required int perPage,
  }) {
    return {'page': page, 'per_page': perPage};
  }

  @override
  Future<PaginatedUsersModel?> getCachedUsers({
    required int page,
    required int perPage,
  }) async {
    final cachedData = await cacheService.getCachedResponse(
      _getCacheKey(page: page, perPage: perPage),
      params: _getCacheParams(page: page, perPage: perPage),
    );

    if (cachedData == null) return null;

    return PaginatedUsersModel.fromJson(cachedData as Map<String, dynamic>);
  }

  @override
  Future<void> cacheUsers({
    required PaginatedUsersModel users,
    required int page,
    required int perPage,
  }) async {
    await cacheService.cacheResponse(
      _getCacheKey(page: page, perPage: perPage),
      data: users.toJson(),
      params: _getCacheParams(page: page, perPage: perPage),
      expiryDuration: _cacheExpiry,
    );
  }

  @override
  Future<bool> isCached({
    required int page,
    required int perPage,
  }) async {
    return await cacheService.isCached(
      _getCacheKey(page: page, perPage: perPage),
      params: _getCacheParams(page: page, perPage: perPage),
    );
  }

  @override
  Future<void> clearCache({
    required int page,
    required int perPage,
  }) async {
    await cacheService.clearCache(
      _getCacheKey(page: page, perPage: perPage),
      params: _getCacheParams(page: page, perPage: perPage),
    );
  }

  @override
  Future<void> clearAllCache() async {
    await cacheService.clearAllCache();
  }
}
