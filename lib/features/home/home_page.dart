import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project/core/constants.dart';
import 'package:project/core/di.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Movie Discovery'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {
              Navigator.of(context).pushNamed(AppConstants.profileRoute);
            },
          ),
          IconButton(
            icon: Icon(_showFilters ? Icons.filter_list : Icons.filter_list_outlined),
            onPressed: () {
              setState(() {
                _showFilters = !_showFilters;
              });
            },
          ),
        ],
      ),
      body: BlocProvider(
        create: (_) => HomeBloc(repository: getIt<HomeRepository>()),
        child: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            if (state.loading && state.searchResults.isEmpty) {
              return LoadingWidget(message: 'Завантаження...');
            }
            
            return Column(
              children: [
                // Пошук та фільтри
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Theme.of(context).cardColor,
                  child: Column(
                    children: [
                      TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Пошук за назвою...',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchController.clear();
                                    context.read<HomeBloc>().clearSearch();
                                    setState(() {});
                                  },
                                )
                              : null,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {});
                          if (value.isEmpty) {
                            context.read<HomeBloc>().clearSearch();
                          }
                        },
                        onSubmitted: (_) => _performSearch(context.read<HomeBloc>(), loadMore: false),
                      ),
                      if (_showFilters) ...[
                        const SizedBox(height: 12),
                        TextField(
                          controller: _genreController,
                          decoration: InputDecoration(
                            hintText: 'Жанр (наприклад: Action, Comedy, Drama)',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            helperText: 'Введіть назву жанру англійською',
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _yearController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  hintText: 'Рік',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Рейтинг: ${_rating.toStringAsFixed(1)}'),
                                  Slider(
                                    min: 0,
                                    max: 10,
                                    divisions: 20,
                                    value: _rating,
                                    onChanged: (val) => setState(() => _rating = val),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => _performSearch(context.read<HomeBloc>()),
                            child: const Text('Пошук'),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                
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
                                  ),
                                  MediaSliderSection(
                                    title: 'Популярні серіали',
                                    items: state.popularTvShows.take(10).toList(),
                                    onSeeMore: () => _openMediaList(
                                      context,
                                      MediaListCategory.popularTv,
                                      'Популярні серіали',
                                    ),
                                  ),
                                  MediaSliderSection(
                                    title: 'Усі фільми',
                                    items: state.allMovies.take(10).toList(),
                                    onSeeMore: () => _openMediaList(
                                      context,
                                      MediaListCategory.allMovies,
                                      'Усі фільми',
                                    ),
                                  ),
                                  MediaSliderSection(
                                    title: 'Усі серіали',
                                    items: state.allTvShows.take(10).toList(),
                                    onSeeMore: () => _openMediaList(
                                      context,
                                      MediaListCategory.allTv,
                                      'Усі серіали',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                ),
              ],
            );
          },
        ),
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
                            onPressed: () => _performSearch(context.read<HomeBloc>(), loadMore: true),
                            child: const Text('Завантажити більше'),
                          ),
                  );
                }
                return const SizedBox.shrink();
              }
              final item = state.searchResults[index];
              return MediaPosterCard(
                item: item,
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
              if (index == state.searchResults.length - 1 && state.hasMoreResults) {
                return const SizedBox(height: 12);
              }
              return const SizedBox(height: 12);
            },
            itemCount: state.searchResults.length + (state.hasMoreResults ? 1 : 0),
          ),
        ),
      ],
    );
  }

  void _openMediaList(BuildContext context, MediaListCategory category, String title) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MediaListPage(
          category: category,
          title: title,
        ),
      ),
    );
  }
}

class MediaSliderSection extends StatelessWidget {
  final String title;
  final List<HomeMediaItem> items;
  final VoidCallback onSeeMore;

  const MediaSliderSection({
    super.key,
    required this.title,
    required this.items,
    required this.onSeeMore,
  });

  @override
  Widget build(BuildContext context) {
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
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                TextButton(
                  onPressed: onSeeMore,
                  child: const Text('Більше'),
                ),
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

  const MediaPosterCard({super.key, required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        width: 160,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 2 / 3,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: item.posterPath != null && item.posterPath!.isNotEmpty
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