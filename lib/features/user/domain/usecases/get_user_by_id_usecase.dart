import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/user_repository.dart';

/// Use case for fetching a single user by ID
class GetUserByIdUsecase {
  final UserRepository repository;

  GetUserByIdUsecase(this.repository);

  /// Execute the use case
  ///
  /// [id] - User ID to fetch
  Future<Either<Failure, UserEntity>> call(int id) async {
    return await repository.getUserById(id);
  }
}
