import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../l10n/app_localizations.dart';
import 'package:project/core/di.dart';
import 'package:project/core/responsive.dart';
import 'package:project/core/theme.dart';
import 'package:project/core/page_transitions.dart';
import 'package:project/features/collections/media_collections_bloc.dart';
import 'package:project/features/collections/media_collections_event.dart';
import 'package:project/shared/widgets/animated_loading_widget.dart';
import 'package:project/shared/widgets/auth_dialog.dart';

import 'package:project/features/home/home_media_item.dart';
import 'domain/usecases/get_popular_content_usecase.dart';
import 'media_detail_page.dart';
import 'home_page.dart';
import 'package:project/core/network/retry_helper.dart';

enum MediaListCategory { popularMovies, popularTv, allMovies, allTv }

class MediaListPage extends StatefulWidget {
  final MediaListCategory category;
  final String title;

  const MediaListPage({super.key, required this.category, required this.title});

  @override
  State<MediaListPage> createState() => _MediaListPageState();
}

class _MediaListPageState extends State<MediaListPage> {
  late final GetPopularContentUseCase _getPopularContentUseCase =
      getIt<GetPopularContentUseCase>();
  late final MediaCollectionsBloc _collectionsBloc =
      getIt<MediaCollectionsBloc>();
  List<HomeMediaItem> _items = [];
  bool _loading = true;
  String _error = '';

