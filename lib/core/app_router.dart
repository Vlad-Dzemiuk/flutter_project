import 'package:flutter/material.dart';
import 'package:project/features/home/home_page.dart';
import 'package:project/features/favorites/favorites_page.dart';
import 'package:project/features/profile/profile_page.dart';
import 'package:project/features/profile/watchlist_page.dart';
import '../features/search/search_page.dart';
import '../features/auth/login_page.dart';
import '../features/auth/auth_repository.dart';
import '../features/profile/edit_profile_page.dart';
import '../features/profile/settings_page.dart';
import '../features/profile/about_app_page.dart';
import 'constants.dart';
import 'di.dart';
import 'main_scaffold.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final authRepo = getIt<AuthRepository>();
    final isLoggedIn = authRepo.currentUser != null;

    switch (settings.name) {
      case '/':
      case AppConstants.homeRoute:
        return MaterialPageRoute(
          builder: (_) => MainScaffold(body: const HomePage()),
        );
      case AppConstants.favoritesRoute:
        return MaterialPageRoute(
          builder: (_) =>
              MainScaffold(body: const FavoritesPage(), title: 'Вподобані'),
        );
      case AppConstants.profileRoute:
        return MaterialPageRoute(
          builder: (_) =>
              MainScaffold(body: const ProfilePage(), title: 'Профіль'),
        );
      case AppConstants.editProfileRoute:
        if (!isLoggedIn) {
          return MaterialPageRoute(
            builder: (_) =>
                const LoginPage(redirectRoute: AppConstants.editProfileRoute),
          );
        }
        return MaterialPageRoute(builder: (_) => const EditProfilePage());
      case AppConstants.watchlistRoute:
        return MaterialPageRoute(
          builder: (_) =>
              MainScaffold(body: const WatchlistPage(), title: 'Переглянуті'),
        );
      case AppConstants.settingsRoute:
        return MaterialPageRoute(builder: (_) => const SettingsPage());
      case AppConstants.aboutRoute:
        return MaterialPageRoute(builder: (_) => const AboutAppPage());
      case AppConstants.searchRoute:
      case '/search':
        return MaterialPageRoute(
          builder: (_) =>
              MainScaffold(body: const SearchPage(), title: 'Пошук'),
        );
      case AppConstants.loginRoute:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      default:
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text('Route not found'))),
        );
    }
  }
}
