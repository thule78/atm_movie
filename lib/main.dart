import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'app/app.dart';
import 'core/config/app_env.dart';
import 'features/auth/data/repositories/auth_repository.dart';
import 'features/movies/data/repositories/movie_repository.dart';
import 'features/movies/data/services/movie_api_service.dart';
import 'features/user_data/data/repositories/user_data_repository.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final appEnv = AppEnv.fromDotEnv(dotenv);
  final movieRepository = TmdbMovieRepository(
    apiService: MovieApiService(
      apiKey: appEnv.apiKey,
      baseUrl: appEnv.apiBaseUrl,
    ),
  );

  runApp(
    AtmMovieApp(
      movieRepository: movieRepository,
      authRepository: FirebaseAuthRepository(),
      userDataRepository: FirestoreUserDataRepository(),
    ),
  );
}
