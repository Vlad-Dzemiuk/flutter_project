import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project/core/constants.dart';
import 'package:project/core/di.dart';
import 'package:project/features/collections/media_collections_cubit.dart';
import 'package:project/shared/widgets/loading_widget.dart';
import 'package:project/shared/widgets/home_header_widget.dart';
import 'package:project/core/theme.dart';

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
          final theme = Theme.of(context);
          final colors = theme.colorScheme;

          if (state.loading && state.searchResults.isEmpty) {
            return LoadingWidget(message: 'Завантаження...');
          }

          return Scaffold(
            backgroundColor: colors.background,
            body: Container(
              decoration: AppGradients.background(context),
              child: SafeArea(
                child: Stack(
                  children: [
                    Positioned(
                      top: -80,
                      right: -40,
                      child: _GlowCircle(
                        color: theme.brightness == Brightness.dark
                            ? Colors.purple.withOpacity(0.18)
                            : Colors.purple.withOpacity(0.08),
                      ),
                    ),
                    Positioned(
                      bottom: -120,
                      left: -60,
                      child: _GlowCircle(
                        color: theme.brightness == Brightness.dark
                            ? Colors.teal.withOpacity(0.14)
                            : Colors.teal.withOpacity(0.06),
                      ),
                    ),
                    state.searchResults.isNotEmpty
                        ? _buildSearchResults(context, state)
                        : state.error.isNotEmpty
                        ? _buildErrorWidget(context, state.error)
                        : RefreshIndicator(
                      onRefresh: () =>
                          context.read<HomeBloc>().loadContent(),
                      edgeOffset: 80,
                      child: ListView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.only(
                          left: 16,
                          right: 16,
                          bottom: 24,
                          top: 0,
                        ),
                        children: [
                          const HomeHeaderWidget(),
                          const SizedBox(height: 12),
                          MediaSliderSection(
                            title: 'Популярні фільми',
                            items:
                            state.popularMovies.take(10).toList(),
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
                            items:
                            state.popularTvShows.take(10).toList(),
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
                  ],
                ),
              ),
            ),
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

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Результати пошуку (${state.searchResults.length}${state.hasMoreResults ? '+' : ''})',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
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
                  if (state.hasMoreResults) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: state.loadingMore
                          ? const Center(child: CircularProgressIndicator())
                          : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
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
                final theme = Theme.of(context);
                final colors = theme.colorScheme;
                final isFavorite =
                    canModifyCollections && collectionsState.isFavorite(item);

                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: colors.outlineVariant.withOpacity(0.8),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(
                          theme.brightness == Brightness.light ? 0.08 : 0.25,
                        ),
                        blurRadius: 12,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => MediaDetailPage(item: item),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: SizedBox(
                              height: 120,
                              width: 90,
                              child: item.posterPath != null &&
                                  item.posterPath!.isNotEmpty
                                  ? Image.network(
                                'https://image.tmdb.org/t/p/w300${item.posterPath}',
                                fit: BoxFit.cover,
                              )
                                  : Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Colors.blueGrey.shade900,
                                      Colors.blueGrey.shade700,
                                    ],
                                  ),
                                ),
                                child: Icon(
                                  Icons.movie,
                                  color: colors.onSurfaceVariant
                                      .withOpacity(0.7),
                                  size: 32,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.title,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: colors.onBackground,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  item.overview,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: colors.onSurfaceVariant.withOpacity(
                                      0.7,
                                    ),
                                    height: 1.4,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: colors.surfaceVariant.withOpacity(
                                          theme.brightness == Brightness.light
                                              ? 0.7
                                              : 0.25,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: colors.outlineVariant
                                              .withOpacity(0.8),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.star,
                                            size: 16,
                                            color: Colors.amber,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            item.rating.toStringAsFixed(1),
                                            style: TextStyle(
                                              color: colors.onSurface,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Spacer(),
                                    IconButton(
                                      onPressed: canModifyCollections
                                          ? () => collectionsCubit.toggleFavorite(
                                        item,
                                      )
                                          : () =>
                                          _showAuthRequiredDialog(context),
                                      icon: Icon(
                                        isFavorite
                                            ? Icons.favorite
                                            : Icons.favorite_border_rounded,
                                        color: isFavorite
                                            ? const Color(0xFFFF6B6B)
                                            : colors.onSurfaceVariant.withOpacity(
                                          0.7,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
              separatorBuilder: (_, index) => const SizedBox(height: 12),
              itemCount:
              state.searchResults.length + (state.hasMoreResults ? 1 : 0),
            ),
          ),
        ],
      ),
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

  Widget _buildErrorWidget(BuildContext context, String error) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.wifi_off_outlined,
              size: 64,
              color: colors.onSurfaceVariant.withOpacity(0.6),
            ),
            const SizedBox(height: 16),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: colors.onBackground,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => context.read<HomeBloc>().loadContent(),
              icon: const Icon(Icons.refresh),
              label: const Text('Спробувати знову'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
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
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final collectionsCubit = context.watch<MediaCollectionsCubit>();
    final collectionsState = collectionsCubit.state;
    final canModifyCollections = collectionsState.authorized;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colors.outlineVariant.withOpacity(0.8)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: colors.primary,
                      ),
                    ),
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                TextButton(
                  style: TextButton.styleFrom(foregroundColor: colors.primary),
                  onPressed: onSeeMore,
                  child: const Text('Більше'),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 280,
            child: items.isEmpty
                ? const Center(child: Text('Немає даних'))
                : ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 4),
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
              separatorBuilder: (_, __) => const SizedBox(width: 14),
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
    final cardWidth = width ?? 168.0;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: SizedBox(
        width: cardWidth,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ===== POSTER =====
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: AspectRatio(
                    aspectRatio: 2 / 3,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: item.posterPath != null &&
                              item.posterPath!.isNotEmpty
                              ? Image.network(
                            'https://image.tmdb.org/t/p/w500${item.posterPath}',
                            fit: BoxFit.cover,
                          )
                              : Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.blueGrey.shade900,
                                  Colors.blueGrey.shade700,
                                ],
                              ),
                            ),
                            child: const Icon(Icons.movie, size: 48),
                          ),
                        ),
                        Positioned.fill(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black.withOpacity(0.05),
                                  Colors.black.withOpacity(0.40),
                                ],
                              ),
                            ),
                          ),
                        ),
                        if (isFavorite != null && onFavoriteToggle != null)
                          Positioned(
                            top: 8,
                            right: 8,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.55),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: IconButton(
                                iconSize: 20,
                                splashRadius: 20,
                                onPressed: onFavoriteToggle,
                                icon: Icon(
                                  isFavorite!
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: const Color(0xFFFF6B6B),
                                ),
                              ),
                            ),
                          ),
                        Positioned(
                          left: 10,
                          bottom: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.65),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.star,
                                    size: 16, color: Colors.amber),
                                const SizedBox(width: 6),
                                Text(
                                  item.rating.toStringAsFixed(1),
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(fontWeight: FontWeight.w700),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // ===== TITLE =====
                Text(
                  item.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),

                const SizedBox(height: 4),

                // ===== DESCRIPTION =====
                Text(
                  item.overview,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurfaceVariant
                        .withOpacity(0.7),
                    height: 1.3,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _GlowCircle extends StatelessWidget {
  final Color color;

  const _GlowCircle({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      height: 220,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, Colors.transparent]),
      ),
    );
  }
}
