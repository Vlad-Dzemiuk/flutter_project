import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'auth_cubit.dart';
import 'auth_state.dart';
import '../../core/constants.dart';
import '../../core/di.dart';
import '../../core/theme.dart';

class LoginPage extends StatefulWidget {
  final String? redirectRoute;

  const LoginPage({super.key, this.redirectRoute});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
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

  void _onSuccess(BuildContext context, AuthAuthenticated state) {
    if (!context.mounted) return;
    
    if (widget.redirectRoute != null) {
      Navigator.of(context).pushReplacementNamed(widget.redirectRoute!);
    } else {
      // Якщо немає redirectRoute, переходимо на головну сторінку
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppConstants.homeRoute,
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthCubit>(
      create: (_) => getIt<AuthCubit>(),
      child: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            _onSuccess(context, state);
          } else if (state is AuthError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
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
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
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
                            child: Icon(
                              Icons.movie,
                              color: colors.primary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppConstants.appName,
                                style: TextStyle(
                                  color: colors.onBackground,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _isLogin
                                    ? 'Повернись до своїх історій'
                                    : 'Створи акаунт та відкривай нове',
                                style: TextStyle(
                                  color: colors.onBackground.withOpacity(0.65),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
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
                                theme.brightness == Brightness.light ? 0.08 : 0.25,
                              ),
                              blurRadius: 16,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const SizedBox(height: 12),
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
                                          if (!_formKey.currentState!.validate()) {
                                            return;
                                          }
                                          final email = _emailController.text;
                                          final password =
                                              _passwordController.text;
                                          final cubit = context.read<AuthCubit>();
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
                                    _isLogin ? 'Увійти' : 'Зареєструватись',
                                    style:
                                        const TextStyle(fontWeight: FontWeight.w800),
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
                      const SizedBox(height: 14),
                      TextButton(
                        onPressed: isLoading
                            ? null
                            : () {
                                if (widget.redirectRoute != null) {
                                  Navigator.of(
                                    context,
                                  ).pushReplacementNamed(widget.redirectRoute!);
                                } else {
                                  Navigator.of(
                                    context,
                                  ).pushReplacementNamed(AppConstants.homeRoute);
                                }
                              },
                        style: TextButton.styleFrom(
                          foregroundColor: colors.onBackground.withOpacity(0.6),
                        ),
                        child: const Text('Пропустити'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
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
          prefixIcon: Icon(icon, color: colors.onSurfaceVariant),
          labelText: label,
          labelStyle: TextStyle(color: colors.onSurfaceVariant),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
