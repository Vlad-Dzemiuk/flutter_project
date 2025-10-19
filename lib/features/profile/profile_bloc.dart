import 'package:flutter_bloc/flutter_bloc.dart';
import 'profile_repository.dart';

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
  final ProfileRepository repository;

  ProfileBloc({required this.repository}) : super(ProfileState()) {
    loadProfile();
  }

  Future<void> loadProfile() async {
    emit(state.copyWith(loading: true));
    try {
      final user = await repository.getUserProfile(1);
      emit(state.copyWith(loading: false, user: user));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }
}
