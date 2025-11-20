import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project/core/di.dart';
import 'package:project/shared/widgets/loading_widget.dart';

import 'home_bloc.dart';
import 'home_media_item.dart';
import 'home_repository.dart';
import 'media_list_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Movie Discovery')),
      body: BlocProvider(
        create: (_) => HomeBloc(repository: getIt<HomeRepository>()),
        child: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            if (state.loading) return LoadingWidget(message: 'Завантаження...');
            if (state.error.isNotEmpty) return Center(child: Text(state.error));
            return RefreshIndicator(
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
            );
          },
        ),
      ),
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
                      return MediaPosterCard(item: item);
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

  const MediaPosterCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
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
    );
  }
}