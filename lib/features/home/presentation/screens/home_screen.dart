import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../../router/route_names.dart';
import '../../../movies/domain/models/movie.dart';
import '../../../movies/presentation/providers/movie_provider.dart';
import '../../../movies/presentation/widgets/movie_artwork.dart';
import '../../../movies/presentation/widgets/movie_poster_card.dart';
import '../../../movies/presentation/widgets/section_header.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Consumer<MovieProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.featuredMovie == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null && provider.featuredMovie == null) {
            return _ErrorState(message: provider.errorMessage!);
          }

          final featured = provider.featuredMovie;
          if (featured == null) {
            return const _ErrorState(message: 'No featured movie available.');
          }

          return RefreshIndicator(
            onRefresh: provider.loadHome,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              children: [
                Text(
                  'Discover',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 6),
                Text(
                  'Find today’s standout trailers and reviews.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 20),
                _FeaturedBanner(movie: featured),
                const SizedBox(height: 28),
                const SectionHeader(
                  title: 'Top 10 Movies',
                  actionLabel: 'Live',
                ),
                const SizedBox(height: 14),
                SizedBox(
                  height: 340,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: provider.topMovies.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 14),
                    itemBuilder: (context, index) {
                      final movie = provider.topMovies[index];
                      return MoviePosterCard(
                        movie: movie,
                        onTap: () => _openMovieDetail(context, movie),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 28),
                const SectionHeader(
                  title: 'New Releases',
                  actionLabel: 'Now playing',
                ),
                const SizedBox(height: 14),
                ...provider.newReleases.map(
                  (movie) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: _ReleaseRow(
                      movie: movie,
                      onTap: () => _openMovieDetail(context, movie),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _openMovieDetail(BuildContext context, Movie movie) {
    Navigator.of(context).pushNamed(RouteNames.movieDetail, arguments: movie);
  }
}

class _FeaturedBanner extends StatelessWidget {
  const _FeaturedBanner({required this.movie});

  final Movie movie;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(28),
      onTap: () {
        Navigator.of(
          context,
        ).pushNamed(RouteNames.movieDetail, arguments: movie);
      },
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: const LinearGradient(
            colors: [Color(0xFF101828), AppTheme.primaryRed],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  'Featured movie',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              MovieArtwork(
                imageUrl: movie.backdropUrl ?? movie.posterUrl,
                height: 220,
                width: double.infinity,
                borderRadius: 22,
                iconSize: 64,
              ),
              const SizedBox(height: 18),
              Text(
                movie.title,
                style: Theme.of(
                  context,
                ).textTheme.headlineMedium?.copyWith(color: Colors.white),
              ),
              const SizedBox(height: 10),
              Text(
                '${movie.primaryGenre} • ${movie.durationLabel} • ${movie.rating.toStringAsFixed(1)}',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: Colors.white70),
              ),
              const SizedBox(height: 16),
              Text(
                movie.overview,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
              ),
              const SizedBox(height: 22),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppTheme.ink,
                ),
                onPressed: () {
                  Navigator.of(
                    context,
                  ).pushNamed(RouteNames.movieDetail, arguments: movie);
                },
                icon: const Icon(Icons.play_circle_fill_rounded),
                label: const Text('Watch trailer'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReleaseRow extends StatelessWidget {
  const _ReleaseRow({required this.movie, required this.onTap});

  final Movie movie;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              MovieArtwork(
                imageUrl: movie.posterUrl,
                width: 88,
                height: 110,
                iconSize: 34,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      movie.title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${movie.year == 0 ? 'TBA' : movie.year} • ${movie.primaryGenre}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      movie.overview,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, size: 40),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => context.read<MovieProvider>().loadHome(),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
