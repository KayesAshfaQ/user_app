import '../../../../core/api/api_client.dart';
import '../../../../core/error/exceptions.dart';
import '../models/paginated_users_model.dart';
import '../models/user_model.dart';

/// Abstract interface for user remote data source
abstract class UserRemoteDataSource {
  /// Fetch paginated users from API
  Future<PaginatedUsersModel> getUsers({
    required int page,
    required int perPage,
  });

  /// Fetch single user by ID from API
  Future<UserModel> getUserById(int id);
}

/// Implementation of user remote data source using API client
class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final ApiClient apiClient;

  UserRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<PaginatedUsersModel> getUsers({
    required int page,
    required int perPage,
  }) async {
    try {
      final response = await apiClient.get(
        '/users',
        queryParameters: {
          'page': page,
          'per_page': perPage,
        },
      );

      return PaginatedUsersModel.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: 'Failed to fetch users: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> getUserById(int id) async {
    try {
      final response = await apiClient.get('/users/$id');

      // API returns user data inside a 'data' wrapper
      final userData = (response as Map<String, dynamic>)['data'];
      return UserModel.fromJson(userData as Map<String, dynamic>);
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(
          message: 'Failed to fetch user details: ${e.toString()}');
    }
  }
}
