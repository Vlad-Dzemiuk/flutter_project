import 'package:flutter/material.dart';
import 'package:project/core/di.dart';
import 'package:project/shared/widgets/loading_widget.dart';

import 'home_repository.dart';
import 'movie_model.dart';

enum MoviesListType { popular, all }

class MoviesListPage extends StatefulWidget {
  final MoviesListType type;
  final String title;

  const MoviesListPage({
    super.key,
    required this.type,
    required this.title,
  });

  @override
  State<MoviesListPage> createState() => _MoviesListPageState();
}

class _MoviesListPageState extends State<MoviesListPage> {
  late final HomeRepository _repository = getIt<HomeRepository>();
  List<Movie> _movies = [];
  bool _loading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadMovies();
  }

  Future<void> _loadMovies() async {
    setState(() {
      _loading = true;
      _error = '';
    });
    try {
      final result = widget.type == MoviesListType.popular
          ? await _repository.fetchPopularMovies(page: 1)
          : await _repository.fetchAllMovies(page: 1);
      setState(() {
        _movies = result;
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
              : RefreshIndicator(
                  onRefresh: _loadMovies,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemBuilder: (context, index) {
                      final movie = _movies[index];
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(vertical: 8),
                        leading: SizedBox(
                          width: 60,
                          child: movie.posterPath != null && movie.posterPath!.isNotEmpty
                              ? Image.network(
                                  'https://image.tmdb.org/t/p/w200${movie.posterPath}',
                                  fit: BoxFit.cover,
                                )
                              : const Icon(Icons.movie, size: 40),
                        ),
                        title: Text(movie.title),
                        subtitle: Text(
                          movie.overview,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star, size: 16, color: Colors.amber),
                            const SizedBox(width: 4),
                            Text(movie.voteAverage.toStringAsFixed(1)),
                          ],
                        ),
                      );
                    },
                    separatorBuilder: (_, __) => const Divider(),
                    itemCount: _movies.length,
                  ),
                ),
    );
  }
}

