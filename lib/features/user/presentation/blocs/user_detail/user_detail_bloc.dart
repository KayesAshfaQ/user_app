import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/usecases/get_user_by_id_usecase.dart';
import 'user_detail_event.dart';
import 'user_detail_state.dart';

/// BLoC for managing user detail state
class UserDetailBloc extends Bloc<UserDetailEvent, UserDetailState> {
  final GetUserByIdUsecase getUserByIdUsecase;

  UserDetailBloc({
    required this.getUserByIdUsecase,
  }) : super(const UserDetailInitial()) {
    on<LoadUserDetailEvent>(_onLoadUserDetail);
  }

  /// Handle loading user details
  Future<void> _onLoadUserDetail(
    LoadUserDetailEvent event,
    Emitter<UserDetailState> emit,
  ) async {
    emit(const UserDetailLoading());

    final result = await getUserByIdUsecase(event.userId);

    result.fold(
      (failure) => emit(UserDetailError(failure.message)),
      (user) => emit(UserDetailLoaded(user)),
    );
  }
}
