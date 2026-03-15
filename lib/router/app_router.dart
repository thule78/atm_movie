import 'package:flutter/material.dart';

import '../features/auth/presentation/screens/auth_screen.dart';
import '../features/movies/domain/models/movie.dart';
import '../features/movies/presentation/screens/movie_detail_screen.dart';
import '../features/root/presentation/screens/root_screen.dart';
import '../features/splash/presentation/screens/splash_screen.dart';
import '../features/welcome/presentation/screens/welcome_screen.dart';
import 'route_names.dart';

class AppRouter {
  const AppRouter._();

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteNames.splash:
        return MaterialPageRoute<void>(
          builder: (_) => const SplashScreen(),
          settings: settings,
        );
      case RouteNames.welcome:
        return MaterialPageRoute<void>(
          builder: (_) => const WelcomeScreen(),
          settings: settings,
        );
      case RouteNames.auth:
        return MaterialPageRoute<void>(
          builder: (_) => const AuthScreen(),
          settings: settings,
        );
      case RouteNames.root:
        final initialIndex = (settings.arguments as int?) ?? 0;
        return MaterialPageRoute<void>(
          builder: (_) => RootScreen(initialIndex: initialIndex),
          settings: settings,
        );
      case RouteNames.movieDetail:
        final movie = settings.arguments as Movie;
        return MaterialPageRoute<void>(
          builder: (_) => MovieDetailScreen(movie: movie),
          settings: settings,
        );
      default:
        return MaterialPageRoute<void>(
          builder: (_) =>
              const Scaffold(body: Center(child: Text('Route not found'))),
          settings: settings,
        );
    }
  }
}
