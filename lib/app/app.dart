import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../features/auth/data/repositories/auth_repository.dart';
import '../features/auth/presentation/providers/auth_provider.dart';
import '../features/movies/data/repositories/movie_repository.dart';
import '../features/movies/presentation/providers/movie_provider.dart';
import '../features/user_data/data/repositories/user_data_repository.dart';
import '../features/user_data/presentation/providers/user_data_provider.dart';
import '../router/app_router.dart';
import '../router/route_names.dart';
import 'theme/app_theme.dart';

class AtmMovieApp extends StatelessWidget {
  const AtmMovieApp({
    super.key,
    required this.movieRepository,
    required this.authRepository,
    required this.userDataRepository,
  });

  final MovieRepository movieRepository;
  final AuthRepository authRepository;
  final UserDataRepository userDataRepository;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(authRepository),
        ),
        ChangeNotifierProxyProvider<AuthProvider, UserDataProvider>(
          create: (_) => UserDataProvider(userDataRepository),
          update: (_, authProvider, userDataProvider) {
            final provider =
                userDataProvider ?? UserDataProvider(userDataRepository);
            provider.syncAuthUser(authProvider.currentUser);
            return provider;
          },
        ),
        ChangeNotifierProvider<MovieProvider>(
          create: (_) => MovieProvider(movieRepository)..loadHome(),
        ),
      ],
      child: MaterialApp(
        title: 'ATM Movie',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        initialRoute: RouteNames.splash,
        onGenerateRoute: AppRouter.onGenerateRoute,
      ),
    );
  }
}
