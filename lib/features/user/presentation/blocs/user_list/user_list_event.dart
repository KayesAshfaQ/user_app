import 'package:equatable/equatable.dart';

/// Base class for all user list events
abstract class UserListEvent extends Equatable {
  const UserListEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load initial users
class LoadUsersEvent extends UserListEvent {
  const LoadUsersEvent();
}

/// Event to load more users (pagination)
class LoadMoreUsersEvent extends UserListEvent {
  const LoadMoreUsersEvent();
}

/// Event to refresh users (pull-to-refresh)
class RefreshUsersEvent extends UserListEvent {
  const RefreshUsersEvent();
}

/// Event to search/filter users locally
class SearchUsersEvent extends UserListEvent {
  final String query;

  const SearchUsersEvent(this.query);

  @override
  List<Object?> get props => [query];
}
