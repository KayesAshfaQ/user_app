import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/paginated_users_entity.dart';
import '../entities/user_entity.dart';

/// Abstract repository interface for user data operations
///
/// This defines the contract that data layer must implement
abstract class UserRepository {
  /// Fetch paginated list of users
  ///
  /// Returns [PaginatedUsersEntity] on success or [Failure] on error
  Future<Either<Failure, PaginatedUsersEntity>> getUsers({
    required int page,
    required int perPage,
  });

  /// Fetch a single user by ID
  ///
  /// Returns [UserEntity] on success or [Failure] on error
  Future<Either<Failure, UserEntity>> getUserById(int id);
}
