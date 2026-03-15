import 'dart:convert';
import 'dart:io';

import '../../domain/models/movie.dart';

class MovieApiService {
  MovieApiService({
    required this.apiKey,
    required this.baseUrl,
    HttpClient? httpClient,
  }) : _httpClient = httpClient ?? HttpClient();

  final String apiKey;
  final String baseUrl;
  final HttpClient _httpClient;

  static const String _imageBaseUrl = 'https://image.tmdb.org/t/p/w500';

  Future<Map<int, String>> fetchGenres() async {
    final response = await _getJson('/genre/movie/list');
    final genres = response['genres'] as List<dynamic>? ?? const [];

    return {
      for (final genre in genres.whereType<Map<String, dynamic>>())
        genre['id'] as int: genre['name'] as String,
    };
  }

  Future<List<Movie>> fetchPopularMovies(Map<int, String> genres) async {
    final response = await _getJson('/movie/popular');
    return _mapMovieList(response, genres);
  }

  Future<List<Movie>> fetchTopRatedMovies(Map<int, String> genres) async {
    final response = await _getJson('/movie/top_rated');
    return _mapMovieList(response, genres);
  }

  Future<List<Movie>> fetchNowPlayingMovies(Map<int, String> genres) async {
    final response = await _getJson('/movie/now_playing');
    return _mapMovieList(response, genres);
  }

  Future<List<Movie>> searchMovies(
    String query,
    Map<int, String> genres,
  ) async {
    final response = await _getJson(
      '/search/movie',
      queryParameters: {'query': query},
    );
    return _mapMovieList(response, genres);
  }

  Future<Movie> fetchMovieDetail(int movieId, Map<int, String> genres) async {
    final response = await _getJson(
      '/movie/$movieId',
      queryParameters: {'append_to_response': 'videos'},
    );

    return Movie.fromTmdbDetailJson(
      response,
      genreNamesById: genres,
      imageBaseUrl: _imageBaseUrl,
    );
  }

  Future<List<Movie>> fetchRecommendations(
    int movieId,
    Map<int, String> genres,
  ) async {
    final response = await _getJson('/movie/$movieId/recommendations');
    return _mapMovieList(response, genres);
  }

  List<Movie> _mapMovieList(
    Map<String, dynamic> response,
    Map<int, String> genres,
  ) {
    final results = response['results'] as List<dynamic>? ?? const [];

    return results
        .whereType<Map<String, dynamic>>()
        .map(
          (json) => Movie.fromTmdbListJson(
            json,
            genreNamesById: genres,
            imageBaseUrl: _imageBaseUrl,
          ),
        )
        .toList();
  }

  Future<Map<String, dynamic>> _getJson(
    String path, {
    Map<String, String>? queryParameters,
  }) async {
    final uri = Uri.parse('$baseUrl$path').replace(
      queryParameters: {
        'api_key': apiKey,
        'language': 'en-US',
        ...?queryParameters,
      },
    );

    final request = await _httpClient.getUrl(uri);
    final response = await request.close();
    final body = await response.transform(utf8.decoder).join();

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw HttpException(
        'TMDb request failed (${response.statusCode})',
        uri: uri,
      );
    }

    return jsonDecode(body) as Map<String, dynamic>;
  }
}
