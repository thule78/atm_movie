import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../router/route_names.dart';
import '../../../movies/presentation/providers/movie_provider.dart';
import '../../../movies/presentation/widgets/movie_poster_card.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (!mounted) {
        return;
      }

      context.read<MovieProvider>().searchMovies(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          Text('Explore', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 6),
          Text(
            'Search movies and browse the latest trailer-worthy picks.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _controller,
            onChanged: _onSearchChanged,
            decoration: const InputDecoration(
              hintText: 'Search movies',
              prefixIcon: Icon(Icons.search_rounded),
            ),
          ),
          const SizedBox(height: 20),
          Consumer<MovieProvider>(
            builder: (context, provider, _) {
              if (provider.isSearching) {
                return const Padding(
                  padding: EdgeInsets.only(top: 48),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (provider.searchError != null) {
                return Center(child: Text(provider.searchError!));
              }

              if (provider.searchQuery.isEmpty) {
                return const _ExploreHint();
              }

              if (provider.searchResults.isEmpty) {
                return const _EmptySearchState();
              }

              return GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: provider.searchResults.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 0.52,
                ),
                itemBuilder: (context, index) {
                  final movie = provider.searchResults[index];
                  return MoviePosterCard(
                    movie: movie,
                    width: double.infinity,
                    onTap: () {
                      Navigator.of(
                        context,
                      ).pushNamed(RouteNames.movieDetail, arguments: movie);
                    },
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ExploreHint extends StatelessWidget {
  const _ExploreHint();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(top: 56),
      child: Center(
        child: Text('Start typing to search real movies from TMDb.'),
      ),
    );
  }
}

class _EmptySearchState extends StatelessWidget {
  const _EmptySearchState();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(top: 56),
      child: Center(child: Text('No movies matched your search.')),
    );
  }
}
