import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/paginated_users_entity.dart';
import '../repositories/user_repository.dart';

/// Use case for fetching paginated users
class GetUsersUsecase {
  final UserRepository repository;

  GetUsersUsecase(this.repository);

  /// Execute the use case
  ///
  /// [page] - Page number to fetch (1-based)
  /// [perPage] - Number of users per page
  Future<Either<Failure, PaginatedUsersEntity>> call({
    required int page,
    required int perPage,
  }) async {
    return await repository.getUsers(page: page, perPage: perPage);
  }
}
