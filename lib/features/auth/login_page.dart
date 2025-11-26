import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'auth_cubit.dart';
import 'auth_state.dart';
import '../../core/di.dart';

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
    if (widget.redirectRoute != null) {
      Navigator.of(context)
          .pushReplacementNamed(widget.redirectRoute!);
    } else {
      Navigator.of(context).pop();
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
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return Scaffold(
            appBar: AppBar(
              title: Text(_isLogin ? 'Вхід' : 'Реєстрація'),
            ),
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
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
                                if (!_formKey.currentState!.validate()) return;
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
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
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
                      child: Text(_isLogin
                          ? 'Немає акаунта? Зареєструватись'
                          : 'Вже є акаунт? Увійти'),
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


