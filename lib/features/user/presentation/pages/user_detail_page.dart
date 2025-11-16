import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/service_locator.dart';
import '../blocs/user_detail/user_detail_bloc.dart';
import '../blocs/user_detail/user_detail_event.dart';
import '../blocs/user_detail/user_detail_state.dart';
import '../widgets/error_retry_widget.dart';

/// User detail page showing detailed user information
class UserDetailPage extends StatelessWidget {
  final int userId;

  const UserDetailPage({
    super.key,
    required this.userId,
  });

  /// Factory method to create page with BLoC
  static Widget create({required int id}) {
    return BlocProvider(
      create: (context) => sl<UserDetailBloc>()..add(LoadUserDetailEvent(id)),
      child: UserDetailPage(userId: id),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Details'),
        elevation: 0,
      ),
      body: BlocBuilder<UserDetailBloc, UserDetailState>(
        builder: (context, state) {
          if (state is UserDetailLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is UserDetailError) {
            return ErrorRetryWidget(
              message: state.message,
              onRetry: () {
                context.read<UserDetailBloc>().add(LoadUserDetailEvent(userId));
              },
            );
          }

          if (state is UserDetailLoaded) {
            final user = state.user;

            return SingleChildScrollView(
              child: Column(
                children: [
                  // Header with avatar
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).primaryColor,
                          Theme.of(context).primaryColor.withOpacity(0.7),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Column(
                      children: [
                        Hero(
                          tag: 'user_avatar_${user.id}',
                          child: CircleAvatar(
                            backgroundImage: NetworkImage(user.avatar),
                            radius: 60,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          user.fullName,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Details
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoCard(
                          context,
                          icon: Icons.email_outlined,
                          label: 'Email',
                          value: user.email,
                        ),
                        const SizedBox(height: 16),
                        _buildInfoCard(
                          context,
                          icon: Icons.person_outline,
                          label: 'First Name',
                          value: user.firstName,
                        ),
                        const SizedBox(height: 16),
                        _buildInfoCard(
                          context,
                          icon: Icons.person_outline,
                          label: 'Last Name',
                          value: user.lastName,
                        ),
                        const SizedBox(height: 16),
                        _buildInfoCard(
                          context,
                          icon: Icons.badge_outlined,
                          label: 'User ID',
                          value: user.id.toString(),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              icon,
              color: Theme.of(context).primaryColor,
              size: 28,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
