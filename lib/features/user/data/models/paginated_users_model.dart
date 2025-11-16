import '../../domain/entities/paginated_users_entity.dart';
import 'user_model.dart';

/// Paginated users data model with JSON serialization
class PaginatedUsersModel extends PaginatedUsersEntity {
  const PaginatedUsersModel({
    required super.page,
    required super.perPage,
    required super.total,
    required super.totalPages,
    required super.users,
  });

  /// Create PaginatedUsersModel from API JSON response
  factory PaginatedUsersModel.fromJson(Map<String, dynamic> json) {
    return PaginatedUsersModel(
      page: json['page'] as int,
      perPage: json['per_page'] as int,
      total: json['total'] as int,
      totalPages: json['total_pages'] as int,
      users: (json['data'] as List<dynamic>)
          .map((user) => UserModel.fromJson(user as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Convert PaginatedUsersModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'page': page,
      'per_page': perPage,
      'total': total,
      'total_pages': totalPages,
      'data': users.map((user) => UserModel.fromEntity(user).toJson()).toList(),
    };
  }

  /// Convert to domain entity
  PaginatedUsersEntity toEntity() {
    return PaginatedUsersEntity(
      page: page,
      perPage: perPage,
      total: total,
      totalPages: totalPages,
      users: users,
    );
  }
}
