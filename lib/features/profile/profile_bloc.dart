import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'profile_event.dart';
import 'domain/repositories/profile_repository.dart';
import 'domain/usecases/get_user_profile_usecase.dart';
import 'package:project/core/network/retry_helper.dart';

class ProfileState extends Equatable {
  final bool loading;
  final String error;
  final UserProfile? user;

  const ProfileState({this.loading = false, this.error = '', this.user});

  ProfileState copyWith({bool? loading, String? error, UserProfile? user}) {
    return ProfileState(
      loading: loading ?? this.loading,
      error: error ?? this.error,
      user: user ?? this.user,
    );
  }

  @override
  List<Object?> get props => [loading, error, user];
}

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetUserProfileUseCase getUserProfileUseCase;

  ProfileBloc({required this.getUserProfileUseCase})
    : super(const ProfileState()) {
    on<LoadProfileEvent>(_onLoadProfile);
    add(const LoadProfileEvent());
  }

  Future<void> _onLoadProfile(
    LoadProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(loading: true, error: ''));
    try {
      // Використання use case з retry механізмом для мережевих помилок
      final user = await RetryHelper.retry(
        operation: () =>
            getUserProfileUseCase(const GetUserProfileParams(userId: 1)),
      );
      emit(state.copyWith(loading: false, user: user, error: ''));
    } catch (e) {
      final errorMessage = _getUserFriendlyError(e);
      emit(state.copyWith(loading: false, error: errorMessage));
    }
  }

  String _getUserFriendlyError(dynamic error) {
    final errorString = error.toString().toLowerCase();

    if (errorString.contains('socketexception') ||
        errorString.contains('failed host lookup') ||
        errorString.contains('no address associated with hostname')) {
      return 'Немає інтернет-з\'єднання. Перевірте підключення до мережі.';
    }

    if (errorString.contains('timeout') || errorString.contains('timed out')) {
      return 'Час очікування вичерпано. Перевірте інтернет-з\'єднання.';
    }

    if (errorString.contains('connection') || errorString.contains('network')) {
      return 'Помилка підключення до сервера. Спробуйте пізніше.';
    }

    if (errorString.contains('unauthorized') ||
        errorString.contains('permission')) {
      return 'Недостатньо прав доступу. Увійдіть в акаунт.';
    }

    if (errorString.contains('not found') || errorString.contains('404')) {
      return 'Профіль користувача не знайдено.';
    }

    // Для інших помилок повертаємо загальне повідомлення
    return 'Не вдалося завантажити профіль. Спробуйте пізніше.';
  }
}
