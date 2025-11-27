import 'package:flutter/material.dart';
import 'package:project/core/constants.dart';
import 'package:project/core/di.dart';
import 'package:project/features/auth/auth_repository.dart';

class MainScaffold extends StatefulWidget {
  final Widget body;
  final String? title;
  final List<Widget>? actions;

  const MainScaffold({super.key, required this.body, this.title, this.actions});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _getCurrentIndex() {
    // Використовуємо widget.title для визначення поточної сторінки
    if (widget.title == null) {
      return 0; // Головна сторінка
    }
    switch (widget.title) {
      case 'Пошук':
        return 1;
      case 'Переглянуті':
        return 2;
      case 'Вподобані':
        return 3;
      case 'Профіль':
        return 4;
      default:
        return 0;
    }
  }

  void _onTabTapped(int index) {
    switch (index) {
      case 0:
        // Для головної сторінки очищаємо весь стек навігації
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil(AppConstants.homeRoute, (route) => false);
        break;
      case 1:
        Navigator.of(context).pushReplacementNamed(AppConstants.searchRoute);
        break;
      case 2:
        Navigator.of(context).pushReplacementNamed(AppConstants.watchlistRoute);
        break;
      case 3:
        Navigator.of(context).pushReplacementNamed(AppConstants.favoritesRoute);
        break;
      case 4:
        Navigator.of(context).pushReplacementNamed(AppConstants.profileRoute);
        break;
    }
  }

  bool _isHomePage() {
    // Якщо title не передано, це головна сторінка
    return widget.title == null;
  }

  @override
  Widget build(BuildContext context) {
    final isHome = _isHomePage();

    return PopScope(
      canPop: !isHome,
      onPopInvoked: (didPop) {
        if (isHome && !didPop) {
          // Якщо на головній сторінці, не дозволяємо вихід
          // Або можна використати для виходу з додатку
        }
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: !isHome,
          centerTitle: true,
          title: isHome
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.movie, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(
                      AppConstants.appName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                )
              : Text(widget.title ?? ''),
          actions: widget.actions,
        ),
        body: widget.body,
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _getCurrentIndex(),
          onTap: _onTabTapped,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Головна'),
            BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Пошук'),
            BottomNavigationBarItem(
              icon: Icon(Icons.visibility),
              label: 'Переглянуті',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite),
              label: 'Вподобані',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Профіль'),
          ],
        ),
      ),
    );
  }
}
