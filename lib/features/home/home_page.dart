import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:project/core/constants.dart';
import 'package:project/core/di.dart';
import 'package:project/core/responsive.dart';
import 'package:project/core/loading_state.dart';
import 'package:project/features/collections/media_collections_bloc.dart';
import 'package:project/features/collections/media_collections_event.dart';
import 'package:project/shared/widgets/animated_loading_widget.dart';
import 'package:project/shared/widgets/home_header_widget.dart';
import 'package:project/shared/widgets/auth_dialog.dart';
import 'package:project/core/theme.dart';

import 'home_bloc.dart';
import 'home_event.dart';
import 'home_media_item.dart';
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
  final double _rating = 5.0;

  Future<void> _showAuthRequiredDialog(BuildContext context) async {
    await AuthDialog.show(
      context,
      title: 'Потрібна авторизація',
      message: 'Увійдіть, щоб додавати медіа до вподобань.',
      icon: Icons.favorite_border,
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

    bloc.add(SearchEvent(
      query: query.isEmpty ? null : query,
      genreName: genreName.isEmpty ? null : genreName,
      year: year,
      rating: _rating,
      loadMore: loadMore,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final loadingStateService = getIt<LoadingStateService>();
    
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => getIt<HomeBloc>(),
        ),
        BlocProvider.value(value: getIt<MediaCollectionsBloc>()),
      ],
      child: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          final theme = Theme.of(context);
          final colors = theme.colorScheme;

          // Перевіряємо, чи всі медіа матеріали завантажені
          // Завантаження вважається завершеним, коли:
          // 1. Не завантажується (loading = false)
          // 2. Не в режимі пошуку (searchResults.isEmpty)
          final isLoadingComplete = !state.loading && state.searchResults.isEmpty;
          
          // Всі категорії мають дані
          final allMediaLoaded = isLoadingComplete &&
              state.popularMovies.isNotEmpty &&
              state.popularTvShows.isNotEmpty &&
              state.allMovies.isNotEmpty &&
              state.allTvShows.isNotEmpty;

          // Встановлюємо, що головна сторінка завантажена, коли всі дані завантажені
          // Або коли завантаження завершено (навіть якщо є помилка - щоб не блокувати інші сторінки)
          if (allMediaLoaded || (isLoadingComplete && state.error.isNotEmpty)) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              loadingStateService.setHomePageLoaded();
            });
          }

          // Показуємо завантаження, поки не завантажаться всі медіа
          // Але якщо є помилка і завантаження завершено, все одно показуємо помилку
          if (state.loading && state.searchResults.isEmpty) {
            return const AnimatedLoadingWidget(message: 'Завантаження...');
          }
          
          // Якщо завантаження завершено, але не всі дані завантажені, показуємо завантаження
          if (isLoadingComplete && !allMediaLoaded && state.error.isEmpty) {
            return const AnimatedLoadingWidget(message: 'Завантаження...');
          }

          return Scaffold(
            backgroundColor: colors.surface,
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
                            ? Colors.purple.withValues(alpha: 0.18)
                            : Colors.purple.withValues(alpha: 0.08),
                      ),
                    ),
                    Positioned(
                      bottom: -120,
                      left: -60,
                      child: _GlowCircle(
                        color: theme.brightness == Brightness.dark
                            ? Colors.teal.withValues(alpha: 0.14)
                            : Colors.teal.withValues(alpha: 0.06),
                      ),
                    ),
                    state.searchResults.isNotEmpty
                        ? _buildSearchResults(context, state)
                        : state.error.isNotEmpty
                        ? _buildErrorWidget(context, state.error)
                        : RefreshIndicator(
                      onRefresh: () async {
                        context.read<HomeBloc>().add(const LoadContentEvent());
                      },
                      edgeOffset: 80,
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final horizontalPadding = Responsive
                              .getHorizontalPadding(context);
                          return ListView(
                            physics: const BouncingScrollPhysics(),
                            padding: EdgeInsets.only(
                              left: horizontalPadding.left,
                              right: horizontalPadding.right,
                              bottom: 24,
                              top: 0,
                            ),
                            children: [
                              const HomeHeaderWidget(),
                              SizedBox(height: Responsive.getSpacing(context)),
                              MediaSliderSection(
                                title: 'Популярні фільми',
                                items: state.popularMovies.take(10).toList(),
                                onSeeMore: () =>
                                    _openMediaList(
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
                                onSeeMore: () =>
                                    _openMediaList(
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
                                onSeeMore: () =>
                                    _openMediaList(
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
                                onSeeMore: () =>
                                    _openMediaList(
                                      context,
                                      MediaListCategory.allTv,
                                      'Усі серіали',
                                    ),
                                onAuthRequired: () =>
                                    _showAuthRequiredDialog(context),
                              ),
                            ],
                          );
                        },
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
      return const AnimatedLoadingWidget(message: 'Завантаження...');
    }

    if (state.searchResults.isEmpty && !state.searching) {
      return const Center(child: Text('Нічого не знайдено'));
    }

    final collectionsBloc = context.watch<MediaCollectionsBloc>();
    final collectionsState = collectionsBloc.state;
    final canModifyCollections = collectionsState.authorized;

    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final horizontalPadding = Responsive.getHorizontalPadding(context);
          final isMobile = Responsive.isMobile(context);

          return Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding.left,
                  16,
                  horizontalPadding.right,
                  8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        'Результати пошуку (${state.searchResults.length}${state
                            .hasMoreResults ? '+' : ''})',
                        style: Theme
                            .of(
                          context,
                        )
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.read<HomeBloc>().add(const ClearSearchEvent()),
                      child: const Text('Очистити'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: isMobile
                    ? _buildSearchResultsList(
                    context, state, horizontalPadding, canModifyCollections,
                    collectionsBloc)
                    : _buildSearchResultsGrid(
                    context, state, horizontalPadding, canModifyCollections,
                    collectionsBloc),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSearchResultsList(BuildContext context,
      HomeState state,
      EdgeInsets horizontalPadding,
      bool canModifyCollections,
      MediaCollectionsBloc collectionsBloc,) {
    final collectionsState = collectionsBloc.state;

    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding.left),
      itemBuilder: (context, index) {
        if (index == state.searchResults.length) {
          if (state.hasMoreResults) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: state.loadingMore
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme
                      .of(
                    context,
                  )
                      .colorScheme
                      .primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () =>
                    _performSearch(
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
              color: colors.outlineVariant.withValues(alpha: 0.8),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha:
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
                          ? CachedNetworkImage(
                        imageUrl: 'https://image.tmdb.org/t/p/w300${item.posterPath}',
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
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
                          child: Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white.withValues(alpha: 0.7),
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
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
                                .withValues(alpha: 0.7),
                            size: 32,
                          ),
                        ),
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
                              .withValues(alpha: 0.7),
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
                            color: colors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          item.overview,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: colors.onSurfaceVariant.withValues(alpha:
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
                                color: colors.surfaceContainerHighest.withValues(alpha:
                                  theme.brightness == Brightness.light
                                      ? 0.7
                                      : 0.25,
                                ),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: colors.outlineVariant
                                      .withValues(alpha: 0.8),
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
                                  ? () =>
                                  collectionsBloc.add(ToggleFavoriteEvent(
                                    item,
                                  ))
                                  : () =>
                                  _showAuthRequiredDialog(context),
                              icon: Icon(
                                isFavorite
                                    ? Icons.favorite
                                    : Icons.favorite_border_rounded,
                                color: isFavorite
                                    ? const Color(0xFFFF6B6B)
                                    : colors.onSurfaceVariant.withValues(alpha:
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
      separatorBuilder: (_, index) =>
          SizedBox(height: Responsive.getSpacing(context)),
      itemCount:
      state.searchResults.length + (state.hasMoreResults ? 1 : 0),
    );
  }

  Widget _buildSearchResultsGrid(BuildContext context,
      HomeState state,
      EdgeInsets horizontalPadding,
      bool canModifyCollections,
      MediaCollectionsBloc collectionsBloc,) {
    final collectionsState = collectionsBloc.state;
    final columns = Responsive.getGridColumnCount(context);
    final spacing = Responsive.getSpacing(context);

    return GridView.builder(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding.left,
        vertical: 8,
      ),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
        childAspectRatio: Responsive.getMediaCardAspectRatio(context),
      ),
      itemBuilder: (context, index) {
        if (index == state.searchResults.length) {
          if (state.hasMoreResults) {
            return Padding(
              padding: EdgeInsets.symmetric(vertical: spacing),
              child: state.loadingMore
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme
                      .of(context)
                      .colorScheme
                      .primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () =>
                    _performSearch(
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
        final isFavorite = canModifyCollections &&
            collectionsState.isFavorite(item);

        return MediaPosterCard(
          item: item,
          isFavorite: isFavorite,
          onFavoriteToggle: canModifyCollections
              ? () => collectionsBloc.add(ToggleFavoriteEvent(item))
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
      itemCount: state.searchResults.length + (state.hasMoreResults ? 1 : 0),
    );
  }

  void _openMediaList(BuildContext context,
      MediaListCategory category,
      String title,) {
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
              color: colors.onSurfaceVariant.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 16),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: colors.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => context.read<HomeBloc>().add(const LoadContentEvent()),
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
    final collectionsBloc = context.watch<MediaCollectionsBloc>();
    final collectionsState = collectionsBloc.state;
    final canModifyCollections = collectionsState.authorized;
    final isMobile = Responsive.isMobile(context);
    final spacing = Responsive.getSpacing(context);

    return Padding(
      padding: Responsive.getVerticalPadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: Responsive.isMobile(context) ? 14 : 20,
              vertical: 12,
            ),
            margin: EdgeInsets.only(bottom: spacing / 2),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.8)),
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
                      style: Theme
                          .of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(
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
          items.isEmpty
              ? const Center(child: Text('Немає даних'))
              : isMobile
              ? _buildHorizontalList(
              context, collectionsBloc, collectionsState, canModifyCollections)
              : _buildGrid(context, collectionsBloc, collectionsState,
              canModifyCollections),
        ],
      ),
    );
  }

  Widget _buildHorizontalList(BuildContext context,
      MediaCollectionsBloc collectionsBloc,
      dynamic collectionsState,
      bool canModifyCollections,) {
    // Розраховуємо ширину картки для горизонтального списку
    // Використовуємо aspect ratio 2/3 для постерів
    final cardHeight = 280.0;
    final cardWidth = cardHeight * (2 / 3);
    
    return SizedBox(
      height: cardHeight,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final item = items[index];
          return MediaPosterCard(
            item: item,
            width: cardWidth,
            height: cardHeight,
            isFavorite: canModifyCollections
                ? collectionsState.isFavorite(item)
                : false,
            onFavoriteToggle: canModifyCollections
                ? () => collectionsBloc.add(ToggleFavoriteEvent(item))
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
        separatorBuilder: (_, __) =>
            SizedBox(width: Responsive.getSpacing(context)),
        itemCount: items.length,
      ),
    );
  }

  Widget _buildGrid(BuildContext context,
      MediaCollectionsBloc collectionsBloc,
      dynamic collectionsState,
      bool canModifyCollections,) {
    final columns = Responsive.getGridColumnCount(context);
    final spacing = Responsive.getSpacing(context);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
        childAspectRatio: Responsive.getMediaCardAspectRatio(context),
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return MediaPosterCard(
          item: item,
          isFavorite: canModifyCollections
              ? collectionsState.isFavorite(item)
              : false,
          onFavoriteToggle: canModifyCollections
              ? () => collectionsBloc.add(ToggleFavoriteEvent(item))
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
    );
  }
}

class MediaPosterCard extends StatelessWidget {
  final HomeMediaItem item;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteToggle;
  final bool? isFavorite;
  final double? width;
  final double? height;

  const MediaPosterCard({
    super.key,
    required this.item,
    this.onTap,
    this.onFavoriteToggle,
    this.isFavorite,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    // Якщо width вказано, використовуємо його (для горизонтальних списків)
    // Якщо не вказано, GridView сам визначить ширину
    final cardWidth = width;
    final cardHeight = height;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: cardWidth != null
          ? SizedBox(
        width: cardWidth,
        height: cardHeight,
        child: _buildCardContent(context),
      )
          : _buildCardContent(context),
    );
  }

  Widget _buildCardContent(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Розраховуємо доступну висоту для тексту (загальна висота мінус постер і відступи)
        final cardWidth = width;
        final cardHeight = height;
        final posterHeight = cardWidth != null ? cardWidth * 1.5 : constraints.maxWidth * 1.5;
        final totalHeight = cardHeight ?? constraints.maxHeight;
        final availableHeight = totalHeight > 0 
            ? totalHeight - posterHeight - 8 - 4 // poster + spacing + title spacing
            : null;
        
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
                          ? Container(
                        width: double.infinity,
                        height: double.infinity,
                        child: CachedNetworkImage(
                          imageUrl: 'https://image.tmdb.org/t/p/w500${item.posterPath}',
                          fit: BoxFit.cover,
                          memCacheWidth: 500,
                          memCacheHeight: 750,
                          fadeInDuration: const Duration(milliseconds: 300),
                          placeholder: (context, url) => Container(
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
                            child: const Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white70,
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) {
                            debugPrint('Error loading image: $url, error: $error');
                            return Container(
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
                            );
                          },
                        ),
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
                              Colors.black.withValues(alpha: 0.05),
                              Colors.black.withValues(alpha: 0.40),
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
                            color: Colors.black.withValues(alpha: 0.55),
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
                          color: Colors.black.withValues(alpha: 0.65),
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
                              style: Theme
                                  .of(context)
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
              style: Theme
                  .of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),

            const SizedBox(height: 4),

            // ===== DESCRIPTION =====
            availableHeight != null && availableHeight > 0
                ? SizedBox(
                    height: availableHeight.clamp(0.0, 40.0), // Обмежуємо максимальну висоту
                    child: Text(
                      item.overview,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme
                          .of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(
                        color: Theme
                            .of(context)
                            .colorScheme
                            .onSurfaceVariant
                            .withValues(alpha: 0.7),
                        height: 1.3,
                      ),
                    ),
                  )
                : Text(
                    item.overview,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme
                        .of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(
                      color: Theme
                          .of(context)
                          .colorScheme
                          .onSurfaceVariant
                          .withValues(alpha: 0.7),
                      height: 1.3,
                    ),
                  ),
          ],
        );
      },
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
