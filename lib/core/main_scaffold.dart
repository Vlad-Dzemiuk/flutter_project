import 'package:flutter/material.dart';
import 'package:project/core/constants.dart';
import 'package:project/core/di.dart';
import 'package:project/features/auth/auth_repository.dart';
import 'package:project/core/theme.dart';

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
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

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
          toolbarHeight: 0,
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          automaticallyImplyLeading: false,
        ),
        body: widget.body,
        bottomNavigationBar: Container(
          padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
          decoration: BoxDecoration(
            gradient: isDark
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF111827),
                      Color(0xFF0B1020),
                    ],
                  )
                : LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colors.surfaceVariant,
                      colors.surface,
                    ],
                  ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BottomNavigationBar(
              backgroundColor: isDark
                  ? Colors.white.withOpacity(0.06)
                  : colors.surface.withOpacity(0.9),
              elevation: 0,
              currentIndex: _getCurrentIndex(),
              onTap: _onTabTapped,
              type: BottomNavigationBarType.fixed,
              selectedItemColor: colors.primary,
              unselectedItemColor: isDark
                  ? Colors.white.withOpacity(0.55)
                  : colors.onSurface.withOpacity(0.6),
              selectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w700,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
              items: [
                BottomNavigationBarItem(
                  icon: _NavIcon(icon: Icons.home_outlined, isActive: false),
                  activeIcon: const _NavIcon(
                    icon: Icons.home,
                    isActive: true,
                  ),
                  label: 'Головна',
                ),
                BottomNavigationBarItem(
                  icon: _NavIcon(icon: Icons.search_outlined, isActive: false),
                  activeIcon: const _NavIcon(
                    icon: Icons.search,
                    isActive: true,
                  ),
                  label: 'Пошук',
                ),
                BottomNavigationBarItem(
                  icon: _NavIcon(icon: Icons.visibility_outlined, isActive: false),
                  activeIcon: const _NavIcon(
                    icon: Icons.visibility,
                    isActive: true,
                  ),
                  label: 'Переглянуті',
                ),
                BottomNavigationBarItem(
                  icon: _NavIcon(icon: Icons.favorite_border, isActive: false),
                  activeIcon: const _NavIcon(
                    icon: Icons.favorite,
                    isActive: true,
                  ),
                  label: 'Вподобані',
                ),
                BottomNavigationBarItem(
                  icon: _NavIcon(icon: Icons.person_outline, isActive: false),
                  activeIcon: const _NavIcon(
                    icon: Icons.person,
                    isActive: true,
                  ),
                  label: 'Профіль',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  final IconData icon;
  final bool isActive;

  const _NavIcon({required this.icon, this.isActive = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: isActive
            ? colors.primary.withOpacity(
                theme.brightness == Brightness.light ? 0.16 : 0.2,
              )
            : null,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(
        icon,
        size: 22,
      ),
    );
  }
}
