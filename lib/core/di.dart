import 'package:get_it/get_it.dart';
import '../features/home/home_repository.dart';
import '../features/auth/auth_repository.dart';
import '../features/auth/auth_cubit.dart';
import '../features/collections/media_collections_cubit.dart';
import '../features/collections/media_collections_repository.dart';
import '../features/home/home_bloc.dart';
import '../core/storage/media_collections_storage.dart';

final getIt = GetIt.instance;

Future<void> init() async {
  // Repositories
  getIt.registerLazySingleton<HomeRepository>(() => HomeRepositoryImpl());
  getIt.registerLazySingleton<AuthRepository>(() => AuthRepository());
  getIt.registerLazySingleton<MediaCollectionsRepository>(
    () => MediaCollectionsRepository(MediaCollectionsStorage.instance),
  );
  getIt.registerLazySingleton<MediaCollectionsCubit>(
    () => MediaCollectionsCubit(
      repository: getIt<MediaCollectionsRepository>(),
      authRepository: getIt<AuthRepository>(),
    ),
  );

  // BLoCs / Cubits
  getIt.registerFactory<HomeBloc>(
    () => HomeBloc(repository: getIt<HomeRepository>()),
  );
  getIt.registerFactory<AuthCubit>(
    () => AuthCubit(repository: getIt<AuthRepository>()),
  );
}
