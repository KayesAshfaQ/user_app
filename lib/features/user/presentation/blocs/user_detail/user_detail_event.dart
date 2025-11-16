import 'package:equatable/equatable.dart';

/// Base class for all user detail events
abstract class UserDetailEvent extends Equatable {
  const UserDetailEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load user details by ID
class LoadUserDetailEvent extends UserDetailEvent {
  final int userId;

  const LoadUserDetailEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}
