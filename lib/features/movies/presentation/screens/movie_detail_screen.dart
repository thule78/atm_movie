import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../user_data/domain/models/movie_comment.dart';
import '../../../user_data/presentation/providers/user_data_provider.dart';
import '../../domain/models/movie.dart';
import '../../domain/models/movie_trailer.dart';
import '../providers/movie_provider.dart';
import '../widgets/movie_artwork.dart';
import '../widgets/movie_poster_card.dart';
import 'trailer_player_screen.dart';

class MovieDetailScreen extends StatefulWidget {
  const MovieDetailScreen({super.key, required this.movie});

  final Movie movie;

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  late Future<Movie> _movieFuture;
  late Future<List<Movie>> _recommendationsFuture;
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final provider = context.read<MovieProvider>();
    _movieFuture = provider.loadMovieDetail(widget.movie);
    _recommendationsFuture = provider.loadRecommendations(widget.movie.id);
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _openTrailer(Movie movie, MovieTrailer trailer) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => TrailerPlayerScreen(
          trailers: movie.trailers,
          initialTrailer: trailer,
        ),
      ),
    );
  }

  Future<void> _submitComment(Movie movie) async {
    final text = _commentController.text.trim();
    if (text.isEmpty) {
      return;
    }

    final success = await context.read<UserDataProvider>().addComment(
      movie: movie,
      text: text,
    );
    if (!mounted || !success) {
      return;
    }

    _commentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Movie>(
      future: _movieFuture,
      initialData: widget.movie,
      builder: (context, snapshot) {
        final movie = snapshot.data ?? widget.movie;
        final userDataProvider = context.watch<UserDataProvider>();
        final isSaved = context.select<UserDataProvider, bool>(
          (provider) => provider.isInWatchlist(movie.id),
        );
        final isSavingWatchlist = context.select<UserDataProvider, bool>(
          (provider) => provider.isWatchlistActionPending(movie.id),
        );
        final isSubmittingComment = context.select<UserDataProvider, bool>(
          (provider) => provider.isSubmittingComment(movie.id),
        );

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                expandedHeight: 320,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      MovieArtwork(
                        imageUrl: movie.backdropUrl ?? movie.posterUrl,
                        height: 320,
                        width: double.infinity,
                        borderRadius: 0,
                        iconSize: 92,
                      ),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.65),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        movie.title,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          _InfoChip(
                            label: movie.year == 0 ? 'TBA' : '${movie.year}',
                          ),
                          _InfoChip(label: movie.primaryGenre),
                          _InfoChip(label: movie.durationLabel),
                          _InfoChip(
                            label: '⭐ ${movie.rating.toStringAsFixed(1)}',
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        movie.overview,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: AppTheme.primaryRed,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                          ),
                          onPressed: movie.trailers.isEmpty
                              ? null
                              : () => _openTrailer(movie, movie.trailers.first),
                          icon: const Icon(Icons.play_arrow_rounded),
                          label: Text(
                            movie.trailers.isEmpty
                                ? 'Trailer unavailable'
                                : 'Play trailer',
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: isSavingWatchlist
                              ? null
                              : () {
                                  context
                                      .read<UserDataProvider>()
                                      .toggleWatchlist(movie);
                                },
                          icon: Icon(
                            isSaved
                                ? Icons.bookmark_remove_outlined
                                : Icons.bookmark_add_outlined,
                          ),
                          label: Text(
                            isSavingWatchlist
                                ? 'Saving...'
                                : isSaved
                                ? 'Remove from My List'
                                : 'Add to My List',
                          ),
                        ),
                      ),
                      if (userDataProvider.profileError != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          userDataProvider.profileError!,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                      const SizedBox(height: 28),
                      Text(
                        'Trailers',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 12),
                      if (movie.trailers.isEmpty)
                        const Card(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Text(
                              'No YouTube trailers available for this movie.',
                            ),
                          ),
                        )
                      else
                        ...movie.trailers.map(
                          (trailer) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Card(
                              child: ListTile(
                                leading: const Icon(
                                  Icons.play_circle_outline_rounded,
                                ),
                                title: Text(trailer.name),
                                subtitle: Text(
                                  trailer.isOfficial
                                      ? 'Official YouTube trailer'
                                      : 'YouTube trailer',
                                ),
                                trailing: const Icon(
                                  Icons.chevron_right_rounded,
                                ),
                                onTap: () => _openTrailer(movie, trailer),
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 18),
                      Text(
                        'More Like This',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 12),
                      FutureBuilder<List<Movie>>(
                        future: _recommendationsFuture,
                        builder: (context, recommendationsSnapshot) {
                          if (!recommendationsSnapshot.hasData) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(24),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }

                          final movies = recommendationsSnapshot.data!;
                          if (movies.isEmpty) {
                            return const Card(
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: Text(
                                  'No recommendations available yet.',
                                ),
                              ),
                            );
                          }

                          return SizedBox(
                            height: 340,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: movies.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(width: 14),
                              itemBuilder: (context, index) {
                                final recommendation = movies[index];
                                return MoviePosterCard(
                                  movie: recommendation,
                                  onTap: () {
                                    Navigator.of(context).pushReplacement(
                                      MaterialPageRoute<void>(
                                        builder: (_) => MovieDetailScreen(
                                          movie: recommendation,
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'Comments',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _commentController,
                        minLines: 2,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          hintText: 'Write your review or trailer reaction',
                        ),
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: FilledButton(
                          onPressed: isSubmittingComment
                              ? null
                              : () => _submitComment(movie),
                          child: Text(
                            isSubmittingComment ? 'Posting...' : 'Post comment',
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      StreamBuilder<List<MovieComment>>(
                        stream: context.read<UserDataProvider>().commentsStream(
                          movie.id,
                        ),
                        builder: (context, commentsSnapshot) {
                          final comments = commentsSnapshot.data ?? const [];
                          if (commentsSnapshot.connectionState ==
                                  ConnectionState.waiting &&
                              comments.isEmpty) {
                            return const Padding(
                              padding: EdgeInsets.all(24),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }

                          if (comments.isEmpty) {
                            return const Card(
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: Text(
                                  'No comments yet. Be the first to post one.',
                                ),
                              ),
                            );
                          }

                          return Column(
                            children: comments
                                .map(
                                  (comment) => Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: Card(
                                      child: ListTile(
                                        title: Text(comment.authorName),
                                        subtitle: Padding(
                                          padding: const EdgeInsets.only(
                                            top: 6,
                                          ),
                                          child: Text(comment.text),
                                        ),
                                        trailing:
                                            comment.userId ==
                                                userDataProvider.currentUserId
                                            ? IconButton(
                                                tooltip: 'Delete comment',
                                                onPressed: () async {
                                                  await context
                                                      .read<
                                                        UserDataProvider
                                                      >()
                                                      .deleteComment(comment);
                                                },
                                                icon: const Icon(
                                                  Icons.delete_outline_rounded,
                                                  color: AppTheme.primaryRed,
                                                ),
                                              )
                                            : Text(
                                                _formatCommentTime(
                                                  comment.createdAt,
                                                ),
                                                style: Theme.of(
                                                  context,
                                                ).textTheme.bodySmall,
                                              ),
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatCommentTime(DateTime createdAt) {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    if (difference.inMinutes < 1) {
      return 'now';
    }
    if (difference.inHours < 1) {
      return '${difference.inMinutes}m';
    }
    if (difference.inDays < 1) {
      return '${difference.inHours}h';
    }
    return '${difference.inDays}d';
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.softGray,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppTheme.border),
      ),
      child: Text(label),
    );
  }
}
