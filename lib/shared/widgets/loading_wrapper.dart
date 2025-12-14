import 'package:flutter/material.dart';
import 'package:project/core/loading_state.dart';
import 'package:project/core/di.dart';
import 'package:project/core/constants.dart';
import 'package:project/shared/widgets/animated_loading_widget.dart';

/// Обгортка, яка показує завантаження до завантаження головної сторінки
class LoadingWrapper extends StatefulWidget {
  final Widget child;

  const LoadingWrapper({super.key, required this.child});

  @override
  State<LoadingWrapper> createState() => _LoadingWrapperState();
}

class _LoadingWrapperState extends State<LoadingWrapper> {
  late final LoadingStateService _loadingStateService;

  @override
  void initState() {
    super.initState();
    _loadingStateService = getIt<LoadingStateService>();
    _loadingStateService.addListener(_onLoadingStateChanged);
  }

  @override
  void dispose() {
    _loadingStateService.removeListener(_onLoadingStateChanged);
    super.dispose();
  }

  void _onLoadingStateChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    // Перевіряємо, чи це сторінка входу/реєстрації - для неї не блокуємо UI
    final route = ModalRoute.of(context);
    final routeName = route?.settings.name;
    final isAuthPage = routeName == AppConstants.loginRoute;

    // Якщо це не сторінка авторизації і головна сторінка ще не завантажена, показуємо завантаження
    if (!isAuthPage && !_loadingStateService.isHomePageLoaded) {
      return const AnimatedLoadingWidget(message: 'Завантаження...');
    }

    return widget.child;
  }
}
