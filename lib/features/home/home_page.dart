import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'home_bloc.dart';
import 'package:project/shared/widgets/loading_widget.dart';
import 'package:project/core/di.dart';
import 'home_repository.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Popular Movies')),
      body: BlocProvider(
        create: (_) => HomeBloc(repository: getIt<HomeRepository>()),
        child: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            if (state.loading) return LoadingWidget(message: 'Завантаження...');
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