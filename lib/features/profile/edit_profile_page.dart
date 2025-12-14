import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../l10n/app_localizations.dart';

import '../../core/constants.dart';
import '../../core/di.dart';
import '../../core/responsive.dart';
import '../../core/theme.dart';
import '../auth/auth_repository.dart';
import '../auth/data/models/local_user.dart';
import '../auth/domain/entities/user.dart';
import '../auth/data/mappers/user_mapper.dart';
import '../profile/domain/usecases/update_profile_usecase.dart';
import '../../shared/widgets/loading_wrapper.dart';
import '../../shared/widgets/app_notification.dart';
import '../../core/network/retry_helper.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _nameController = TextEditingController();
  final _picker = ImagePicker();

  late final AuthRepository _authRepository;
  late final UpdateProfileUseCase _updateProfileUseCase;
  StreamSubscription<LocalUser?>? _subscription;
  User? _user;
  String? _avatarPath;
  String? _originalAvatarPath; // Зберігаємо оригінальний шлях для порівняння

  @override
  void initState() {
    super.initState();
    _authRepository = getIt<AuthRepository>();
    _updateProfileUseCase = getIt<UpdateProfileUseCase>();
    final localUser = _authRepository.currentUser;
    _hydrateUser(localUser != null ? UserMapper.toEntity(localUser) : null);
    _subscription = _authRepository.authStateChanges().listen((localUser) {
      _hydrateUser(localUser != null ? UserMapper.toEntity(localUser) : null);
    });
  }

  void _hydrateUser(User? user) {
    _user = user;
    _nameController.text = user?.displayName ?? '';
    _avatarPath = user?.avatarUrl;
    _originalAvatarPath = user?.avatarUrl; // Зберігаємо оригінальний шлях
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _nameController.dispose();
    super.dispose();
  }

  ImageProvider? _avatarImageProvider() {
    if (_avatarPath == null || _avatarPath!.isEmpty) return null;
    if (_avatarPath!.startsWith('http')) {
      return NetworkImage(_avatarPath!);
    }
    return FileImage(File(_avatarPath!));
  }

  Future<void> _pickAvatar(ImageSource source) async {
    final picked = await _picker.pickImage(
      source: source,
      maxHeight: 512,
      maxWidth: 512,
      imageQuality: 85,
    );
    if (picked == null) return;
    setState(() {
      _avatarPath = picked.path;
    });
  }

  Future<void> _showAvatarSheet() async {
    await showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text(AppLocalizations.of(context)!.selectFromGallery),
              onTap: () async {
                Navigator.of(ctx).pop();
                await _pickAvatar(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: Text(AppLocalizations.of(context)!.takePhoto),
              onTap: () async {
                Navigator.of(ctx).pop();
                await _pickAvatar(ImageSource.camera);
              },
            ),
            if (_avatarPath != null && _avatarPath!.isNotEmpty)
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: Text(AppLocalizations.of(context)!.deleteAvatar),
                onTap: () {
                  Navigator.of(ctx).pop();
                  setState(() {
                    _avatarPath = null;
                  });
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveProfile() async {
    try {
      final trimmedName = _nameController.text.trim();

      // Визначаємо, чи змінився аватар
      final avatarChanged = _avatarPath != _originalAvatarPath;

      // Використання use case з retry механізмом для мережевих помилок
      final updated = await RetryHelper.retry(
        operation: () => _updateProfileUseCase(
          UpdateProfileParams(
            displayName: trimmedName.isEmpty ? null : trimmedName,
            clearDisplayName: trimmedName.isEmpty,
            // Передаємо avatarUrl тільки якщо він змінився
            avatarUrl: avatarChanged ? _avatarPath : null,
            clearAvatar: _avatarPath == null || _avatarPath!.isEmpty,
          ),
        ),
      );
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      AppNotification.showSuccess(context, l10n.profileUpdated(updated.email));
      Navigator.of(context).maybePop();
    } catch (error) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      AppNotification.showError(context, l10n.error(error.toString()));
    }
  }

  Future<void> _openPasswordSheet() async {
    final currentController = TextEditingController();
    final newController = TextEditingController();
    final confirmController = TextEditingController();
    final changed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        final colors = theme.colorScheme;
        final isDesktop = Responsive.isDesktop(ctx);
        final isTablet = Responsive.isTablet(ctx);
        final horizontalPadding = Responsive.getHorizontalPadding(ctx);
        final spacing = Responsive.getSpacing(ctx);
        final isDark = theme.brightness == Brightness.dark;

        bool isLoading = false;
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            Future<void> submit() async {
              final l10n = AppLocalizations.of(context)!;
              if (newController.text.trim().isEmpty ||
                  currentController.text.trim().isEmpty) {
                AppNotification.showWarning(context, l10n.fillAllFields);
                return;
              }
              if (newController.text != confirmController.text) {
                AppNotification.showWarning(context, l10n.passwordsDoNotMatch);
                return;
              }
              setModalState(() => isLoading = true);
              try {
                await _authRepository.changePassword(
                  currentPassword: currentController.text,
                  newPassword: newController.text,
                );
                if (context.mounted) {
                  Navigator.of(ctx).pop(true);
                }
              } catch (error) {
                setModalState(() => isLoading = false);
                if (context.mounted) {
                  final l10n = AppLocalizations.of(context)!;
                  AppNotification.showError(
                    context,
                    l10n.error(error.toString()),
                  );
                }
              }
            }

            return Container(
              decoration: BoxDecoration(
                gradient: isDark
                    ? const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF0F172A), Color(0xFF0B1020)],
                      )
                    : LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          colors.surfaceContainerHighest,
                          colors.surface,
                        ],
                      ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: horizontalPadding.left,
                    right: horizontalPadding.right,
                    top: spacing * 1.5,
                    bottom:
                        spacing * 1.5 + MediaQuery.of(ctx).viewInsets.bottom,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Handle bar
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          margin: EdgeInsets.only(bottom: spacing),
                          decoration: BoxDecoration(
                            color: colors.onSurfaceVariant.withValues(
                              alpha: 0.4,
                            ),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      // Header
                      Row(
                        children: [
                          Icon(
                            Icons.lock_outline,
                            color: colors.primary,
                            size: isDesktop
                                ? 28
                                : isTablet
                                    ? 26
                                    : 24,
                          ),
                          SizedBox(width: spacing * 0.6),
                          Text(
                            AppLocalizations.of(context)!.changePassword,
                            style: TextStyle(
                              color: colors.onSurface,
                              fontSize: isDesktop
                                  ? 24
                                  : isTablet
                                      ? 22
                                      : 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: spacing * 1.5),
                      // Form fields
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isDesktop
                              ? 18
                              : isTablet
                                  ? 16
                                  : 14,
                          vertical: isDesktop ? 8 : 4,
                        ),
                        decoration: BoxDecoration(
                          color: colors.surfaceContainerHighest.withValues(
                            alpha: isDark ? 0.2 : 0.5,
                          ),
                          borderRadius: BorderRadius.circular(
                            isDesktop ? 16 : 14,
                          ),
                          border: Border.all(
                            color: colors.outlineVariant.withValues(alpha: 0.5),
                          ),
                        ),
                        child: TextField(
                          controller: currentController,
                          obscureText: true,
                          style: TextStyle(
                            color: colors.onSurface,
                            fontSize: isDesktop ? 16 : 14,
                          ),
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(
                              context,
                            )!
                                .currentPassword,
                            labelStyle: TextStyle(
                              color: colors.onSurfaceVariant,
                              fontSize: isDesktop ? 16 : 14,
                            ),
                            prefixIcon: Icon(
                              Icons.lock_outline,
                              color: colors.onSurfaceVariant,
                              size: isDesktop ? 22 : 20,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              vertical: isDesktop ? 16 : 14,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: spacing),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isDesktop
                              ? 18
                              : isTablet
                                  ? 16
                                  : 14,
                          vertical: isDesktop ? 8 : 4,
                        ),
                        decoration: BoxDecoration(
                          color: colors.surfaceContainerHighest.withValues(
                            alpha: isDark ? 0.2 : 0.5,
                          ),
                          borderRadius: BorderRadius.circular(
                            isDesktop ? 16 : 14,
                          ),
                          border: Border.all(
                            color: colors.outlineVariant.withValues(alpha: 0.5),
                          ),
                        ),
                        child: TextField(
                          controller: newController,
                          obscureText: true,
                          style: TextStyle(
                            color: colors.onSurface,
                            fontSize: isDesktop ? 16 : 14,
                          ),
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(
                              context,
                            )!
                                .newPassword,
                            labelStyle: TextStyle(
                              color: colors.onSurfaceVariant,
                              fontSize: isDesktop ? 16 : 14,
                            ),
                            prefixIcon: Icon(
                              Icons.lock_open_outlined,
                              color: colors.onSurfaceVariant,
                              size: isDesktop ? 22 : 20,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              vertical: isDesktop ? 16 : 14,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: spacing),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isDesktop
                              ? 18
                              : isTablet
                                  ? 16
                                  : 14,
                          vertical: isDesktop ? 8 : 4,
                        ),
                        decoration: BoxDecoration(
                          color: colors.surfaceContainerHighest.withValues(
                            alpha: isDark ? 0.2 : 0.5,
                          ),
                          borderRadius: BorderRadius.circular(
                            isDesktop ? 16 : 14,
                          ),
                          border: Border.all(
                            color: colors.outlineVariant.withValues(alpha: 0.5),
                          ),
                        ),
                        child: TextField(
                          controller: confirmController,
                          obscureText: true,
                          style: TextStyle(
                            color: colors.onSurface,
                            fontSize: isDesktop ? 16 : 14,
                          ),
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(
                              context,
                            )!
                                .confirmPassword,
                            labelStyle: TextStyle(
                              color: colors.onSurfaceVariant,
                              fontSize: isDesktop ? 16 : 14,
                            ),
                            prefixIcon: Icon(
                              Icons.verified_outlined,
                              color: colors.onSurfaceVariant,
                              size: isDesktop ? 22 : 20,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              vertical: isDesktop ? 16 : 14,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: spacing * 1.5),
                      // Submit button
                      FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: colors.primary,
                          foregroundColor: colors.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              isDesktop ? 16 : 14,
                            ),
                          ),
                          padding: EdgeInsets.symmetric(
                            vertical: isDesktop ? 18 : 16,
                          ),
                        ),
                        onPressed: isLoading ? null : submit,
                        icon: isLoading
                            ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    colors.onPrimary,
                                  ),
                                ),
                              )
                            : Icon(
                                Icons.save_outlined,
                                size: isDesktop ? 22 : 20,
                              ),
                        label: Text(
                          isLoading
                              ? AppLocalizations.of(context)!.saving
                              : AppLocalizations.of(context)!.save,
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: isDesktop ? 16 : 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
    if (changed == true && mounted) {
      final l10n = AppLocalizations.of(context)!;
      AppNotification.showSuccess(context, l10n.passwordChanged);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _user;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return LoadingWrapper(
      child: Scaffold(
        backgroundColor: colors.surface,
        body: Container(
          decoration: AppGradients.background(context),
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isDesktop = Responsive.isDesktop(context);
                final isTablet = Responsive.isTablet(context);
                final horizontalPadding = Responsive.getHorizontalPadding(
                  context,
                );
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
                            Icons.edit_outlined,
                            color: colors.primary,
                            size: isDesktop ? 28 : 24,
                          ),
                          SizedBox(width: spacing * 0.6),
                          Text(
                            AppLocalizations.of(context)!.editProfile,
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
                              maxWidth: isDesktop || isTablet
                                  ? maxFormWidth
                                  : double.infinity,
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(
                                isDesktop
                                    ? 32
                                    : isTablet
                                        ? 24
                                        : 20,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  user == null
                                      ? Center(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.person_off_outlined,
                                                size: isDesktop
                                                    ? 80
                                                    : isTablet
                                                        ? 72
                                                        : 64,
                                                color: colors.onSurfaceVariant
                                                    .withValues(alpha: 0.75),
                                              ),
                                              SizedBox(height: spacing),
                                              Text(
                                                AppLocalizations.of(
                                                  context,
                                                )!
                                                    .authorizeFirst,
                                                style: TextStyle(
                                                  color: colors.onSurface,
                                                  fontSize: isDesktop ? 22 : 18,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                              SizedBox(height: spacing),
                                              FilledButton(
                                                style: FilledButton.styleFrom(
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal:
                                                        isDesktop ? 32 : 24,
                                                    vertical:
                                                        isDesktop ? 18 : 16,
                                                  ),
                                                ),
                                                onPressed: () {
                                                  Navigator.of(
                                                    context,
                                                  ).pushReplacementNamed(
                                                    AppConstants.loginRoute,
                                                  );
                                                },
                                                child: Text(
                                                  AppLocalizations.of(
                                                    context,
                                                  )!
                                                      .signIn,
                                                  style: TextStyle(
                                                    fontSize:
                                                        isDesktop ? 16 : 14,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      : Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          children: [
                                            Center(
                                              child: Stack(
                                                alignment:
                                                    Alignment.bottomRight,
                                                children: [
                                                  CircleAvatar(
                                                    radius: isDesktop
                                                        ? 80
                                                        : isTablet
                                                            ? 72
                                                            : 64,
                                                    backgroundColor: colors
                                                        .surfaceContainerHighest,
                                                    backgroundImage:
                                                        _avatarImageProvider(),
                                                    child: _avatarPath ==
                                                                null ||
                                                            _avatarPath!.isEmpty
                                                        ? Icon(
                                                            Icons.person,
                                                            size: isDesktop
                                                                ? 60
                                                                : isTablet
                                                                    ? 54
                                                                    : 48,
                                                            color: colors
                                                                .onSurfaceVariant,
                                                          )
                                                        : null,
                                                  ),
                                                  IconButton.filled(
                                                    style: IconButton.styleFrom(
                                                      backgroundColor: colors
                                                          .surfaceContainerHighest
                                                          .withValues(
                                                        alpha:
                                                            theme.brightness ==
                                                                    Brightness
                                                                        .light
                                                                ? 0.8
                                                                : 0.3,
                                                      ),
                                                      padding: EdgeInsets.all(
                                                        isDesktop ? 8 : 6,
                                                      ),
                                                    ),
                                                    onPressed: _showAvatarSheet,
                                                    icon: Icon(
                                                      Icons.edit_outlined,
                                                      color: colors
                                                          .onSurfaceVariant,
                                                      size: isDesktop ? 20 : 18,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(height: spacing * 2),
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: isDesktop ? 18 : 14,
                                                vertical: isDesktop ? 8 : 4,
                                              ),
                                              decoration: BoxDecoration(
                                                color: colors
                                                    .surfaceContainerHighest
                                                    .withValues(
                                                  alpha: theme.brightness ==
                                                          Brightness.light
                                                      ? 0.5
                                                      : 0.2,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(
                                                  isDesktop ? 16 : 14,
                                                ),
                                                border: Border.all(
                                                  color: colors.outlineVariant
                                                      .withValues(alpha: 0.5),
                                                ),
                                              ),
                                              child: TextField(
                                                controller: _nameController,
                                                style: TextStyle(
                                                  color: colors.onSurface,
                                                  fontSize: isDesktop ? 16 : 14,
                                                ),
                                                decoration: InputDecoration(
                                                  labelText:
                                                      AppLocalizations.of(
                                                    context,
                                                  )!
                                                          .username,
                                                  helperText:
                                                      AppLocalizations.of(
                                                    context,
                                                  )!
                                                          .canBeEmpty,
                                                  labelStyle: TextStyle(
                                                    color:
                                                        colors.onSurfaceVariant,
                                                    fontSize:
                                                        isDesktop ? 16 : 14,
                                                  ),
                                                  helperStyle: TextStyle(
                                                    color: colors
                                                        .onSurfaceVariant
                                                        .withValues(alpha: 0.7),
                                                    fontSize:
                                                        isDesktop ? 14 : 12,
                                                  ),
                                                  border: InputBorder.none,
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: spacing * 1.5),
                                            FilledButton.icon(
                                              style: FilledButton.styleFrom(
                                                backgroundColor: colors.primary,
                                                foregroundColor:
                                                    colors.onPrimary,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                    isDesktop ? 16 : 14,
                                                  ),
                                                ),
                                                padding: EdgeInsets.symmetric(
                                                  vertical: isDesktop ? 18 : 14,
                                                ),
                                              ),
                                              onPressed: _saveProfile,
                                              icon: Icon(
                                                Icons.save_outlined,
                                                size: isDesktop ? 22 : 20,
                                              ),
                                              label: Text(
                                                AppLocalizations.of(
                                                  context,
                                                )!
                                                    .saveChanges,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w800,
                                                  fontSize: isDesktop ? 16 : 14,
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: spacing * 1.5),
                                            Divider(
                                              color: colors.outlineVariant
                                                  .withValues(alpha: 0.3),
                                              thickness: 1,
                                            ),
                                            SizedBox(height: spacing),
                                            // Адаптивна сітка для кнопок на десктопі
                                            LayoutBuilder(
                                              builder:
                                                  (context, buttonConstraints) {
                                                if (isDesktop) {
                                                  // На десктопі: 2 колонки
                                                  return GridView.count(
                                                    shrinkWrap: true,
                                                    physics:
                                                        const NeverScrollableScrollPhysics(),
                                                    crossAxisCount: 2,
                                                    crossAxisSpacing: spacing,
                                                    mainAxisSpacing: spacing,
                                                    childAspectRatio: 2.5,
                                                    children: [
                                                      FilledButton.tonalIcon(
                                                        style: FilledButton
                                                            .styleFrom(
                                                          backgroundColor: colors
                                                              .surfaceContainerHighest
                                                              .withValues(
                                                            alpha: theme.brightness ==
                                                                    Brightness
                                                                        .light
                                                                ? 0.5
                                                                : 0.2,
                                                          ),
                                                          foregroundColor: colors
                                                              .onSurfaceVariant,
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                            vertical: isDesktop
                                                                ? 16
                                                                : 14,
                                                          ),
                                                        ),
                                                        onPressed:
                                                            _openPasswordSheet,
                                                        icon: const Icon(
                                                          Icons.lock_outline,
                                                        ),
                                                        label: Text(
                                                          AppLocalizations.of(
                                                            context,
                                                          )!
                                                              .changePassword,
                                                        ),
                                                      ),
                                                      FilledButton.tonal(
                                                        style: FilledButton
                                                            .styleFrom(
                                                          backgroundColor: colors
                                                              .surfaceContainerHighest
                                                              .withValues(
                                                            alpha: theme.brightness ==
                                                                    Brightness
                                                                        .light
                                                                ? 0.5
                                                                : 0.2,
                                                          ),
                                                          foregroundColor: colors
                                                              .onSurfaceVariant,
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                            vertical: isDesktop
                                                                ? 16
                                                                : 14,
                                                          ),
                                                        ),
                                                        onPressed: () async {
                                                          await _authRepository
                                                              .signOut();
                                                          if (context.mounted) {
                                                            Navigator.of(
                                                              context,
                                                            ).pushReplacementNamed(
                                                              AppConstants
                                                                  .loginRoute,
                                                            );
                                                          }
                                                        },
                                                        child: Text(
                                                          AppLocalizations.of(
                                                            context,
                                                          )!
                                                              .signOut,
                                                        ),
                                                      ),
                                                    ],
                                                  );
                                                } else {
                                                  // На мобільних/планшетах: вертикальний список
                                                  return Column(
                                                    children: [
                                                      FilledButton.tonalIcon(
                                                        style: FilledButton
                                                            .styleFrom(
                                                          backgroundColor: colors
                                                              .surfaceContainerHighest
                                                              .withValues(
                                                            alpha: theme.brightness ==
                                                                    Brightness
                                                                        .light
                                                                ? 0.5
                                                                : 0.2,
                                                          ),
                                                          foregroundColor: colors
                                                              .onSurfaceVariant,
                                                        ),
                                                        onPressed:
                                                            _openPasswordSheet,
                                                        icon: const Icon(
                                                          Icons.lock_outline,
                                                        ),
                                                        label: Text(
                                                          AppLocalizations.of(
                                                            context,
                                                          )!
                                                              .changePassword,
                                                        ),
                                                      ),
                                                      SizedBox(height: spacing),
                                                      FilledButton.tonal(
                                                        style: FilledButton
                                                            .styleFrom(
                                                          backgroundColor: colors
                                                              .surfaceContainerHighest
                                                              .withValues(
                                                            alpha: theme.brightness ==
                                                                    Brightness
                                                                        .light
                                                                ? 0.5
                                                                : 0.2,
                                                          ),
                                                          foregroundColor: colors
                                                              .onSurfaceVariant,
                                                        ),
                                                        onPressed: () async {
                                                          await _authRepository
                                                              .signOut();
                                                          if (context.mounted) {
                                                            Navigator.of(
                                                              context,
                                                            ).pushReplacementNamed(
                                                              AppConstants
                                                                  .loginRoute,
                                                            );
                                                          }
                                                        },
                                                        child: Text(
                                                          AppLocalizations.of(
                                                            context,
                                                          )!
                                                              .signOut,
                                                        ),
                                                      ),
                                                    ],
                                                  );
                                                }
                                              },
                                            ),
                                            SizedBox(height: spacing),
                                            TextButton(
                                              style: TextButton.styleFrom(
                                                padding: EdgeInsets.symmetric(
                                                  vertical: isDesktop ? 16 : 12,
                                                ),
                                              ),
                                              onPressed: () async {
                                                await _authRepository
                                                    .deleteAccount();
                                                if (context.mounted) {
                                                  Navigator.of(
                                                    context,
                                                  ).pushReplacementNamed(
                                                    AppConstants.loginRoute,
                                                  );
                                                }
                                              },
                                              child: Text(
                                                AppLocalizations.of(
                                                  context,
                                                )!
                                                    .deleteAccount,
                                                style: TextStyle(
                                                  color: colors.error,
                                                  fontSize: isDesktop ? 16 : 14,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                ],
                              ),
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
      ),
    );
  }
}
