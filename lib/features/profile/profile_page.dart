import 'dart:io';

import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../core/di.dart';
import '../auth/auth_repository.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authRepo = getIt<AuthRepository>();

    return Scaffold(
      appBar: AppBar(title: const Text('Профіль')),
      body: StreamBuilder<LocalUser?>(
        stream: authRepo.authStateChanges(),
        builder: (context, snapshot) {
          final user = snapshot.data ?? authRepo.currentUser;

          if (user == null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Ви не авторизовані'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(
                        context,
                      ).pushReplacementNamed(AppConstants.loginRoute);
                    },
                    child: const Text('Увійти'),
                  ),
                ],
              ),
            );
          }

          final displayName = (user.displayName?.trim().isNotEmpty ?? false)
              ? user.displayName!.trim()
              : user.email;

          return SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color:
                                  Theme.of(context).colorScheme.surfaceVariant,
                              borderRadius: BorderRadius.circular(28),
                            ),
                            child: Column(
                              children: [
                                CircleAvatar(
                                  radius: 62,
                                  backgroundImage: (user.avatarUrl != null &&
                                          user.avatarUrl!.isNotEmpty)
                                      ? (user.avatarUrl!.startsWith('http')
                                          ? NetworkImage(user.avatarUrl!)
                                          : FileImage(File(user.avatarUrl!))
                                              as ImageProvider)
                                      : null,
                                  child: (user.avatarUrl == null ||
                                          user.avatarUrl!.isEmpty)
                                      ? const Icon(Icons.person, size: 56)
                                      : null,
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  displayName,
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  user.email,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: Colors.grey.shade700,
                                      ),
                                ),
                                const SizedBox(height: 32),
                                Row(
                                  children: [
                                    Expanded(
                                      child: FilledButton.tonalIcon(
                                        onPressed: () {
                                          Navigator.of(
                                            context,
                                          ).pushNamed(
                                              AppConstants.watchlistRoute);
                                        },
                                        icon: const Icon(
                                          Icons.playlist_add_check,
                                        ),
                                        label: const Text('Watchlist'),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: FilledButton.tonalIcon(
                                        onPressed: () {
                                          Navigator.of(
                                            context,
                                          ).pushNamed(
                                              AppConstants.favoritesRoute);
                                        },
                                        icon: const Icon(Icons.favorite_border),
                                        label: const Text('Favorites'),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 18),
                                FilledButton.icon(
                                  onPressed: () {
                                    Navigator.of(
                                      context,
                                    ).pushNamed(AppConstants.editProfileRoute);
                                  },
                                  icon: const Icon(Icons.edit_outlined),
                                  label: const Text('Редагувати профіль'),
                                ),
                                const SizedBox(height: 12),
                                FilledButton.tonalIcon(
                                  onPressed: () {
                                    Navigator.of(
                                      context,
                                    ).pushNamed(AppConstants.settingsRoute);
                                  },
                                  icon: const Icon(Icons.settings_outlined),
                                  label: const Text('Налаштування'),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            children: [
                              const SizedBox(height: 24),
                              FilledButton.icon(
                                style: FilledButton.styleFrom(
                                  minimumSize: const Size.fromHeight(56),
                                ),
                                onPressed: () async {
                                  await authRepo.signOut();
                                  if (context.mounted) {
                                    Navigator.of(
                                      context,
                                    ).pushReplacementNamed(
                                        AppConstants.loginRoute);
                                  }
                                },
                                icon: const Icon(Icons.logout),
                                label: const Text('Вийти з акаунта'),
                              ),
                            ],
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
    );
  }
}
