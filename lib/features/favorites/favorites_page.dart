import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'favorites_bloc.dart';
import '../../shared/widgets/loading_widget.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Favorites')),
      body: BlocProvider(
        create: (_) => FavoritesBloc(repository: RepositoryProvider.of(context)),
        child: BlocBuilder<FavoritesBloc, FavoritesState>(
          builder: (context, state) {
            if (state.loading) return const LoadingWidget(message: 'Loading favorites...');
            if (state.error.isNotEmpty) return Center(child: Text(state.error));
            return ListView.builder(
              itemCount: state.movies.length,
              itemBuilder: (context, index) {
                final movie = state.movies[index];
                return ListTile(
                  leading: Image.network('https://image.tmdb.org/t/p/w200${movie.posterPath}'),
                  title: Text(movie.title),
                  subtitle: Text(movie.overview),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
