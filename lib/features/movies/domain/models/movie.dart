import 'movie_trailer.dart';

class Movie {
  const Movie({
    required this.id,
    required this.title,
    required this.overview,
    required this.rating,
    required this.genreNames,
    required this.releaseDate,
    this.posterUrl,
    this.backdropUrl,
    this.runtimeMinutes,
    this.trailerCount = 0,
    this.trailers = const [],
  });

  final int id;
  final String title;
  final String overview;
  final double rating;
  final List<String> genreNames;
  final DateTime? releaseDate;
  final String? posterUrl;
  final String? backdropUrl;
  final int? runtimeMinutes;
  final int trailerCount;
  final List<MovieTrailer> trailers;

  int get year => releaseDate?.year ?? 0;

  String get primaryGenre => genreNames.isEmpty ? 'Movie' : genreNames.first;

  String get durationLabel {
    if (runtimeMinutes == null || runtimeMinutes == 0) {
      return 'Runtime TBC';
    }

    final hours = runtimeMinutes! ~/ 60;
    final minutes = runtimeMinutes! % 60;
    return '${hours}h ${minutes.toString().padLeft(2, '0')}m';
  }

  bool get isNewRelease {
    if (releaseDate == null) {
      return false;
    }

    return DateTime.now().difference(releaseDate!).inDays <= 45;
  }

  factory Movie.fromTmdbListJson(
    Map<String, dynamic> json, {
    required Map<int, String> genreNamesById,
    required String imageBaseUrl,
  }) {
    final genreIds = (json['genre_ids'] as List<dynamic>? ?? const [])
        .whereType<int>()
        .toList();

    return Movie(
      id: json['id'] as int,
      title: (json['title'] ?? json['name'] ?? 'Untitled') as String,
      overview: (json['overview'] as String?)?.trim().isNotEmpty == true
          ? json['overview'] as String
          : 'Overview not available yet.',
      rating: (json['vote_average'] as num?)?.toDouble() ?? 0,
      genreNames: genreIds
          .map((id) => genreNamesById[id])
          .whereType<String>()
          .toList(),
      releaseDate: _parseDate(json['release_date'] as String?),
      posterUrl: _imageUrl(json['poster_path'] as String?, imageBaseUrl),
      backdropUrl: _imageUrl(json['backdrop_path'] as String?, imageBaseUrl),
    );
  }

  factory Movie.fromTmdbDetailJson(
    Map<String, dynamic> json, {
    required Map<int, String> genreNamesById,
    required String imageBaseUrl,
  }) {
    final genres = (json['genres'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map((genre) => genre['name'] as String)
        .toList();
    final videos =
        ((json['videos'] as Map<String, dynamic>?)?['results']
                    as List<dynamic>? ??
                const [])
            .whereType<Map<String, dynamic>>()
            .where(
              (video) =>
                  video['site'] == 'YouTube' &&
                  (video['type'] == 'Trailer' || video['type'] == 'Teaser'),
            )
            .toList();

    return Movie(
      id: json['id'] as int,
      title: (json['title'] ?? json['name'] ?? 'Untitled') as String,
      overview: (json['overview'] as String?)?.trim().isNotEmpty == true
          ? json['overview'] as String
          : 'Overview not available yet.',
      rating: (json['vote_average'] as num?)?.toDouble() ?? 0,
      genreNames: genres.isEmpty
          ? genreNamesById.values.take(1).toList()
          : genres,
      releaseDate: _parseDate(json['release_date'] as String?),
      posterUrl: _imageUrl(json['poster_path'] as String?, imageBaseUrl),
      backdropUrl: _imageUrl(json['backdrop_path'] as String?, imageBaseUrl),
      runtimeMinutes: json['runtime'] as int?,
      trailerCount: videos.length,
      trailers: videos
          .where((video) => (video['key'] as String?)?.isNotEmpty == true)
          .map(
            (video) => MovieTrailer(
              name: (video['name'] as String?)?.trim().isNotEmpty == true
                  ? video['name'] as String
                  : 'Trailer',
              youtubeKey: video['key'] as String,
              isOfficial: video['official'] as bool? ?? false,
            ),
          )
          .toList(),
    );
  }

  static DateTime? _parseDate(String? rawDate) {
    if (rawDate == null || rawDate.isEmpty) {
      return null;
    }

    return DateTime.tryParse(rawDate);
  }

  static String? _imageUrl(String? path, String imageBaseUrl) {
    if (path == null || path.isEmpty) {
      return null;
    }

    return '$imageBaseUrl$path';
  }
}
