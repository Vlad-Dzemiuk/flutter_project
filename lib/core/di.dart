import 'package:get_it/get_it.dart';
import '../features/home/home_repository.dart';
import '../features/home/home_bloc.dart';
import '../features/auth/auth_repository.dart';
import '../features/auth/auth_cubit.dart';

final getIt = GetIt.instance;

Future<void> init() async {
  // Repositories
  getIt.registerLazySingleton<HomeRepository>(() => HomeRepositoryImpl());
  getIt.registerLazySingleton<AuthRepository>(() => AuthRepository());

  // BLoCs / Cubits
  getIt.registerFactory<HomeBloc>(
    () => HomeBloc(repository: getIt<HomeRepository>()),
  );
  getIt.registerFactory<AuthCubit>(
    () => AuthCubit(repository: getIt<AuthRepository>()),
  );
}
