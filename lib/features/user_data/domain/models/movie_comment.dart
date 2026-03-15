class MovieComment {
  const MovieComment({
    required this.id,
    required this.movieId,
    required this.movieTitle,
    required this.userId,
    required this.authorName,
    required this.text,
    required this.createdAt,
  });

  final String id;
  final int movieId;
  final String movieTitle;
  final String userId;
  final String authorName;
  final String text;
  final DateTime createdAt;
}
