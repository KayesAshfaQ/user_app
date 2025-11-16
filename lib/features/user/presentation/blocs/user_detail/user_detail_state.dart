import 'package:equatable/equatable.dart';

import '../../../domain/entities/user_entity.dart';

/// Base class for all user detail states
abstract class UserDetailState extends Equatable {
  const UserDetailState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class UserDetailInitial extends UserDetailState {
  const UserDetailInitial();
}

/// Loading state
class UserDetailLoading extends UserDetailState {
  const UserDetailLoading();
}

/// Loaded state with user details
class UserDetailLoaded extends UserDetailState {
  final UserEntity user;

  const UserDetailLoaded(this.user);

  @override
  List<Object?> get props => [user];
}

/// Error state
class UserDetailError extends UserDetailState {
  final String message;

  const UserDetailError(this.message);

  @override
  List<Object?> get props => [message];
}
