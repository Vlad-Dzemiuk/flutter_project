import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project/core/constants.dart';
import 'package:project/core/di.dart';
import 'package:project/core/theme.dart';
import 'package:project/features/collections/media_collections_cubit.dart';
import 'package:project/shared/widgets/loading_widget.dart';

import 'home_media_item.dart';
import 'home_repository.dart';
import 'media_detail_page.dart';

enum MediaListCategory { popularMovies, popularTv, allMovies, allTv }

class MediaListPage extends StatefulWidget {
  final MediaListCategory category;
  final String title;

  const MediaListPage({super.key, required this.category, required this.title});

  @override
  State<MediaListPage> createState() => _MediaListPageState();
}

class _MediaListPageState extends State<MediaListPage> {
  late final HomeRepository _repository = getIt<HomeRepository>();
  late final MediaCollectionsCubit _collectionsCubit =
      getIt<MediaCollectionsCubit>();
  List<HomeMediaItem> _items = [];
  bool _loading = true;
  String _error = '';

  Future<void> _showAuthDialog(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Потрібна авторизація'),
        content: const Text('Увійдіть, щоб додавати у вподобання.'),
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
      switch (widget.category) {
        case MediaListCategory.popularMovies:
          final movies = await _repository.fetchPopularMovies(page: 1);
          items = movies.map((m) => HomeMediaItem.fromMovie(m)).toList();
          break;
        case MediaListCategory.popularTv:
          final tvShows = await _repository.fetchPopularTvShows(page: 1);
          items = tvShows.map((t) => HomeMediaItem.fromTvShow(t)).toList();
          break;
        case MediaListCategory.allMovies:
          final movies = await _repository.fetchAllMovies(page: 1);
          items = movies.map((m) => HomeMediaItem.fromMovie(m)).toList();
          break;
        case MediaListCategory.allTv:
          final tvShows = await _repository.fetchAllTvShows(page: 1);
          items = tvShows.map((t) => HomeMediaItem.fromTvShow(t)).toList();
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
    
    return Scaffold(
      backgroundColor: colors.background,
      body: Container(
        decoration: AppGradients.background(context),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  children: [
                    Icon(_getCategoryIcon(), color: colors.primary),
                    const SizedBox(width: 10),
                    Text(
                      widget.title,
                      style: TextStyle(
                        color: colors.onBackground,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _loading
            ? const LoadingWidget(message: 'Завантаження...')
                  : _error.isNotEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  size: 64,
                                  color: colors.onSurfaceVariant.withOpacity(0.6),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _error,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: colors.onBackground,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                FilledButton.icon(
                                  onPressed: _loadItems,
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
                        )
                      : BlocBuilder<MediaCollectionsCubit, MediaCollectionsState>(
                          bloc: _collectionsCubit,
                          builder: (context, collectionsState) {
                            final canModify = collectionsState.authorized;
                            return RefreshIndicator(
                              onRefresh: _loadItems,
                              edgeOffset: 70,
                              child: ListView.builder(
                                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                                itemCount: _items.length,
                                itemBuilder: (context, index) {
                            final item = _items[index];
                            final isFavorite =
                                canModify && collectionsState.isFavorite(item);
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
                                      theme.brightness == Brightness.light
                                          ? 0.08
                                          : 0.25,
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
                                      builder: (_) =>
                                          MediaDetailPage(item: item),
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
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
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
                                                color: colors.onSurfaceVariant
                                                    .withOpacity(0.7),
                                                height: 1.4,
                                              ),
                                            ),
                                            const SizedBox(height: 12),
                                            Row(
                                              children: [
                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 6,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: colors.surfaceVariant
                                                        .withOpacity(
                                                      theme.brightness ==
                                                              Brightness.light
                                                          ? 0.7
                                                          : 0.25,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(12),
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
                                                        item.rating
                                                            .toStringAsFixed(1),
                                                        style: TextStyle(
                                                          color: colors.onSurface,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                const Spacer(),
                                                IconButton(
                                                  onPressed: canModify
                                                      ? () => _collectionsCubit
                                                          .toggleFavorite(item)
                                                      : () => _showAuthDialog(
                                                          context),
                                                  icon: Icon(
                                                    isFavorite
                                                        ? Icons.favorite
                                                        : Icons
                                                            .favorite_border_rounded,
                                                    color: isFavorite
                                                        ? const Color(0xFFFF6B6B)
                                                        : colors.onSurfaceVariant
                                                            .withOpacity(0.7),
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
                        ),
                      );
                    },
                  ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
