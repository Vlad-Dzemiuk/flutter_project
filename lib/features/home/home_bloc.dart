import 'package:bloc/bloc.dart';
import 'home_repository.dart';

class HomeState {
  final String message;
  final bool loading;

  HomeState({required this.message, this.loading = false});

  HomeState copyWith({String? message, bool? loading}) {
    return HomeState(
      message: message ?? this.message,
      loading: loading ?? this.loading,
    );
  }
}

class HomeBloc extends Cubit<HomeState> {
  final HomeRepository repository;

  HomeBloc({required this.repository}) : super(HomeState(message: '', loading: true)) {
    loadMessage();
  }

  Future<void> loadMessage() async {
    emit(state.copyWith(loading: true));
    final msg = await repository.fetchWelcomeMessage();
    emit(state.copyWith(message: msg, loading: false));
  }
}
