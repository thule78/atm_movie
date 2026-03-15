import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppEnv {
  const AppEnv({required this.apiKey, required this.apiBaseUrl});

  final String apiKey;
  final String apiBaseUrl;

  factory AppEnv.fromDotEnv(DotEnv env) {
    final apiKey = env.maybeGet('API_KEY');
    final apiBaseUrl = env.maybeGet('API_BASE_URL');

    if (apiKey == null || apiKey.isEmpty) {
      throw StateError('Missing API_KEY in .env');
    }

    if (apiBaseUrl == null || apiBaseUrl.isEmpty) {
      throw StateError('Missing API_BASE_URL in .env');
    }

    return AppEnv(apiKey: apiKey, apiBaseUrl: apiBaseUrl);
  }
}
