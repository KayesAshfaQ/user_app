import 'package:flutter/material.dart';

import '../../domain/entities/user_entity.dart';
import 'pagination_loader.dart';
import 'user_list_item.dart';

/// User list view with refresh and pagination
///
/// A pure, reusable widget that doesn't depend on BLoC or navigation
class UserListView extends StatelessWidget {
  final List<UserEntity> users;
  final bool hasMore;
  final bool isSearching;
  final bool isLoadingMore;
  final VoidCallback onRefresh;
  final VoidCallback onLoadMore;
  final void Function(UserEntity user) onUserTap;

  const UserListView({
    super.key,
    required this.users,
    required this.hasMore,
    required this.isSearching,
    required this.onRefresh,
    required this.onLoadMore,
    required this.onUserTap,
    this.isLoadingMore = false,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        onRefresh();
        // Small delay to show the refresh indicator
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          // Trigger load more when near bottom
          if (!isSearching &&
              hasMore &&
              !isLoadingMore &&
              scrollInfo.metrics.pixels >=
                  scrollInfo.metrics.maxScrollExtent * 0.9) {
            onLoadMore();
          }
          return false;
        },
        child: ListView.builder(
          itemCount: users.length + (hasMore && !isSearching ? 1 : 0),
          itemBuilder: (context, index) {
            // Show loading indicator at bottom
            if (index == users.length) {
              return const PaginationLoader();
            }

            final user = users[index];
            return UserListItem(
              user: user,
              onTap: () => onUserTap(user),
            );
          },
        ),
      ),
    );
  }
}
