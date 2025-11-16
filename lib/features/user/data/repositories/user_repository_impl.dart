import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/paginated_users_entity.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/user_local_data_source.dart';
import '../datasources/user_remote_data_source.dart';

/// Implementation of user repository
/// Orchestrates between local (cache) and remote (API) data sources
class UserRepositoryImpl implements UserRepository {
  final UserLocalDataSource localDataSource;
  final UserRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  UserRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, PaginatedUsersEntity>> getUsers({
    required int page,
    required int perPage,
  }) async {
    try {
      final isConnected = await networkInfo.isConnected;

      if (isConnected) {
        // Online: Try to fetch from remote and cache
        try {
          final remoteUsers = await remoteDataSource.getUsers(
            page: page,
            perPage: perPage,
          );

          // Cache the fresh data
          await localDataSource.cacheUsers(
            users: remoteUsers,
            page: page,
            perPage: perPage,
          );

          return Right(remoteUsers.toEntity());
        } on ServerException catch (e) {
          // If remote fails, try to return cached data as fallback
          final cachedUsers = await localDataSource.getCachedUsers(
            page: page,
            perPage: perPage,
          );

          if (cachedUsers != null) {
            return Right(cachedUsers.toEntity());
          }

          return Left(ServerFailure(message: e.message, code: e.code));
        }
      } else {
        // Offline: Try to get from cache
        final cachedUsers = await localDataSource.getCachedUsers(
          page: page,
          perPage: perPage,
        );

        if (cachedUsers != null) {
          return Right(cachedUsers.toEntity());
        }

        return const Left(
          NetworkFailure(
            message: 'No internet connection and no cached data available',
          ),
        );
      }
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> getUserById(int id) async {
    try {
      // Check network connectivity
      final isConnected = await networkInfo.isConnected;

      if (!isConnected) {
        return const Left(
          NetworkFailure(message: 'No internet connection'),
        );
      }

      // Fetch user details from remote (no caching for individual users)
      final userModel = await remoteDataSource.getUserById(id);

      return Right(userModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }
}
