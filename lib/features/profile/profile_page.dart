import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants.dart';
import '../../core/di.dart';
import '../auth/auth_cubit.dart';
import '../auth/auth_repository.dart';
import '../auth/auth_state.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLogin = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authRepo = getIt<AuthRepository>();

    return BlocProvider<AuthCubit>(
      create: (_) => getIt<AuthCubit>(),
      child: StreamBuilder<LocalUser?>(
        stream: authRepo.authStateChanges(),
        builder: (context, snapshot) {
          final user = snapshot.data ?? authRepo.currentUser;

          if (user == null) {
            return _buildUnauthorizedView(context);
          }

          return _buildAuthorizedView(context, user, authRepo);
        },
      ),
    );
  }

  Widget _buildUnauthorizedView(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                Text(
                  _isLogin ? 'Вхід' : 'Реєстрація',
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Введіть email';
                          }
                          if (!value.contains('@')) {
                            return 'Некоректний email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _passwordController,
                        decoration: const InputDecoration(
                          labelText: 'Пароль',
                          border: OutlineInputBorder(),
                        ),
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Введіть пароль';
                          }
                          if (value.length < 6) {
                            return 'Мінімум 6 символів';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: isLoading
                              ? null
                              : () {
                                  if (!_formKey.currentState!.validate())
                                    return;
                                  final email = _emailController.text;
                                  final password = _passwordController.text;
                                  final cubit = context.read<AuthCubit>();
                                  if (_isLogin) {
                                    cubit.signIn(email, password);
                                  } else {
                                    cubit.register(email, password);
                                  }
                                },
                          child: isLoading
                              ? const CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                )
                              : Text(_isLogin ? 'Увійти' : 'Зареєструватись'),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: isLoading
                            ? null
                            : () {
                                setState(() {
                                  _isLogin = !_isLogin;
                                });
                              },
                        child: Text(
                          _isLogin
                              ? 'Немає акаунта? Зареєструватись'
                              : 'Вже є акаунт? Увійти',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                const Divider(),
                const SizedBox(height: 16),
                FilledButton.tonalIcon(
                  onPressed: () {
                    Navigator.of(context).pushNamed(AppConstants.settingsRoute);
                  },
                  icon: const Icon(Icons.settings_outlined),
                  label: const Text('Налаштування'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAuthorizedView(
    BuildContext context,
    LocalUser user,
    AuthRepository authRepo,
  ) {
    final displayName = (user.displayName?.trim().isNotEmpty ?? false)
        ? user.displayName!.trim()
        : user.email;

    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 62,
                            backgroundImage:
                                (user.avatarUrl != null &&
                                    user.avatarUrl!.isNotEmpty)
                                ? (user.avatarUrl!.startsWith('http')
                                      ? NetworkImage(user.avatarUrl!)
                                      : FileImage(File(user.avatarUrl!))
                                            as ImageProvider)
                                : null,
                            child:
                                (user.avatarUrl == null ||
                                    user.avatarUrl!.isEmpty)
                                ? const Icon(Icons.person, size: 56)
                                : null,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            displayName,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            user.email,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: Colors.grey.shade700),
                          ),
                          const SizedBox(height: 32),
                          Row(
                            children: [
                              Expanded(
                                child: FilledButton.tonalIcon(
                                  onPressed: () {
                                    Navigator.of(
                                      context,
                                    ).pushNamed(AppConstants.watchlistRoute);
                                  },
                                  icon: const Icon(Icons.playlist_add_check),
                                  label: const Text('Watchlist'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: FilledButton.tonalIcon(
                                  onPressed: () {
                                    Navigator.of(
                                      context,
                                    ).pushNamed(AppConstants.favoritesRoute);
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
                              ).pushReplacementNamed(AppConstants.loginRoute);
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
  }
}
