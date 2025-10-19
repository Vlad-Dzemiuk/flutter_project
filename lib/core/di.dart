import 'package:get_it/get_it.dart';
import 'package:project/features/home/home_repository.dart';
import 'package:project/features/home/home_bloc.dart';

final getIt = GetIt.instance;

void setupDI() {
  // Repositories
  getIt.registerLazySingleton<HomeRepository>(() => HomeRepositoryImpl());

  // BLoCs / Cubits
  getIt.registerFactory<HomeBloc>(() => HomeBloc(repository: getIt<HomeRepository>()));
}
