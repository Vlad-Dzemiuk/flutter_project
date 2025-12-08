import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants.dart';
import '../../core/di.dart';
import '../../core/theme.dart';
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
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;
        final theme = Theme.of(context);
        final colors = theme.colorScheme;

        return Scaffold(
          backgroundColor: colors.background,
          body: Container(
            decoration: AppGradients.background(context),
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: colors.primary.withOpacity(0.14),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(Icons.person_outline,
                              color: colors.primary),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _isLogin ? 'Вхід' : 'Реєстрація',
                              style: TextStyle(
                                color: colors.onBackground,
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              _isLogin
                                  ? 'Повернись до перегляду'
                                  : 'Створи акаунт за хвилину',
                              style: TextStyle(
                                color: colors.onBackground.withOpacity(0.65),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: colors.outlineVariant.withOpacity(0.8),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(
                              theme.brightness == Brightness.light
                                  ? 0.08
                                  : 0.25,
                            ),
                            blurRadius: 18,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _AuthInput(
                              controller: _emailController,
                              label: 'Email',
                              icon: Icons.alternate_email,
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
                            const SizedBox(height: 14),
                            _AuthInput(
                              controller: _passwordController,
                              label: 'Пароль',
                              icon: Icons.lock_outline,
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
                              height: 52,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: colors.primary,
                                  foregroundColor: colors.onPrimary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                onPressed: isLoading
                                    ? null
                                    : () {
                                  if (!_formKey.currentState!
                                      .validate()) {
                                    return;
                                  }
                                  final email = _emailController.text;
                                  final password =
                                      _passwordController.text;
                                  final cubit =
                                  context.read<AuthCubit>();
                                  if (_isLogin) {
                                    cubit.signIn(email, password);
                                  } else {
                                    cubit.register(email, password);
                                  }
                                },
                                icon: isLoading
                                    ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor:
                                    AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                                    : const Icon(Icons.login),
                                label: Text(
                                  _isLogin
                                      ? 'Увійти'
                                      : 'Зареєструватись',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
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
                              style: TextButton.styleFrom(
                                foregroundColor: colors.primary,
                              ),
                              child: Text(
                                _isLogin
                                    ? 'Немає акаунта? Зареєструватись'
                                    : 'Вже є акаунт? Увійти',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    FilledButton.tonalIcon(
                      onPressed: () {
                        Navigator.of(context)
                            .pushNamed(AppConstants.settingsRoute);
                      },
                      icon: const Icon(Icons.settings_outlined),
                      label: const Text('Налаштування'),
                    ),
                  ],
                ),
              ),
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
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final displayName =
    (user.displayName?.trim().isNotEmpty ?? false)
        ? user.displayName!.trim()
        : user.email;

    return Scaffold(
      backgroundColor: colors.background,
      body: Container(
        decoration: AppGradients.background(context),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding:
                const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  children: [
                    Icon(Icons.person, color: colors.primary),
                    const SizedBox(width: 10),
                    Text(
                      'Профіль',
                      style: TextStyle(
                        color: colors.onBackground,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
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
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: theme.cardColor,
                                  borderRadius:
                                  BorderRadius.circular(28),
                                  border: Border.all(
                                    color: colors.outlineVariant
                                        .withOpacity(0.8),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                      Colors.black.withOpacity(
                                        theme.brightness ==
                                            Brightness.light
                                            ? 0.08
                                            : 0.25,
                                      ),
                                      blurRadius: 18,
                                      offset:
                                      const Offset(0, 12),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    CircleAvatar(
                                      radius: 62,
                                      backgroundImage:
                                      (user.avatarUrl != null &&
                                          user.avatarUrl!
                                              .isNotEmpty)
                                          ? (user.avatarUrl!
                                          .startsWith(
                                          'http')
                                          ? NetworkImage(
                                          user.avatarUrl!)
                                          : FileImage(File(
                                          user.avatarUrl!))
                                      as ImageProvider)
                                          : null,
                                      backgroundColor: colors
                                          .primary
                                          .withOpacity(0.08),
                                      child: (user.avatarUrl ==
                                          null ||
                                          user.avatarUrl!.isEmpty)
                                          ? Icon(Icons.person,
                                          size: 56,
                                          color: colors
                                              .primary)
                                          : null,
                                    ),
                                    const SizedBox(height: 20),
                                    Text(
                                      displayName,
                                      textAlign: TextAlign.center,
                                      style: theme.textTheme
                                          .headlineSmall
                                          ?.copyWith(
                                        fontWeight:
                                        FontWeight.w700,
                                        color: colors
                                            .onBackground,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      user.email,
                                      style: theme.textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                        color: colors
                                            .onSurfaceVariant,
                                      ),
                                    ),
                                    const SizedBox(height: 32),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: FilledButton
                                              .tonalIcon(
                                            onPressed: () {
                                              Navigator.of(
                                                context,
                                              ).pushNamed(
                                                AppConstants
                                                    .watchlistRoute,
                                              );
                                            },
                                            icon: const Icon(
                                                Icons
                                                    .playlist_add_check),
                                            label: const Text(
                                                'Watchlist'),
                                          ),
                                        ),
                                        const SizedBox(
                                            width: 12),
                                        Expanded(
                                          child: FilledButton
                                              .tonalIcon(
                                            onPressed: () {
                                              Navigator.of(
                                                context,
                                              ).pushNamed(
                                                AppConstants
                                                    .favoritesRoute,
                                              );
                                            },
                                            icon: const Icon(
                                                Icons
                                                    .favorite_border),
                                            label: const Text(
                                                'Favorites'),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 18),
                                    FilledButton.icon(
                                      onPressed: () {
                                        Navigator.of(context)
                                            .pushNamed(
                                          AppConstants
                                              .editProfileRoute,
                                        );
                                      },
                                      icon: const Icon(
                                          Icons.edit_outlined),
                                      label: const Text(
                                          'Редагувати профіль'),
                                    ),
                                    const SizedBox(height: 12),
                                    FilledButton.tonalIcon(
                                      onPressed: () {
                                        Navigator.of(context)
                                            .pushNamed(
                                          AppConstants
                                              .settingsRoute,
                                        );
                                      },
                                      icon: const Icon(
                                          Icons.settings_outlined),
                                      label: const Text(
                                          'Налаштування'),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),
                              FilledButton.icon(
                                style:
                                FilledButton.styleFrom(
                                  minimumSize:
                                  const Size.fromHeight(56),
                                ),
                                onPressed: () async {
                                  await authRepo.signOut();
                                  if (context.mounted) {
                                    Navigator.of(context)
                                        .pushReplacementNamed(
                                      AppConstants.loginRoute,
                                    );
                                  }
                                },
                                icon: const Icon(Icons.logout),
                                label: const Text(
                                    'Вийти з акаунта'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
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

class _AuthInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final bool obscureText;

  const _AuthInput({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
    this.validator,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding:
      const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: colors.surfaceVariant.withOpacity(
          theme.brightness == Brightness.light ? 1 : 0.2,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: colors.outlineVariant.withOpacity(
            theme.brightness == Brightness.light ? 1 : 0.4,
          ),
        ),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        obscureText: obscureText,
        style: TextStyle(color: colors.onSurface),
        decoration: InputDecoration(
          prefixIcon:
          Icon(icon, color: colors.onSurfaceVariant),
          labelText: label,
          labelStyle:
          TextStyle(color: colors.onSurfaceVariant),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