  Future<void> _showAuthDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    await AuthDialog.show(
      context,
      title: l10n.authorizationRequired,
      message: l10n.loginToAddToFavorites,
      icon: Icons.favorite_border,
    );
  }

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    setState(() {
      _loading = true;
      _error = '';
    });
    try {
      List<HomeMediaItem> items;

      // Використання use case з retry механізмом для мережевих помилок
      final result = await RetryHelper.retry(
        operation: () =>
            _getPopularContentUseCase(const GetPopularContentParams(page: 1)),
      );

      switch (widget.category) {
        case MediaListCategory.popularMovies:
          items = result.popularMovies;
          break;
        case MediaListCategory.popularTv:
          items = result.popularTvShows;
          break;
        case MediaListCategory.allMovies:
          items = result.allMovies;
          break;
        case MediaListCategory.allTv:
          items = result.allTvShows;
          break;
      }
      setState(() {
        _items = items;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  IconData _getCategoryIcon() {
    switch (widget.category) {
      case MediaListCategory.popularMovies:
        return Icons.local_fire_department;
      case MediaListCategory.popularTv:
        return Icons.trending_up;
      case MediaListCategory.allMovies:
        return Icons.movie;
      case MediaListCategory.allTv:
        return Icons.tv;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final horizontalPadding = Responsive.getHorizontalPadding(context);
    final isMobile = Responsive.isMobile(context);

    return Scaffold(
      backgroundColor: colors.surface,
      body: Container(
        decoration: AppGradients.background(context),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Column(
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding.left,
                      Responsive.isMobile(context) ? 16 : 20,
                      horizontalPadding.right,
                      Responsive.getSpacing(context) / 2,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _getCategoryIcon(),
                          color: colors.primary,
                          size: Responsive.isMobile(context) ? 24 : 28,
                        ),
                        SizedBox(width: Responsive.isMobile(context) ? 10 : 12),
                        Expanded(
                          child: Text(
                            widget.title,
                            style: TextStyle(
                              color: colors.onSurface,
                              fontSize: Responsive.isMobile(context) ? 20 : 24,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: _loading
                        ? AnimatedLoadingWidget(
                            message: AppLocalizations.of(context)!.loading,
                          )
                        : _error.isNotEmpty
                        ? Center(
                            child: Padding(
                              padding: Responsive.getHorizontalPadding(context),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    size: Responsive.isMobile(context)
                                        ? 64
                                        : 80,
                                    color: colors.onSurfaceVariant.withValues(
                                      alpha: 0.6,
                                    ),
                                  ),
                                  SizedBox(
                                    height: Responsive.getSpacing(context),
                                  ),
                                  Text(
                                    _error,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: Responsive.isMobile(context)
                                          ? 16
                                          : 18,
                                      color: colors.onSurface,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(
                                    height:
                                        Responsive.getSpacing(context) * 1.5,
                                  ),
                                  FilledButton.icon(
                                    onPressed: _loadItems,
                                    icon: const Icon(Icons.refresh),
                                    label: const Text('Спробувати знову'),
                                    style: FilledButton.styleFrom(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: Responsive.isMobile(context)
                                            ? 24
                                            : 32,
                                        vertical: Responsive.isMobile(context)
                                            ? 12
                                            : 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : BlocBuilder<
                            MediaCollectionsBloc,
                            MediaCollectionsState
                          >(
                            bloc: _collectionsBloc,
                            buildWhen: (previous, current) =>
                                previous.authorized != current.authorized,
                            builder: (context, collectionsState) {
                              final canModify = collectionsState.authorized;
                              return RefreshIndicator(
                                onRefresh: _loadItems,
                                edgeOffset: 70,
                                child: isMobile
                                    ? _buildList(
                                        context,
                                        theme,
                                        colors,
                                        canModify,
                                        collectionsState,
                                        horizontalPadding,
                                      )
                                    : _buildGrid(
                                        context,
                                        theme,
                                        colors,
                                        canModify,
                                        collectionsState,
                                        horizontalPadding,
                                      ),
                              );
                            },
                          ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildList(
    BuildContext context,
    ThemeData theme,
    ColorScheme colors,
    bool canModify,
    dynamic collectionsState,
    EdgeInsets horizontalPadding,
  ) {
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(
        horizontalPadding.left,
        8,
        horizontalPadding.right,
        24,
      ),
      itemCount: _items.length,
      itemBuilder: (context, index) {
        final item = _items[index];
        final isFavorite = canModify && collectionsState.isFavorite(item);
        return RepaintBoundary(
          child: Container(
            margin: EdgeInsets.only(bottom: Responsive.getSpacing(context)),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: colors.outlineVariant.withValues(alpha: 0.8),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(
                    alpha: theme.brightness == Brightness.light ? 0.08 : 0.25,
                  ),
                  blurRadius: 12,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () {
                Navigator.of(
                  context,
                ).push(DetailPageRoute(child: MediaDetailPage(item: item)));
              },
              child: Padding(
                padding: EdgeInsets.all(Responsive.isMobile(context) ? 12 : 16),
                child: Row(
                  children: [
                    Hero(
                      tag: 'poster_${item.id}_${item.isMovie ? 'movie' : 'tv'}',
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: SizedBox(
                          height: Responsive.isMobile(context) ? 120 : 140,
                          width: Responsive.isMobile(context) ? 90 : 105,
                          child:
                              item.posterPath != null &&
                                  item.posterPath!.isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl:
                                      'https://image.tmdb.org/t/p/w300${item.posterPath}',
                                  fit: BoxFit.cover,
                                  memCacheWidth: 300,
                                  memCacheHeight: 450,
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
                                        color: Colors.white.withValues(
                                          alpha: 0.7,
                                        ),
                                      ),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      Container(
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
                                    color: colors.onSurfaceVariant.withValues(
                                      alpha: 0.7,
                                    ),
                                    size: 32,
                                  ),
                                ),
                        ),
                      ),
                    ),
                    SizedBox(width: Responsive.isMobile(context) ? 14 : 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: TextStyle(
                              fontSize: Responsive.isMobile(context) ? 16 : 18,
                              fontWeight: FontWeight.w700,
                              color: colors.onSurface,
                            ),
                          ),
                          SizedBox(
                            height: Responsive.isMobile(context) ? 6 : 8,
                          ),
                          Text(
                            item.overview,
                            maxLines: Responsive.isMobile(context) ? 3 : 4,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: colors.onSurfaceVariant.withValues(
                                alpha: 0.7,
                              ),
                              fontSize: Responsive.isMobile(context) ? 14 : 15,
                              height: 1.4,
                            ),
                          ),
                          SizedBox(
                            height: Responsive.isMobile(context) ? 12 : 14,
                          ),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: colors.surfaceContainerHighest
                                      .withValues(
                                        alpha:
                                            theme.brightness == Brightness.light
                                            ? 0.7
                                            : 0.25,
                                      ),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: colors.outlineVariant.withValues(
                                      alpha: 0.8,
                                    ),
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
                                onPressed: canModify
                                    ? () => _collectionsBloc.add(
                                        ToggleFavoriteEvent(item),
                                      )
                                    : () => _showAuthDialog(context),
                                icon: Icon(
                                  isFavorite
                                      ? Icons.favorite
                                      : Icons.favorite_border_rounded,
                                  color: isFavorite
                                      ? const Color(0xFFFF6B6B)
                                      : colors.onSurfaceVariant.withValues(
                                          alpha: 0.7,
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
          ),
        );
      },
    );
  }

  Widget _buildGrid(
    BuildContext context,
    ThemeData theme,
    ColorScheme colors,
    bool canModify,
    dynamic collectionsState,
    EdgeInsets horizontalPadding,
  ) {
    final columns = Responsive.getGridColumnCount(context);
    final spacing = Responsive.getSpacing(context);
    // Адаптивний aspect ratio залежно від розміру екрана та орієнтації
    final aspectRatio = Responsive.getMediaCardAspectRatio(context);

    return GridView.builder(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding.left,
        vertical: Responsive.getSpacing(context) / 2,
      ),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
        childAspectRatio: aspectRatio,
      ),
      itemCount: _items.length,
      itemBuilder: (context, index) {
        final item = _items[index];
        final isFavorite = canModify && collectionsState.isFavorite(item);

        return RepaintBoundary(
          child: MediaPosterCard(
            item: item,
            isFavorite: isFavorite,
            onFavoriteToggle: canModify
                ? () => _collectionsBloc.add(ToggleFavoriteEvent(item))
                : () => _showAuthDialog(context),
            onTap: () {
              Navigator.of(
                context,
              ).push(DetailPageRoute(child: MediaDetailPage(item: item)));
            },
          ),
        );
      },
    );
  }
}
