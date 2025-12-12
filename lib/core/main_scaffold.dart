import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import 'package:project/core/constants.dart';
import 'package:project/core/responsive.dart';

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
    final l10n = AppLocalizations.of(context);
    if (l10n == null) {
      // Fallback для випадку, коли локалізація недоступна
      switch (widget.title) {
        case 'Пошук':
        case 'Search':
          return 1;
        case 'Переглянуті':
        case 'Watched':
          return 2;
        case 'Вподобані':
        case 'Favorites':
          return 3;
        case 'Профіль':
        case 'Profile':
          return 4;
        default:
          return 0;
      }
    }
    // Порівнюємо з локалізованими значеннями
    if (widget.title == l10n.search) return 1;
    if (widget.title == l10n.watched) return 2;
    if (widget.title == l10n.favorites) return 3;
    if (widget.title == l10n.profile) return 4;
    return 0;
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
      onPopInvokedWithResult: (didPop, result) {
        if (isHome && !didPop) {
          // Якщо на головній сторінці, не дозволяємо вихід
          // Або можна використати для виходу з додатку
        }
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = Responsive.isDesktop(context);
          final isTablet = Responsive.isTablet(context);
          final horizontalPadding = Responsive.getHorizontalPadding(context);

          // На десктопі та планшетах використовуємо NavigationRail
          if (isDesktop || isTablet) {
            final isLandscape = Responsive.isLandscape(context);
            return Scaffold(
              appBar: AppBar(
                toolbarHeight: 0,
                backgroundColor: Colors.transparent,
                elevation: 0,
                scrolledUnderElevation: 0,
                automaticallyImplyLeading: false,
              ),
              body: Row(
                children: [
                  NavigationRail(
                    extended: isDesktop && isLandscape,
                    minWidth: isDesktop ? (isLandscape ? 100 : 80) : (isLandscape ? 80 : 72),
                    backgroundColor: isDark
                        ? Colors.white.withValues(alpha: 0.03)
                        : colors.surfaceContainerHighest.withValues(alpha: 0.5),
                    selectedIndex: _getCurrentIndex(),
                    onDestinationSelected: _onTabTapped,
                    elevation: 2,
                    selectedIconTheme: IconThemeData(
                      color: colors.primary,
                      size: isDesktop ? 28 : 24,
                    ),
                    unselectedIconTheme: IconThemeData(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.55)
                          : colors.onSurface.withValues(alpha: 0.6),
                      size: isDesktop ? 26 : 22,
                    ),
                    selectedLabelTextStyle: TextStyle(
                      color: colors.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: isDesktop ? 15 : 14,
                    ),
                    unselectedLabelTextStyle: TextStyle(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.55)
                          : colors.onSurface.withValues(alpha: 0.6),
                      fontWeight: FontWeight.w600,
                      fontSize: isDesktop ? 14 : 13,
                    ),
                    // Коли extended: true, labelType повинен бути none або null
                    labelType: (isDesktop && isLandscape)
                        ? NavigationRailLabelType.none
                        : NavigationRailLabelType.all,
                    destinations: [
                      NavigationRailDestination(
                        icon: _NavIcon(
                          icon: Icons.home_outlined,
                          isActive: _getCurrentIndex() == 0,
                          size: isDesktop ? 28 : 24,
                        ),
                        selectedIcon: _NavIcon(
                          icon: Icons.home,
                          isActive: true,
                          size: isDesktop ? 28 : 24,
                        ),
                        label: Text(AppLocalizations.of(context)!.home),
                      ),
                      NavigationRailDestination(
                        icon: _NavIcon(
                          icon: Icons.search_outlined,
                          isActive: _getCurrentIndex() == 1,
                          size: isDesktop ? 28 : 24,
                        ),
                        selectedIcon: _NavIcon(
                          icon: Icons.search,
                          isActive: true,
                          size: isDesktop ? 28 : 24,
                        ),
                        label: Text(AppLocalizations.of(context)!.search),
                      ),
                      NavigationRailDestination(
                        icon: _NavIcon(
                          icon: Icons.visibility_outlined,
                          isActive: _getCurrentIndex() == 2,
                          size: isDesktop ? 28 : 24,
                        ),
                        selectedIcon: _NavIcon(
                          icon: Icons.visibility,
                          isActive: true,
                          size: isDesktop ? 28 : 24,
                        ),
                        label: Text(AppLocalizations.of(context)!.watched),
                      ),
                      NavigationRailDestination(
                        icon: _NavIcon(
                          icon: Icons.favorite_border,
                          isActive: _getCurrentIndex() == 3,
                          size: isDesktop ? 28 : 24,
                        ),
                        selectedIcon: _NavIcon(
                          icon: Icons.favorite,
                          isActive: true,
                          size: isDesktop ? 28 : 24,
                        ),
                        label: Text(AppLocalizations.of(context)!.favorites),
                      ),
                      NavigationRailDestination(
                        icon: _NavIcon(
                          icon: Icons.person_outline,
                          isActive: _getCurrentIndex() == 4,
                          size: isDesktop ? 28 : 24,
                        ),
                        selectedIcon: _NavIcon(
                          icon: Icons.person,
                          isActive: true,
                          size: isDesktop ? 28 : 24,
                        ),
                        label: Text(AppLocalizations.of(context)!.profile),
                      ),
                    ],
                  ),
                  const VerticalDivider(thickness: 1, width: 1),
                  Expanded(
                    child: widget.body,
                  ),
                ],
              ),
            );
          }

          // На мобільних пристроях використовуємо bottom navigation
          // Робимо рівні верхній і нижній padding всередині BottomNavigationBar
          // і зменшуємо верхній padding Container, щоб іконки були нижче
          final bottomNavPaddingTop = 4.0; // Верхній padding всередині BottomNavigationBar
          final bottomNavPaddingBottom = 4.0; // Мінімальний нижній padding під іконками
          final containerTopPadding = 2.0; // Мінімальний верхній padding Container для опускання іконок
          
          return Scaffold(
            appBar: AppBar(
              toolbarHeight: 0,
              backgroundColor: Colors.transparent,
              elevation: 0,
              scrolledUnderElevation: 0,
              automaticallyImplyLeading: false,
            ),
            body: widget.body,
            bottomNavigationBar: Container(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding.left * 0.5,
                containerTopPadding,
                horizontalPadding.right * 0.5,
                bottomNavPaddingBottom,
              ),
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
                          colors.surfaceContainerHighest,
                          colors.surface,
                        ],
                      ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Padding(
                  padding: EdgeInsets.only(
                    top: bottomNavPaddingTop,
                    bottom: bottomNavPaddingBottom,
                  ),
                  child: BottomNavigationBar(
                      backgroundColor: isDark
                          ? Colors.white.withValues(alpha: 0.06)
                          : colors.surface.withValues(alpha: 0.9),
                      elevation: 0,
                      currentIndex: _getCurrentIndex(),
                      onTap: _onTabTapped,
                      type: BottomNavigationBarType.fixed,
                    selectedItemColor: colors.primary,
                    unselectedItemColor: isDark
                        ? Colors.white.withValues(alpha: 0.55)
                        : colors.onSurface.withValues(alpha: 0.6),
                    selectedLabelStyle: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                    selectedFontSize: 14,
                    unselectedFontSize: 13,
                    items: [
                    BottomNavigationBarItem(
                      icon: _NavIcon(icon: Icons.home_outlined, isActive: false, size: 24),
                      activeIcon: const _NavIcon(
                        icon: Icons.home,
                        isActive: true,
                        size: 24,
                      ),
                      label: AppLocalizations.of(context)!.home,
                    ),
                    BottomNavigationBarItem(
                      icon: _NavIcon(icon: Icons.search_outlined, isActive: false, size: 24),
                      activeIcon: const _NavIcon(
                        icon: Icons.search,
                        isActive: true,
                        size: 24,
                      ),
                      label: AppLocalizations.of(context)!.search,
                    ),
                    BottomNavigationBarItem(
                      icon: _NavIcon(icon: Icons.visibility_outlined, isActive: false, size: 24),
                      activeIcon: const _NavIcon(
                        icon: Icons.visibility,
                        isActive: true,
                        size: 24,
                      ),
                      label: AppLocalizations.of(context)!.watched,
                    ),
                    BottomNavigationBarItem(
                      icon: _NavIcon(icon: Icons.favorite_border, isActive: false, size: 24),
                      activeIcon: const _NavIcon(
                        icon: Icons.favorite,
                        isActive: true,
                        size: 24,
                      ),
                      label: AppLocalizations.of(context)!.favorites,
                    ),
                    BottomNavigationBarItem(
                      icon: _NavIcon(icon: Icons.person_outline, isActive: false, size: 24),
                      activeIcon: const _NavIcon(
                        icon: Icons.person,
                        isActive: true,
                        size: 24,
                      ),
                      label: AppLocalizations.of(context)!.profile,
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

class _NavIcon extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final double? size;

  const _NavIcon({
    required this.icon,
    this.isActive = false,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final iconSize = size ?? 22;

    return Container(
      padding: EdgeInsets.all(size != null ? (size! * 0.4) : 9),
      decoration: BoxDecoration(
        color: isActive
            ? colors.primary.withValues(
                alpha: theme.brightness == Brightness.light ? 0.16 : 0.2,
              )
            : null,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(
        icon,
        size: iconSize,
      ),
    );
  }
}
