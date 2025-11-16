import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/service_locator.dart';
import '../blocs/user_list/user_list_bloc.dart';
import '../blocs/user_list/user_list_event.dart';
import '../blocs/user_list/user_list_state.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/error_retry_widget.dart';
import '../widgets/user_list_view.dart';
import '../widgets/user_search_bar.dart';
import 'user_detail_page.dart';

/// User list page with search and pagination
class UserListPage extends StatelessWidget {
  static const routePath = '/users';

  const UserListPage({super.key});

  /// Factory method to create page with BLoC
  static Widget create() {
    return BlocProvider(
      create: (context) => sl<UserListBloc>()..add(const LoadUsersEvent()),
      child: const UserListPage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Users'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search bar
          UserSearchBar(
            onSearchChanged: (query) {
              context.read<UserListBloc>().add(SearchUsersEvent(query));
            },
          ),
          // User list
          Expanded(
            child: BlocBuilder<UserListBloc, UserListState>(
              builder: (context, state) {
                if (state is UserListLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is UserListError) {
                  return ErrorRetryWidget(
                    message: state.message,
                    onRetry: () {
                      context.read<UserListBloc>().add(const LoadUsersEvent());
                    },
                  );
                }

                if (state is UserListLoaded) {
                  if (state.users.isEmpty) {
                    return EmptyStateWidget(
                      message: state.isSearching
                          ? 'No users found for "${state.searchQuery}"'
                          : 'No users available',
                      icon: state.isSearching
                          ? Icons.search_off
                          : Icons.people_outline,
                    );
                  }

                  return UserListView(
                    users: state.users,
                    hasMore: state.hasMore,
                    isSearching: state.isSearching,
                    isLoadingMore: state.isLoadingMore,
                    onRefresh: () {
                      context
                          .read<UserListBloc>()
                          .add(const RefreshUsersEvent());
                    },
                    onLoadMore: () {
                      context
                          .read<UserListBloc>()
                          .add(const LoadMoreUsersEvent());
                    },
                    onUserTap: (user) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              UserDetailPage.create(id: user.id),
                        ),
                      );
                    },
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}
