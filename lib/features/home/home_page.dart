import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project/core/constants.dart';
import 'package:project/core/di.dart';
import 'package:project/features/collections/media_collections_cubit.dart';
import 'package:project/shared/widgets/loading_widget.dart';

import 'home_bloc.dart';
import 'home_media_item.dart';
import 'home_repository.dart';
import 'media_list_page.dart';
import 'media_detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _genreController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  double _rating = 5.0;
  bool _showFilters = false;

  Future<void> _showAuthRequiredDialog(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Потрібна авторизація'),
        content: const Text('Увійдіть, щоб додавати медіа до вподобань.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Скасувати'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pushNamed(AppConstants.loginRoute);
            },
            child: const Text('Увійти'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _genreController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  void _performSearch(HomeBloc bloc, {bool loadMore = false}) {
    final query = _searchController.text.trim();
    final genreName = _genreController.text.trim();
    final year = int.tryParse(_yearController.text);

    bloc.search(
      query: query.isEmpty ? null : query,
      genreName: genreName.isEmpty ? null : genreName,
      year: year,
      rating: _rating,
      loadMore: loadMore,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => HomeBloc(repository: getIt<HomeRepository>()),
        ),
        BlocProvider.value(value: getIt<MediaCollectionsCubit>()),
      ],
      child: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          if (state.loading && state.searchResults.isEmpty) {
            return LoadingWidget(message: 'Завантаження...');
          }

          return Column(
            children: [
              // Результати пошуку або основні секції
              Expanded(
                child: state.searchResults.isNotEmpty
                    ? _buildSearchResults(context, state)
                    : state.error.isNotEmpty
                    ? Center(child: Text(state.error))
                    : RefreshIndicator(
                        onRefresh: () => context.read<HomeBloc>().loadContent(),
                        child: ListView(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          children: [
                            MediaSliderSection(
                              title: 'Популярні фільми',
                              items: state.popularMovies.take(10).toList(),
                              onSeeMore: () => _openMediaList(
                                context,
                                MediaListCategory.popularMovies,
                                'Популярні фільми',
                              ),
                              onAuthRequired: () =>
                                  _showAuthRequiredDialog(context),
                            ),
                            MediaSliderSection(
                              title: 'Популярні серіали',
                              items: state.popularTvShows.take(10).toList(),
                              onSeeMore: () => _openMediaList(
                                context,
                                MediaListCategory.popularTv,
                                'Популярні серіали',
                              ),
                              onAuthRequired: () =>
                                  _showAuthRequiredDialog(context),
                            ),
                            MediaSliderSection(
                              title: 'Усі фільми',
                              items: state.allMovies.take(10).toList(),
                              onSeeMore: () => _openMediaList(
                                context,
                                MediaListCategory.allMovies,
                                'Усі фільми',
                              ),
                              onAuthRequired: () =>
                                  _showAuthRequiredDialog(context),
                            ),
                            MediaSliderSection(
                              title: 'Усі серіали',
                              items: state.allTvShows.take(10).toList(),
                              onSeeMore: () => _openMediaList(
                                context,
                                MediaListCategory.allTv,
                                'Усі серіали',
                              ),
                              onAuthRequired: () =>
                                  _showAuthRequiredDialog(context),
                            ),
                          ],
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSearchResults(BuildContext context, HomeState state) {
    if (state.searching && state.searchResults.isEmpty) {
      return const LoadingWidget(message: 'Пошук...');
    }

    if (state.searchResults.isEmpty && !state.searching) {
      return const Center(child: Text('Нічого не знайдено'));
    }

    final collectionsCubit = context.watch<MediaCollectionsCubit>();
    final collectionsState = collectionsCubit.state;
    final canModifyCollections = collectionsState.authorized;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Результати пошуку (${state.searchResults.length}${state.hasMoreResults ? '+' : ''})',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              TextButton(
                onPressed: () => context.read<HomeBloc>().clearSearch(),
                child: const Text('Очистити'),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemBuilder: (context, index) {
              if (index == state.searchResults.length) {
                // Кнопка "Завантажити більше"
                if (state.hasMoreResults) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: state.loadingMore
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                            onPressed: () => _performSearch(
                              context.read<HomeBloc>(),
                              loadMore: true,
                            ),
                            child: const Text('Завантажити більше'),
                          ),
                  );
                }
                return const SizedBox.shrink();
              }
              final item = state.searchResults[index];
              return MediaPosterCard(
                item: item,
                isFavorite: canModifyCollections
                    ? collectionsState.isFavorite(item)
                    : false,
                onFavoriteToggle: canModifyCollections
                    ? () => collectionsCubit.toggleFavorite(item)
                    : () => _showAuthRequiredDialog(context),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => MediaDetailPage(item: item),
                    ),
                  );
                },
              );
            },
            separatorBuilder: (_, index) {
              if (index == state.searchResults.length - 1 &&
                  state.hasMoreResults) {
                return const SizedBox(height: 12);
              }
              return const SizedBox(height: 12);
            },
            itemCount:
                state.searchResults.length + (state.hasMoreResults ? 1 : 0),
          ),
        ),
      ],
    );
  }

  void _openMediaList(
    BuildContext context,
    MediaListCategory category,
    String title,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MediaListPage(category: category, title: title),
      ),
    );
  }
}

class MediaSliderSection extends StatelessWidget {
  final String title;
  final List<HomeMediaItem> items;
  final VoidCallback onSeeMore;
  final VoidCallback onAuthRequired;

  const MediaSliderSection({
    super.key,
    required this.title,
    required this.items,
    required this.onSeeMore,
    required this.onAuthRequired,
  });

  @override
  Widget build(BuildContext context) {
    final collectionsCubit = context.watch<MediaCollectionsCubit>();
    final collectionsState = collectionsCubit.state;
    final canModifyCollections = collectionsState.authorized;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleLarge),
                TextButton(onPressed: onSeeMore, child: const Text('Більше')),
              ],
            ),
          ),
          SizedBox(
            height: 260,
            child: items.isEmpty
                ? const Center(child: Text('Немає даних'))
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return MediaPosterCard(
                        item: item,
                        isFavorite: canModifyCollections
                            ? collectionsState.isFavorite(item)
                            : false,
                        onFavoriteToggle: canModifyCollections
                            ? () => collectionsCubit.toggleFavorite(item)
                            : onAuthRequired,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => MediaDetailPage(item: item),
                            ),
                          );
                        },
                      );
                    },
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemCount: items.length,
                  ),
          ),
        ],
      ),
    );
  }
}

class MediaPosterCard extends StatelessWidget {
  final HomeMediaItem item;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteToggle;
  final bool? isFavorite;
  final double? width;

  const MediaPosterCard({
    super.key,
    required this.item,
    this.onTap,
    this.onFavoriteToggle,
    this.isFavorite,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        width: width ?? 160,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 2 / 3,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child:
                          item.posterPath != null && item.posterPath!.isNotEmpty
                          ? Image.network(
                              'https://image.tmdb.org/t/p/w500${item.posterPath}',
                              fit: BoxFit.cover,
                            )
                          : Container(
                              color: Colors.grey.shade300,
                              child: const Icon(Icons.movie, size: 48),
                            ),
                    ),
                  ),
                  if (isFavorite != null && onFavoriteToggle != null)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: IconButton(
                          iconSize: 20,
                          splashRadius: 20,
                          onPressed: onFavoriteToggle,
                          icon: Icon(
                            isFavorite!
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: Colors.redAccent,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              item.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.star, size: 14, color: Colors.amber),
                const SizedBox(width: 4),
                Text(
                  item.rating.toStringAsFixed(1),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
