import 'package:equatable/equatable.dart';

import '../../../domain/entities/user_entity.dart';

/// Base class for all user list states
abstract class UserListState extends Equatable {
  const UserListState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class UserListInitial extends UserListState {
  const UserListInitial();
}

/// Loading state (for initial load)
class UserListLoading extends UserListState {
  const UserListLoading();
}

/// Loaded state with users
class UserListLoaded extends UserListState {
  final List<UserEntity> users;
  final List<UserEntity> allUsers; // For search functionality
  final bool hasMore;
  final int currentPage;
  final String searchQuery;
  final bool isLoadingMore; // Flag for pagination loading

  const UserListLoaded({
    required this.users,
    required this.allUsers,
    required this.hasMore,
    required this.currentPage,
    this.searchQuery = '',
    this.isLoadingMore = false,
  });

  /// Check if currently searching
  bool get isSearching => searchQuery.isNotEmpty;

  /// Copy with method for state updates
  UserListLoaded copyWith({
    List<UserEntity>? users,
    List<UserEntity>? allUsers,
    bool? hasMore,
    int? currentPage,
    String? searchQuery,
    bool? isLoadingMore,
  }) {
    return UserListLoaded(
      users: users ?? this.users,
      allUsers: allUsers ?? this.allUsers,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props =>
      [users, allUsers, hasMore, currentPage, searchQuery, isLoadingMore];
}

/// Error state
class UserListError extends UserListState {
  final String message;

  const UserListError(this.message);

  @override
  List<Object?> get props => [message];
}
