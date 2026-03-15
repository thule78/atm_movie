import '../../domain/models/movie.dart';

class HomeMovieFeed {
  const HomeMovieFeed({
    required this.featuredMovie,
    required this.topMovies,
    required this.newReleases,
  });

  final Movie featuredMovie;
  final List<Movie> topMovies;
  final List<Movie> newReleases;
}
