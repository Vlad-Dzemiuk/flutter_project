import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../l10n/app_localizations.dart';
import '../../core/constants.dart';
import '../../core/di.dart';
import '../../core/responsive.dart';
import '../../core/theme.dart';
import '../auth/auth_bloc.dart';
import '../auth/auth_event.dart';
import '../auth/auth_repository.dart';
import '../auth/auth_state.dart';
import '../auth/data/models/local_user.dart';
import '../auth/domain/entities/user.dart';
import '../auth/data/mappers/user_mapper.dart';
import '../../shared/widgets/loading_wrapper.dart';
import '../../shared/widgets/app_notification.dart';

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

    return LoadingWrapper(
      child: BlocProvider<AuthBloc>.value(
        value: getIt<AuthBloc>(),
        child: StreamBuilder<LocalUser?>(
          stream: authRepo.authStateChanges(),
          builder: (context, snapshot) {
            final localUser = snapshot.data ?? authRepo.currentUser;
            final user = localUser != null ? UserMapper.toEntity(localUser) : null;

            if (user == null) {
              return _buildUnauthorizedView(context);
            }

            return _buildAuthorizedView(context, user, authRepo);
          },
        ),
      ),
    );
  }

  Widget _buildUnauthorizedView(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
          AppNotification.showError(context, state.message);
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;
        final theme = Theme.of(context);
        final colors = theme.colorScheme;

        return Scaffold(
          backgroundColor: colors.surface,
          body: Container(
            decoration: AppGradients.background(context),
            child: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isDesktop = Responsive.isDesktop(context);
                  final isTablet = Responsive.isTablet(context);
                  final horizontalPadding = Responsive.getHorizontalPadding(context);
                  final verticalPadding = Responsive.getVerticalPadding(context);
                  final spacing = Responsive.getSpacing(context);
                  final maxFormWidth = Responsive.getMaxFormWidth(context);

                  return Center(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding.left,
                        verticalPadding.top,
                        horizontalPadding.right,
                        verticalPadding.bottom * 2,
                      ),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: maxFormWidth,
                          minHeight: constraints.maxHeight - 
                              (verticalPadding.top + verticalPadding.bottom * 2),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                    Row(
                              mainAxisAlignment: isDesktop || isTablet
                                  ? MainAxisAlignment.center
                                  : MainAxisAlignment.start,
                      children: [
                        Container(
                                  padding: EdgeInsets.all(
                                    isDesktop ? 14 : 12,
                                  ),
                          decoration: BoxDecoration(
                            color: colors.primary.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(14),
                          ),
                                  child: Icon(
                                    Icons.person_outline,
                                    color: colors.primary,
                                    size: isDesktop ? 28 : 24,
                                  ),
                                ),
                                SizedBox(width: spacing),
                                Flexible(
                                  child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _isLogin ? AppLocalizations.of(context)!.login : AppLocalizations.of(context)!.signUp,
                              style: TextStyle(
                                color: colors.onSurface,
                                          fontSize: isDesktop ? 26 : 22,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              _isLogin
                                  ? AppLocalizations.of(context)!.returnToViewing
                                  : AppLocalizations.of(context)!.createAccountQuick,
                              style: TextStyle(
                                color: colors.onSurface.withValues(alpha: 0.65),
                                          fontSize: isDesktop ? 16 : 14,
                              ),
                            ),
                          ],
                                  ),
                        ),
                      ],
                    ),
                            SizedBox(height: spacing * 1.5),
                    Container(
                              padding: EdgeInsets.all(
                                isDesktop ? 24 : isTablet ? 20 : 18,
                              ),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                                borderRadius: BorderRadius.circular(
                                  isDesktop ? 20 : 18,
                                ),
                        border: Border.all(
                          color: colors.outlineVariant.withValues(alpha: 0.8),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha:
                              theme.brightness == Brightness.light
                                  ? 0.08
                                  : 0.25,
                            ),
                                    blurRadius: isDesktop ? 20 : 18,
                                    offset: Offset(0, isDesktop ? 12 : 10),
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                                    SizedBox(height: isDesktop ? 16 : 0),
                            _AuthInput(
                              controller: _emailController,
                              label: AppLocalizations.of(context)!.email,
                              icon: Icons.alternate_email,
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                final l10n = AppLocalizations.of(context)!;
                                if (value == null || value.isEmpty) {
                                  return l10n.enterEmail;
                                }
                                if (!value.contains('@')) {
                                  return l10n.invalidEmail;
                                }
                                return null;
                              },
                            ),
                                    SizedBox(height: spacing),
                            _AuthInput(
                              controller: _passwordController,
                              label: AppLocalizations.of(context)!.password,
                              icon: Icons.lock_outline,
                              obscureText: true,
                              validator: (value) {
                                final l10n = AppLocalizations.of(context)!;
                                if (value == null || value.isEmpty) {
                                  return l10n.enterPassword;
                                }
                                if (value.length < 6) {
                                  return l10n.minPasswordLength;
                                }
                                return null;
                              },
                            ),
                                    SizedBox(height: spacing * 1.5),
                            SizedBox(
                                      height: isDesktop ? 56 : 52,
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
                                  final bloc = context.read<AuthBloc>();
                                  // Перевіряємо, чи BLoC не закритий перед додаванням події
                                  if (!bloc.isClosed) {
                                    if (_isLogin) {
                                      bloc.add(SignInEvent(email: email, password: password));
                                    } else {
                                      bloc.add(RegisterEvent(email: email, password: password));
                                    }
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
                                      ? AppLocalizations.of(context)!.signIn
                                      : AppLocalizations.of(context)!.signUp,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),
                                      SizedBox(height: spacing),
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
                                    ? AppLocalizations.of(context)!.noAccount
                                    : AppLocalizations.of(context)!.hasAccount,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                              SizedBox(height: spacing),
                    FilledButton.tonalIcon(
                      onPressed: () {
                        Navigator.of(context)
                            .pushNamed(AppConstants.settingsRoute);
                      },
                      icon: const Icon(Icons.settings_outlined),
                      label: Text(AppLocalizations.of(context)!.settings),
                    ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAuthorizedView(
      BuildContext context,
      User user,
      AuthRepository authRepo,
      ) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final displayName =
    (user.displayName?.trim().isNotEmpty ?? false)
        ? user.displayName!.trim()
        : user.email;

    return Scaffold(
      backgroundColor: colors.surface,
      body: Container(
        decoration: AppGradients.background(context),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = Responsive.isDesktop(context);
              final isTablet = Responsive.isTablet(context);
              final horizontalPadding = Responsive.getHorizontalPadding(context);
              final verticalPadding = Responsive.getVerticalPadding(context);
              final spacing = Responsive.getSpacing(context);
              final maxFormWidth = Responsive.getMaxFormWidth(context);

              return Column(
                children: [
              Padding(
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding.left,
                      verticalPadding.top,
                      horizontalPadding.right,
                      verticalPadding.bottom,
                    ),
                child: Row(
                      mainAxisAlignment: isDesktop || isTablet
                          ? MainAxisAlignment.center
                          : MainAxisAlignment.start,
                  children: [
                        Icon(
                          Icons.person,
                          color: colors.primary,
                          size: isDesktop ? 28 : 24,
                        ),
                        SizedBox(width: spacing * 0.6),
                    Text(
                      AppLocalizations.of(context)!.profile,
                      style: TextStyle(
                                        color: colors.onSurface,
                            fontSize: isDesktop ? 24 : 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding.left,
                      0,
                      horizontalPadding.right,
                      verticalPadding.bottom * 2,
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: isDesktop || isTablet ? maxFormWidth : double.infinity,
                        minHeight: constraints.maxHeight - 
                            (verticalPadding.top + verticalPadding.bottom * 3),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(
                                  isDesktop ? 32 : isTablet ? 28 : 24,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.cardColor,
                                  borderRadius: BorderRadius.circular(
                                    isDesktop ? 32 : isTablet ? 30 : 28,
                                  ),
                                  border: Border.all(
                                    color: colors.outlineVariant
                                        .withValues(alpha: 0.8),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                      Colors.black.withValues(alpha:
                                        theme.brightness ==
                                            Brightness.light
                                            ? 0.08
                                            : 0.25,
                                      ),
                                      blurRadius: isDesktop ? 22 : 18,
                                      offset: Offset(0, isDesktop ? 14 : 12),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    CircleAvatar(
                                      radius: isDesktop ? 72 : isTablet ? 68 : 62,
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
                                          .withValues(alpha: 0.08),
                                      child: (user.avatarUrl ==
                                          null ||
                                          user.avatarUrl!.isEmpty)
                                          ? Icon(
                                          Icons.person,
                                          size: isDesktop ? 64 : isTablet ? 60 : 56,
                                          color: colors.primary,
                                        )
                                          : null,
                                    ),
                                    SizedBox(height: spacing * 1.5),
                                    Text(
                                      displayName,
                                      textAlign: TextAlign.center,
                                      style: theme.textTheme
                                          .headlineSmall
                                          ?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: colors.onSurface,
                                        fontSize: isDesktop ? 26 : 24,
                                      ),
                                    ),
                                    SizedBox(height: 6),
                                    Text(
                                      user.email,
                                      style: theme.textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                        color: colors.onSurfaceVariant,
                                        fontSize: isDesktop ? 16 : 14,
                                      ),
                                    ),
                                    SizedBox(height: spacing * 2),
                                    // Адаптивна сітка для кнопок
                                    LayoutBuilder(
                                      builder: (context, buttonConstraints) {
                                        final buttonSpacing = spacing;
                                        
                                        if (isDesktop) {
                                          // На десктопі: 2 колонки для Watchlist та Favorites
                                          return Column(
                                            children: [
                                    Row(
                                      children: [
                                        Expanded(
                                                    child: FilledButton.tonalIcon(
                                            onPressed: () {
                                                        Navigator.of(context)
                                                            .pushNamed(
                                                          AppConstants.watchlistRoute,
                                              );
                                            },
                                            icon: const Icon(
                                                          Icons.playlist_add_check),
                                                      label: Text(AppLocalizations.of(context)!.watched),
                                                      style: FilledButton.styleFrom(
                                                        padding: EdgeInsets.symmetric(
                                                          vertical: isDesktop ? 16 : 14,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(width: buttonSpacing),
                                        Expanded(
                                                    child: FilledButton.tonalIcon(
                                            onPressed: () {
                                                        Navigator.of(context)
                                                            .pushNamed(
                                                          AppConstants.favoritesRoute,
                                              );
                                            },
                                            icon: const Icon(
                                                          Icons.favorite_border),
                                                      label: Text(AppLocalizations.of(context)!.favorites),
                                                      style: FilledButton.styleFrom(
                                                        padding: EdgeInsets.symmetric(
                                                          vertical: isDesktop ? 16 : 14,
                                                        ),
                                                      ),
                                          ),
                                        ),
                                      ],
                                    ),
                                              SizedBox(height: buttonSpacing),
                                              // Кнопка виходу з акаунта
                                              FilledButton.icon(
                                                style: FilledButton.styleFrom(
                                                  backgroundColor: colors.errorContainer,
                                                  foregroundColor: colors.onErrorContainer,
                                                  padding: EdgeInsets.symmetric(
                                                    vertical: isDesktop ? 16 : 14,
                                                  ),
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
                                                label: Text(AppLocalizations.of(context)!.signOut),
                                              ),
                                              SizedBox(height: buttonSpacing),
                                    FilledButton.icon(
                                                onPressed: () {
                                                  Navigator.of(context).pushNamed(
                                                    AppConstants.editProfileRoute,
                                                  );
                                                },
                                                icon: const Icon(Icons.edit_outlined),
                                                label: Text(AppLocalizations.of(context)!.editProfileButton),
                                                style: FilledButton.styleFrom(
                                                  padding: EdgeInsets.symmetric(
                                                    vertical: isDesktop ? 16 : 14,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(height: buttonSpacing * 0.7),
                                              FilledButton.tonalIcon(
                                                onPressed: () {
                                                  Navigator.of(context).pushNamed(
                                                    AppConstants.settingsRoute,
                                                  );
                                                },
                                                icon: const Icon(Icons.settings_outlined),
                                                label: Text(AppLocalizations.of(context)!.settings),
                                                style: FilledButton.styleFrom(
                                                  padding: EdgeInsets.symmetric(
                                                    vertical: isDesktop ? 16 : 14,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          );
                                        } else {
                                          // На мобільних/планшетах: вертикальний список
                                          return Column(
                                            children: [
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: FilledButton.tonalIcon(
                                      onPressed: () {
                                        Navigator.of(context)
                                            .pushNamed(
                                                          AppConstants.watchlistRoute,
                                        );
                                      },
                                      icon: const Icon(
                                                          Icons.playlist_add_check),
                                                      label: Text(AppLocalizations.of(context)!.watched),
                                                    ),
                                                  ),
                                                  SizedBox(width: buttonSpacing),
                                                  Expanded(
                                                    child: FilledButton.tonalIcon(
                                      onPressed: () {
                                        Navigator.of(context)
                                            .pushNamed(
                                                          AppConstants.favoritesRoute,
                                        );
                                      },
                                      icon: const Icon(
                                                          Icons.favorite_border),
                                                      label: Text(AppLocalizations.of(context)!.favorites),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: buttonSpacing),
                                              // Кнопка виходу з акаунта
                                              FilledButton.icon(
                                                style: FilledButton.styleFrom(
                                                  backgroundColor: colors.errorContainer,
                                                  foregroundColor: colors.onErrorContainer,
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
                                                label: Text(AppLocalizations.of(context)!.signOut),
                                              ),
                                              SizedBox(height: buttonSpacing),
                                              FilledButton.icon(
                                                onPressed: () {
                                                  Navigator.of(context).pushNamed(
                                                    AppConstants.editProfileRoute,
                                                  );
                                                },
                                                icon: const Icon(Icons.edit_outlined),
                                                label: Text(AppLocalizations.of(context)!.editProfileButton),
                                              ),
                                              SizedBox(height: buttonSpacing * 0.7),
                                              FilledButton.tonalIcon(
                                                onPressed: () {
                                                  Navigator.of(context).pushNamed(
                                                    AppConstants.settingsRoute,
                                                  );
                                                },
                                                icon: const Icon(Icons.settings_outlined),
                                                label: Text(AppLocalizations.of(context)!.settings),
                                              ),
                                            ],
                                          );
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
                ],
              );
            },
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
        color: colors.surfaceContainerHighest.withValues(alpha:
          theme.brightness == Brightness.light ? 1 : 0.2,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha:
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
