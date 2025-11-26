import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project/features/home/home_page.dart';
import 'package:project/features/favorites/favorites_page.dart';
import 'package:project/features/profile/profile_page.dart';
import '../features/search/search_page.dart';
import '../features/auth/login_page.dart';
import 'constants.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final isLoggedIn = FirebaseAuth.instance.currentUser != null;

    switch (settings.name) {
      case '/':
      case AppConstants.homeRoute:
        return MaterialPageRoute(builder: (_) => const HomePage());
      case AppConstants.favoritesRoute:
        if (!isLoggedIn) {
          return MaterialPageRoute(
            builder: (_) => const LoginPage(
              redirectRoute: AppConstants.favoritesRoute,
            ),
          );
        }
        return MaterialPageRoute(builder: (_) => const FavoritesPage());
      case AppConstants.profileRoute:
        if (!isLoggedIn) {
          return MaterialPageRoute(
            builder: (_) => const LoginPage(
              redirectRoute: AppConstants.profileRoute,
            ),
          );
        }
        return MaterialPageRoute(builder: (_) => const ProfilePage());
      case '/search':
        return MaterialPageRoute(builder: (_) => const SearchPage());
      case AppConstants.loginRoute:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Route not found')),
          ),
        );
    }
  }
}

