import '../../../../core/datasources/cached_data_source.dart';

/// Example cached data source implementation
/// This demonstrates how to use the CachedDataSource base class
class ExampleCachedDataSource extends CachedDataSource<Map<String, dynamic>> {
  ExampleCachedDataSource({
    required super.cacheService,
    required super.networkInfo,
  });

  @override
  String get endpoint => 'example/data';

  @override
  Duration get cacheExpiry => const Duration(minutes: 30);

  @override
  Future<Map<String, dynamic>> fetchFromRemote({
    Map<String, dynamic>? params,
  }) async {
    // TODO: Implement actual API call using ApiClient
    // Example:
    // final response = await apiClient.get(endpoint, queryParameters: params);
    // return response as Map<String, dynamic>;

    throw UnimplementedError('Implement API call here');
  }

  @override
  Map<String, dynamic> parseFromCache(dynamic cachedData) {
    return cachedData as Map<String, dynamic>;
  }

  @override
  dynamic convertToCache(Map<String, dynamic> data) {
    return data;
  }
}
