import 'package:flutter_bloc/flutter_bloc.dart';
import 'domain/repositories/profile_repository.dart';
import 'domain/usecases/get_user_profile_usecase.dart';

class ProfileState {
  final bool loading;
  final String error;
  final UserProfile? user;

  ProfileState({this.loading = false, this.error = '', this.user});

  ProfileState copyWith({
    bool? loading,
    String? error,
    UserProfile? user,
  }) {
    return ProfileState(
      loading: loading ?? this.loading,
      error: error ?? this.error,
      user: user ?? this.user,
    );
  }
}

class ProfileBloc extends Cubit<ProfileState> {
  final GetUserProfileUseCase getUserProfileUseCase;

  ProfileBloc({required this.getUserProfileUseCase}) : super(ProfileState()) {
    loadProfile();
  }

  Future<void> loadProfile() async {
    emit(state.copyWith(loading: true));
    try {
      // Використання use case замість прямого виклику репозиторію
      final user = await getUserProfileUseCase(
        const GetUserProfileParams(userId: 1),
      );
      emit(state.copyWith(loading: false, user: user));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }
}
