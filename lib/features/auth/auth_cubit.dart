import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'auth_repository.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository repository;

  AuthCubit({required this.repository}) : super(AuthInitial());

  User? get currentUser => repository.currentUser;

  Future<void> signIn(String email, String password) async {
    emit(AuthLoading());
    try {
      final cred =
          await repository.signIn(email: email.trim(), password: password);
      emit(AuthAuthenticated(cred.user!));
    } on FirebaseAuthException catch (e) {
      emit(AuthError(e.message ?? 'Authentication error'));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> register(String email, String password) async {
    emit(AuthLoading());
    try {
      final cred =
          await repository.register(email: email.trim(), password: password);
      emit(AuthAuthenticated(cred.user!));
    } on FirebaseAuthException catch (e) {
      emit(AuthError(e.message ?? 'Registration error'));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> signOut() async {
    await repository.signOut();
    emit(AuthInitial());
  }
}


