import 'package:bloc/bloc.dart';

import 'auth_repository.dart';
import 'auth_state.dart';
import 'domain/entities/user.dart';
import 'domain/usecases/sign_in_usecase.dart';
import 'domain/usecases/register_usecase.dart';
import 'data/mappers/user_mapper.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository repository;
  final SignInUseCase signInUseCase;
  final RegisterUseCase registerUseCase;

  AuthCubit({
    required this.repository,
    required this.signInUseCase,
    required this.registerUseCase,
  }) : super(AuthInitial());

  User? get currentUser {
    final localUser = repository.currentUser;
    return localUser != null ? UserMapper.toEntity(localUser) : null;
  }

  Future<void> signIn(String email, String password) async {
    emit(AuthLoading());
    try {
      // Використання use case замість прямого виклику репозиторію
      final user = await signInUseCase(
        SignInParams(email: email, password: password),
      );
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> register(String email, String password) async {
    emit(AuthLoading());
    try {
      // Використання use case замість прямого виклику репозиторію
      final user = await registerUseCase(
        RegisterParams(email: email, password: password),
      );
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> signOut() async {
    await repository.signOut();
    emit(AuthInitial());
  }
}


