import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/constants.dart';
import '../../core/di.dart';
import '../auth/auth_repository.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _nameController = TextEditingController();
  final _picker = ImagePicker();

  late final AuthRepository _authRepository;
  StreamSubscription<LocalUser?>? _subscription;
  LocalUser? _user;
  String? _avatarPath;

  @override
  void initState() {
    super.initState();
    _authRepository = getIt<AuthRepository>();
    _hydrateUser(_authRepository.currentUser);
    _subscription = _authRepository.authStateChanges().listen(_hydrateUser);
  }

  void _hydrateUser(LocalUser? user) {
    _user = user;
    _nameController.text = user?.displayName ?? '';
    _avatarPath = user?.avatarUrl;
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
              title: const Text('Обрати з галереї'),
              onTap: () async {
                Navigator.of(ctx).pop();
                await _pickAvatar(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Зробити фото'),
              onTap: () async {
                Navigator.of(ctx).pop();
                await _pickAvatar(ImageSource.camera);
              },
            ),
            if (_avatarPath != null && _avatarPath!.isNotEmpty)
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: const Text('Видалити аватар'),
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
      final updated = await _authRepository.updateProfile(
        displayName: trimmedName.isEmpty ? null : trimmedName,
        clearDisplayName: trimmedName.isEmpty,
        avatarUrl: _avatarPath,
        clearAvatar: _avatarPath == null || _avatarPath!.isEmpty,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Профіль оновлено (${updated.email})')),
      );
      Navigator.of(context).maybePop();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Помилка: $error')));
    }
  }

  Future<void> _openPasswordSheet() async {
    final currentController = TextEditingController();
    final newController = TextEditingController();
    final confirmController = TextEditingController();
    final changed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        bool isLoading = false;
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            Future<void> submit() async {
              if (newController.text.trim().isEmpty ||
                  currentController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Заповніть всі поля')),
                );
                return;
              }
              if (newController.text != confirmController.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Паролі не співпадають')),
                );
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
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Помилка: $error')),
                );
              }
            }

            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 24,
                bottom: 24 + MediaQuery.of(ctx).viewInsets.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Змінити пароль',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: currentController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Поточний пароль',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: newController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Новий пароль',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: confirmController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Підтвердити пароль',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: isLoading ? null : submit,
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Зберегти'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
    if (changed == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Пароль змінено')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _user;

    return Scaffold(
      appBar: AppBar(title: const Text('Редагування профілю')),
      body: user == null
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Спочатку авторизуйтеся'),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () {
                      Navigator.of(
                        context,
                      ).pushReplacementNamed(AppConstants.loginRoute);
                    },
                    child: const Text('Увійти'),
                  ),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          CircleAvatar(
                            radius: 64,
                            backgroundImage: _avatarImageProvider(),
                            child: _avatarPath == null || _avatarPath!.isEmpty
                                ? const Icon(Icons.person, size: 48)
                                : null,
                          ),
                          IconButton.filledTonal(
                            onPressed: _showAvatarSheet,
                            icon: const Icon(Icons.edit_outlined),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Ім\'я користувача',
                        helperText: 'Можна залишити порожнім',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: _saveProfile,
                      icon: const Icon(Icons.save_outlined),
                      label: const Text('Зберегти зміни'),
                    ),
                    const SizedBox(height: 24),
                    Divider(color: Colors.grey.shade300),
                    const SizedBox(height: 12),
                    FilledButton.tonalIcon(
                      onPressed: _openPasswordSheet,
                      icon: const Icon(Icons.lock_outline),
                      label: const Text('Змінити пароль'),
                    ),
                    const SizedBox(height: 12),
                    FilledButton.tonal(
                      onPressed: () async {
                        await _authRepository.signOut();
                        if (context.mounted) {
                          Navigator.of(context).pushReplacementNamed(
                            AppConstants.loginRoute,
                          );
                        }
                      },
                      child: const Text('Вийти з акаунта'),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () async {
                        await _authRepository.deleteAccount();
                        if (context.mounted) {
                          Navigator.of(context).pushReplacementNamed(
                            AppConstants.loginRoute,
                          );
                        }
                      },
                      child: const Text(
                        'Видалити акаунт',
                        style: TextStyle(color: Colors.redAccent),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
