import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/event/app_event_bus.dart';
import '../../../domain/usecases/get_users_usecase.dart';
import '../../../domain/usecases/search_users_usecase.dart';
import 'user_list_event.dart';
import 'user_list_state.dart';

/// BLoC for managing user list state with pagination and search
class UserListBloc extends Bloc<UserListEvent, UserListState> {
  final GetUsersUsecase getUsersUsecase;
  final SearchUsersUsecase searchUsersUsecase;
  final AppEventBus eventBus;

  static const int _perPage = 10;

  UserListBloc({
    required this.getUsersUsecase,
    required this.searchUsersUsecase,
    required this.eventBus,
  }) : super(const UserListInitial()) {
    on<LoadUsersEvent>(_onLoadUsers);
    on<LoadMoreUsersEvent>(_onLoadMoreUsers);
    on<RefreshUsersEvent>(_onRefreshUsers);
    on<SearchUsersEvent>(_onSearchUsers);
  }

  /// Handle initial load of users
  Future<void> _onLoadUsers(
    LoadUsersEvent event,
    Emitter<UserListState> emit,
  ) async {
    emit(const UserListLoading());

    final result = await getUsersUsecase(page: 1, perPage: _perPage);

    result.fold(
      (failure) => emit(UserListError(failure.message)),
      (paginatedUsers) {
        emit(UserListLoaded(
          users: paginatedUsers.users,
          allUsers: paginatedUsers.users,
          hasMore: paginatedUsers.hasMorePages,
          currentPage: paginatedUsers.page,
        ));
      },
    );
  }

  /// Handle loading more users (pagination)
  Future<void> _onLoadMoreUsers(
    LoadMoreUsersEvent event,
    Emitter<UserListState> emit,
  ) async {
    final currentState = state;

    // Only load more if we're in a loaded state and have more pages
    if (currentState is! UserListLoaded || !currentState.hasMore) {
      return;
    }

    // Don't load if searching or already loading more
    if (currentState.isSearching || currentState.isLoadingMore) {
      return;
    }

    // Set loading more flag
    emit(currentState.copyWith(isLoadingMore: true));

    final nextPage = currentState.currentPage + 1;
    final result = await getUsersUsecase(page: nextPage, perPage: _perPage);

    result.fold(
      (failure) {
        // Revert loading flag on error
        emit(currentState.copyWith(isLoadingMore: false));
      },
      (paginatedUsers) {
        final updatedUsers = [
          ...currentState.allUsers,
          ...paginatedUsers.users,
        ];

        emit(UserListLoaded(
          users: updatedUsers,
          allUsers: updatedUsers,
          hasMore: paginatedUsers.hasMorePages,
          currentPage: paginatedUsers.page,
          searchQuery: currentState.searchQuery,
          isLoadingMore: false,
        ));
      },
    );
  }

  /// Handle refresh users (pull-to-refresh)
  Future<void> _onRefreshUsers(
    RefreshUsersEvent event,
    Emitter<UserListState> emit,
  ) async {
    // Reset to initial state and reload
    emit(const UserListLoading());

    final result = await getUsersUsecase(page: 1, perPage: _perPage);

    result.fold(
      (failure) => emit(UserListError(failure.message)),
      (paginatedUsers) {
        emit(UserListLoaded(
          users: paginatedUsers.users,
          allUsers: paginatedUsers.users,
          hasMore: paginatedUsers.hasMorePages,
          currentPage: paginatedUsers.page,
        ));
      },
    );
  }

  /// Handle search/filter users locally
  void _onSearchUsers(
    SearchUsersEvent event,
    Emitter<UserListState> emit,
  ) {
    final currentState = state;

    if (currentState is! UserListLoaded) {
      return;
    }

    // Filter users locally using the search use case
    final filteredUsers = searchUsersUsecase(
      users: currentState.allUsers,
      query: event.query,
    );

    emit(currentState.copyWith(
      users: filteredUsers,
      searchQuery: event.query,
    ));
  }
}
