import 'package:flutter/material.dart';

import '../../data/models/home_movie_feed.dart';
import '../../data/repositories/movie_repository.dart';
import '../../domain/models/movie.dart';

class MovieProvider extends ChangeNotifier {
  MovieProvider(this._movieRepository);

  final MovieRepository _movieRepository;
  final Map<int, Movie> _movieCache = {};
  final Map<int, List<Movie>> _recommendationsCache = {};

  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';
  bool _isSearching = false;
  String? _searchError;
  Movie? _featuredMovie;
  List<Movie> _topMovies = const [];
  List<Movie> _newReleases = const [];
  List<Movie> _searchResults = const [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isSearching => _isSearching;
  String? get searchError => _searchError;
  String get searchQuery => _searchQuery;
  Movie? get featuredMovie => _featuredMovie;
  List<Movie> get topMovies => _topMovies;
  List<Movie> get newReleases => _newReleases;
  List<Movie> get searchResults => _searchResults;

  Future<void> loadHome() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final feed = await _movieRepository.fetchHomeFeed();
      _applyHomeFeed(feed);
    } catch (_) {
      _errorMessage =
          'Could not load movies right now. Check the API key and connection.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> searchMovies(String query) async {
    _searchQuery = query.trim();
    _searchError = null;

    if (_searchQuery.isEmpty) {
      _searchResults = const [];
      notifyListeners();
      return;
    }

    _isSearching = true;
    notifyListeners();

    try {
      final movies = await _movieRepository.searchMovies(_searchQuery);
      _registerMovies(movies);
      _searchResults = movies;
    } catch (_) {
      _searchError = 'Search failed. Please try again.';
      _searchResults = const [];
    } finally {
      _isSearching = false;
      notifyListeners();
    }
  }

  Future<Movie> loadMovieDetail(Movie movie) async {
    final cached = _movieCache[movie.id];
    if (cached != null && cached.runtimeMinutes != null) {
      return cached;
    }

    final detailedMovie = await _movieRepository.fetchMovieDetail(movie.id);
    _registerMovie(detailedMovie);
    notifyListeners();
    return detailedMovie;
  }

  Future<List<Movie>> loadRecommendations(int movieId) async {
    if (_recommendationsCache.containsKey(movieId)) {
      return _recommendationsCache[movieId]!;
    }

    final movies = await _movieRepository.fetchRecommendations(movieId);
    _registerMovies(movies);
    _recommendationsCache[movieId] = movies;
    notifyListeners();
    return movies;
  }

  void _applyHomeFeed(HomeMovieFeed feed) {
    _featuredMovie = feed.featuredMovie;
    _topMovies = feed.topMovies;
    _newReleases = feed.newReleases;

    _registerMovie(feed.featuredMovie);
    _registerMovies(feed.topMovies);
    _registerMovies(feed.newReleases);
  }

  void _registerMovies(List<Movie> movies) {
    for (final movie in movies) {
      _registerMovie(movie);
    }
  }

  void _registerMovie(Movie movie) {
    _movieCache[movie.id] = movie;
  }
}
