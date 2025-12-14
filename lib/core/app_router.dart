import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
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
import 'page_transitions.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final authRepo = getIt<AuthRepository>();
    final isLoggedIn = authRepo.currentUser != null;

    switch (settings.name) {
      case '/':
      case AppConstants.homeRoute:
        return FadePageRoute(
          child: Builder(
            builder: (context) => MainScaffold(body: const HomePage()),
          ),
        );
      case AppConstants.favoritesRoute:
        return SlidePageRoute(
          beginOffset: const Offset(0.0, 1.0),
          child: Builder(
            builder: (context) => MainScaffold(
              body: const FavoritesPage(),
              title: AppLocalizations.of(context)?.favorites ?? 'Вподобані',
            ),
          ),
        );
      case AppConstants.profileRoute:
        return SlidePageRoute(
          beginOffset: const Offset(0.0, 1.0),
          child: Builder(
            builder: (context) => MainScaffold(
              body: const ProfilePage(),
              title: AppLocalizations.of(context)?.profile ?? 'Профіль',
            ),
          ),
        );
      case AppConstants.editProfileRoute:
        if (!isLoggedIn) {
          return SlidePageRoute(
            beginOffset: const Offset(0.0, 1.0),
            child: const LoginPage(
              redirectRoute: AppConstants.editProfileRoute,
            ),
          );
        }
        return SlidePageRoute(
          beginOffset: const Offset(0.0, 1.0),
          child: const EditProfilePage(),
        );
      case AppConstants.watchlistRoute:
        return SlidePageRoute(
          beginOffset: const Offset(0.0, 1.0),
          child: Builder(
            builder: (context) => MainScaffold(
              body: const WatchlistPage(),
              title: AppLocalizations.of(context)?.watched ?? 'Переглянуті',
            ),
          ),
        );
      case AppConstants.settingsRoute:
        return SlidePageRoute(
          beginOffset: const Offset(1.0, 0.0),
          child: const SettingsPage(),
        );
      case AppConstants.aboutRoute:
        return FadePageRoute(child: const AboutAppPage());
      case AppConstants.searchRoute:
        return SlidePageRoute(
          beginOffset: const Offset(0.0, 1.0),
          child: Builder(
            builder: (context) => MainScaffold(
              body: const SearchPage(),
              title: AppLocalizations.of(context)?.search ?? 'Пошук',
            ),
          ),
        );
      case AppConstants.loginRoute:
        return ScalePageRoute(child: const LoginPage());
      default:
        return FadePageRoute(
          child: const Scaffold(body: Center(child: Text('Route not found'))),
        );
    }
  }
}
