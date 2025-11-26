import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../home/home_api_service.dart';
import '../home/home_media_item.dart';
import '../home/media_detail_page.dart';
import 'search_bloc.dart';
import 'search_event.dart';
import 'search_state.dart';
import 'search_repository.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _genreController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  double _rating = 5.0;

  late final SearchBloc _searchBloc;

  @override
  void initState() {
    super.initState();
    final apiService = HomeApiService();
    final repository = SearchRepository(apiService);
    _searchBloc = SearchBloc(repository);
  }

  @override
  void dispose() {
    _genreController.dispose();
    _yearController.dispose();
    _searchBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => _searchBloc,
      child: Scaffold(
        appBar: AppBar(title: const Text('Пошук фільмів')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Жанр
              TextField(
                controller: _genreController,
                decoration: const InputDecoration(
                  labelText: 'Жанр (наприклад: Action, Comedy)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),

              // Рік
              TextField(
                controller: _yearController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Рік випуску',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),

              // Рейтинг
              Row(
                children: [
                  const Text('Рейтинг:'),
                  Expanded(
                    child: Slider(
                      min: 0,
                      max: 10,
                      divisions: 20,
                      value: _rating,
                      label: _rating.toStringAsFixed(1),
                      onChanged: (val) => setState(() => _rating = val),
                    ),
                  ),
                  Text(_rating.toStringAsFixed(1)),
                ],
              ),

              // Кнопка пошуку
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final genre = _genreController.text.trim();
                    final year = int.tryParse(_yearController.text);
                    _searchBloc.add(SearchByFilters(
                      genre: genre.isEmpty ? null : genre,
                      year: year,
                      rating: _rating,
                    ));
                  },
                  child: const Text('Пошук'),
                ),
              ),
              const SizedBox(height: 16),

              // Результати
              Expanded(
                child: BlocBuilder<SearchBloc, SearchState>(
                  builder: (context, state) {
                    if (state is SearchLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is SearchLoaded) {
                      if (state.movies.isEmpty) {
                        return const Center(child: Text('Нічого не знайдено'));
                      }
                      return ListView.builder(
                        itemCount: state.movies.length,
                        itemBuilder: (context, index) {
                          final movie = state.movies[index];
                          final item = HomeMediaItem.fromMovie(movie);
                          return ListTile(
                            leading: (movie.posterPath?.isNotEmpty ?? false)
                                ? Image.network(
                                    'https://image.tmdb.org/t/p/w200${movie.posterPath}',
                                    width: 50,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        const Icon(Icons.image_not_supported),
                                  )
                                : const Icon(Icons.image_not_supported),
                            title: Text(movie.title),
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
                    } else if (state is SearchError) {
                      return Center(child: Text(state.message));
                    } else {
                      return const Center(
                          child: Text('Введіть фільтр і натисніть пошук'));
                    }
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
