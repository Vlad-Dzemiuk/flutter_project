import 'package:get_it/get_it.dart';
import '../features/home/home_repository.dart';
import '../features/home/home_bloc.dart';

final getIt = GetIt.instance;

Future<void> init() async {
  // Repositories
  getIt.registerLazySingleton<HomeRepository>(() => HomeRepositoryImpl());

  // BLoCs / Cubits
  getIt.registerFactory<HomeBloc>(() => HomeBloc(repository: getIt<HomeRepository>()));
}
