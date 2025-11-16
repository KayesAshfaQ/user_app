import 'package:equatable/equatable.dart';

import 'user_entity.dart';

/// Paginated users entity for handling API pagination metadata
class PaginatedUsersEntity extends Equatable {
  final int page;
  final int perPage;
  final int total;
  final int totalPages;
  final List<UserEntity> users;

  const PaginatedUsersEntity({
    required this.page,
    required this.perPage,
    required this.total,
    required this.totalPages,
    required this.users,
  });

  /// Check if there are more pages to load
  bool get hasMorePages => page < totalPages;

  @override
  List<Object?> get props => [page, perPage, total, totalPages, users];
}
