import '../models/home_movie_feed.dart';
import '../services/movie_api_service.dart';
import '../../domain/models/movie.dart';

abstract class MovieRepository {
  Future<HomeMovieFeed> fetchHomeFeed();
  Future<List<Movie>> searchMovies(String query);
  Future<Movie> fetchMovieDetail(int movieId);
  Future<List<Movie>> fetchRecommendations(int movieId);
}

class TmdbMovieRepository implements MovieRepository {
  TmdbMovieRepository({required MovieApiService apiService})
    : _apiService = apiService;

  final MovieApiService _apiService;
  Map<int, String>? _genres;

  Future<Map<int, String>> _getGenres() async {
    return _genres ??= await _apiService.fetchGenres();
  }

  @override
  Future<HomeMovieFeed> fetchHomeFeed() async {
    final genres = await _getGenres();
    final popular = await _apiService.fetchPopularMovies(genres);
    final topRated = await _apiService.fetchTopRatedMovies(genres);
    final nowPlaying = await _apiService.fetchNowPlayingMovies(genres);

    return HomeMovieFeed(
      featuredMovie: popular.first,
      topMovies: topRated.take(10).toList(),
      newReleases: nowPlaying.take(8).toList(),
    );
  }

  @override
  Future<List<Movie>> searchMovies(String query) async {
    final genres = await _getGenres();
    return _apiService.searchMovies(query, genres);
  }

  @override
  Future<Movie> fetchMovieDetail(int movieId) async {
    final genres = await _getGenres();
    return _apiService.fetchMovieDetail(movieId, genres);
  }

  @override
  Future<List<Movie>> fetchRecommendations(int movieId) async {
    final genres = await _getGenres();
    return _apiService.fetchRecommendations(movieId, genres);
  }
}
