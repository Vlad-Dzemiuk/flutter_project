import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'auth_bloc.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import '../../core/constants.dart';
import '../../core/di.dart';
import '../../core/responsive.dart';
import '../../core/theme.dart';
import '../../shared/widgets/loading_wrapper.dart';
import '../../shared/widgets/app_notification.dart';

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
    return LoadingWrapper(
      child: BlocProvider<AuthBloc>.value(
        value: getIt<AuthBloc>(),
        child: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          final theme = Theme.of(context);
          final colors = theme.colorScheme;
          final isDark = theme.brightness == Brightness.dark;
          
          if (state is AuthAuthenticated) {
            // Показуємо нотифікацію про успішну авторизацію
            AppNotification.showSuccess(
              context,
              _isLogin ? 'Успішний вхід!' : 'Реєстрація успішна!',
            );
            _onSuccess(context, state);
          } else if (state is AuthError) {
            // Показуємо помилку
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
                                      Icons.movie,
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
                                          AppConstants.appName,
                                          style: TextStyle(
                                            color: colors.onSurface,
                                            fontSize: isDesktop ? 24 : 20,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          _isLogin
                                              ? 'Повернись до своїх історій'
                                              : 'Створи акаунт та відкривай нове',
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
                                        theme.brightness == Brightness.light ? 0.08 : 0.25,
                                      ),
                                      blurRadius: isDesktop ? 20 : 16,
                                      offset: Offset(0, isDesktop ? 12 : 10),
                                    ),
                                  ],
                                ),
                                child: Form(
                                  key: _formKey,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      SizedBox(height: isDesktop ? 16 : 12),
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
                                      SizedBox(height: spacing),
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
                                                  if (!_formKey.currentState!.validate()) {
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
                                                  } else {
                                                    debugPrint('⚠️ [AUTH] BLoC закритий, не можу додати подію');
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
                                              ? 'Немає акаунта? Зареєструватись'
                                              : 'Вже є акаунт? Увійти',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: spacing),
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
                                  foregroundColor: colors.onSurface.withValues(alpha: 0.6),
                                ),
                                child: const Text('Пропустити'),
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
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
          prefixIcon: Icon(icon, color: colors.onSurfaceVariant),
          labelText: label,
          labelStyle: TextStyle(color: colors.onSurfaceVariant),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
