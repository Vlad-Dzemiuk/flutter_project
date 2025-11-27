import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project/core/constants.dart';
import 'package:project/core/di.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: _loading
          ? const LoadingWidget(message: 'Завантаження...')
          : _error.isNotEmpty
          ? Center(child: Text(_error))
          : BlocBuilder<MediaCollectionsCubit, MediaCollectionsState>(
              bloc: _collectionsCubit,
              builder: (context, collectionsState) {
                final canModify = collectionsState.authorized;
                return RefreshIndicator(
                  onRefresh: _loadItems,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemBuilder: (context, index) {
                      final item = _items[index];
                      final isFavorite =
                          canModify && collectionsState.isFavorite(item);
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(vertical: 8),
                        leading: SizedBox(
                          width: 60,
                          child:
                              item.posterPath != null &&
                                  item.posterPath!.isNotEmpty
                              ? Image.network(
                                  'https://image.tmdb.org/t/p/w200${item.posterPath}',
                                  fit: BoxFit.cover,
                                )
                              : const Icon(Icons.movie, size: 40),
                        ),
                        title: Text(item.title),
                        subtitle: Text(
                          item.overview,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.star,
                                  size: 16,
                                  color: Colors.amber,
                                ),
                                const SizedBox(width: 4),
                                Text(item.rating.toStringAsFixed(1)),
                              ],
                            ),
                            canModify
                                ? IconButton(
                                    icon: Icon(
                                      isFavorite
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      color: Colors.redAccent,
                                    ),
                                    onPressed: () =>
                                        _collectionsCubit.toggleFavorite(item),
                                  )
                                : IconButton(
                                    icon: const Icon(
                                      Icons.favorite_border,
                                      color: Colors.grey,
                                    ),
                                    onPressed: () => _showAuthDialog(context),
                                  ),
                          ],
                        ),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => MediaDetailPage(item: item),
                            ),
                          );
                        },
                      );
                    },
                    separatorBuilder: (_, __) => const Divider(),
                    itemCount: _items.length,
                  ),
                );
              },
            ),
    );
  }
}
