import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/user/presentation/pages/user_detail_page.dart';
import '../../features/user/presentation/pages/user_list_page.dart';

// Create keys for `root` & `section` navigator avoiding unnecessary rebuilds
final _rootNavigatorKey = GlobalKey<NavigatorState>();

/// Application router configuration using go_router
///
/// This class defines all the routes available in the application
/// and provides navigation-related utilities.
class AppRouter {
  /// Creates the router configuration
  static GoRouter get router => _router;

  static final _router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: UserListPage.routePath,
    debugLogDiagnostics: true,
    routes: [
      // User List Route
      GoRoute(
        path: UserListPage.routePath,
        builder: (context, state) => UserListPage.create(),
        routes: [
          // User Detail Route (nested under user list)
          GoRoute(
            path: ':id',
            parentNavigatorKey: _rootNavigatorKey,
            builder: (context, state) {
              final id = int.tryParse(state.pathParameters['id'] ?? '');
              if (id == null) {
                throw Exception(
                    'Invalid User ID: ${state.pathParameters['id']}');
              }
              return UserDetailPage.create(id: id);
            },
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Error: ${state.error}'),
      ),
    ),
  );
}
