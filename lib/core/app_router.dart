import 'package:flutter/material.dart';
import 'package:project/features/home/home_page.dart';
import 'package:project/features/favorites/favorites_page.dart';
import 'package:project/features/profile/profile_page.dart';
import 'constants.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppConstants.homeRoute:
        return MaterialPageRoute(builder: (_) => const HomePage());
      case AppConstants.favoritesRoute:
        return MaterialPageRoute(builder: (_) => const FavoritesPage());
      case AppConstants.profileRoute:
        return MaterialPageRoute(builder: (_) => const ProfilePage());
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Route not found')),
          ),
        );
    }
  }
}

