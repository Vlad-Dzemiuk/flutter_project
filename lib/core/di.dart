import 'package:get_it/get_it.dart';
import '../features/home/home_repository.dart';
import '../features/home/home_api_service.dart';
import '../features/auth/auth_repository.dart';
import '../features/auth/auth_cubit.dart';
import '../features/collections/media_collections_cubit.dart';
import '../features/collections/media_collections_repository.dart';
import '../features/home/home_bloc.dart';
import '../features/search/search_bloc.dart';
import '../core/storage/media_collections_storage.dart';
import '../core/loading_state.dart';
// Repositories (domain interfaces)
import '../features/search/domain/repositories/search_repository.dart';
import '../features/favorites/domain/repositories/favorites_repository.dart';
import '../features/profile/domain/repositories/profile_repository.dart';
// Repositories (data implementations)
import '../features/search/data/repositories/search_repository_impl.dart';
import '../features/favorites/data/repositories/favorites_repository_impl.dart';
import '../features/profile/data/repositories/profile_repository_impl.dart';
// Use Cases
import '../features/home/domain/usecases/get_popular_content_usecase.dart';
import '../features/home/domain/usecases/search_media_usecase.dart';
import '../features/home/domain/usecases/get_movie_details_usecase.dart';
import '../features/home/domain/usecases/get_tv_details_usecase.dart';
import '../features/home/domain/usecases/search_by_name_usecase.dart';
import '../features/auth/domain/usecases/sign_in_usecase.dart';
import '../features/auth/domain/usecases/register_usecase.dart';
import '../features/profile/domain/usecases/update_profile_usecase.dart';
import '../features/profile/domain/usecases/get_user_profile_usecase.dart';
import '../features/favorites/domain/usecases/get_favorites_usecase.dart';
import '../features/collections/domain/usecases/get_media_collections_usecase.dart';
import '../features/collections/domain/usecases/toggle_favorite_usecase.dart';
import '../features/collections/domain/usecases/add_to_watchlist_usecase.dart';
import '../features/search/domain/usecases/search_by_filters_usecase.dart';

final getIt = GetIt.instance;

Future<void> init() async {
  // API Services
  final homeApiService = HomeApiService();
  getIt.registerLazySingleton<HomeApiService>(() => homeApiService);

  // Repositories
  getIt.registerLazySingleton<HomeRepository>(() => HomeRepositoryImpl());
  getIt.registerLazySingleton<AuthRepository>(() => AuthRepository());
  getIt.registerLazySingleton<SearchRepository>(
    () => SearchRepositoryImpl(homeApiService),
  );
  getIt.registerLazySingleton<FavoritesRepository>(
    () => FavoritesRepositoryImpl(),
  );
  getIt.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(),
  );
  getIt.registerLazySingleton<MediaCollectionsRepository>(
    () => MediaCollectionsRepository(MediaCollectionsStorage.instance),
  );
  getIt.registerLazySingleton<MediaCollectionsCubit>(
    () => MediaCollectionsCubit(
      getMediaCollectionsUseCase: getIt<GetMediaCollectionsUseCase>(),
      toggleFavoriteUseCase: getIt<ToggleFavoriteUseCase>(),
      addToWatchlistUseCase: getIt<AddToWatchlistUseCase>(),
      authRepository: getIt<AuthRepository>(),
    ),
  );

  // Services
  getIt.registerLazySingleton<LoadingStateService>(() => LoadingStateService());

  // Use Cases
  getIt.registerFactory<GetPopularContentUseCase>(
    () => GetPopularContentUseCase(getIt<HomeRepository>()),
  );
  getIt.registerFactory<SearchMediaUseCase>(
    () => SearchMediaUseCase(getIt<HomeRepository>()),
  );
  getIt.registerFactory<GetMovieDetailsUseCase>(
    () => GetMovieDetailsUseCase(getIt<HomeRepository>()),
  );
  getIt.registerFactory<GetTvDetailsUseCase>(
    () => GetTvDetailsUseCase(getIt<HomeRepository>()),
  );
  getIt.registerFactory<SearchByNameUseCase>(
    () => SearchByNameUseCase(getIt<HomeRepository>()),
  );
  getIt.registerFactory<SignInUseCase>(
    () => SignInUseCase(getIt<AuthRepository>()),
  );
  getIt.registerFactory<RegisterUseCase>(
    () => RegisterUseCase(getIt<AuthRepository>()),
  );
  getIt.registerFactory<UpdateProfileUseCase>(
    () => UpdateProfileUseCase(getIt<AuthRepository>()),
  );
  getIt.registerFactory<GetUserProfileUseCase>(
    () => GetUserProfileUseCase(getIt<ProfileRepository>()),
  );
  getIt.registerFactory<GetFavoritesUseCase>(
    () => GetFavoritesUseCase(getIt<FavoritesRepository>()),
  );
  getIt.registerFactory<GetMediaCollectionsUseCase>(
    () => GetMediaCollectionsUseCase(getIt<MediaCollectionsRepository>()),
  );
  getIt.registerFactory<ToggleFavoriteUseCase>(
    () => ToggleFavoriteUseCase(getIt<MediaCollectionsRepository>()),
  );
  getIt.registerFactory<AddToWatchlistUseCase>(
    () => AddToWatchlistUseCase(getIt<MediaCollectionsRepository>()),
  );
  getIt.registerFactory<SearchByFiltersUseCase>(
    () => SearchByFiltersUseCase(getIt<SearchRepository>()),
  );

  // BLoCs / Cubits
  getIt.registerFactory<HomeBloc>(
    () => HomeBloc(
      getPopularContentUseCase: getIt<GetPopularContentUseCase>(),
      searchMediaUseCase: getIt<SearchMediaUseCase>(),
    ),
  );
  getIt.registerFactory<AuthCubit>(
    () => AuthCubit(
      repository: getIt<AuthRepository>(),
      signInUseCase: getIt<SignInUseCase>(),
      registerUseCase: getIt<RegisterUseCase>(),
    ),
  );
  getIt.registerFactory<SearchBloc>(
    () => SearchBloc(
      searchByFiltersUseCase: getIt<SearchByFiltersUseCase>(),
    ),
  );
}
