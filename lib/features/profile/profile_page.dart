import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'profile_bloc.dart';
import '../../shared/widgets/loading_widget.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: BlocProvider(
        create: (_) => ProfileBloc(repository: RepositoryProvider.of(context)),
        child: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            if (state.loading) return const LoadingWidget(message: 'Loading profile...');
            if (state.error.isNotEmpty) return Center(child: Text(state.error));
            final user = state.user!;
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (user.avatarPath.isNotEmpty)
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage('https://image.tmdb.org/t/p/w200${user.avatarPath}'),
                    ),
                  const SizedBox(height: 16),
                  Text(user.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  Text('@${user.username}', style: const TextStyle(fontSize: 16, color: Colors.grey)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
