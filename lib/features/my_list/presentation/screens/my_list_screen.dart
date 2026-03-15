import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../router/route_names.dart';
import '../../../movies/presentation/widgets/movie_poster_card.dart';
import '../../../user_data/presentation/providers/user_data_provider.dart';

class MyListScreen extends StatelessWidget {
  const MyListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Consumer<UserDataProvider>(
          builder: (context, provider, _) {
            final watchlist = provider.watchlist;

            if (watchlist.isEmpty) {
              return Center(
                child: Text(
                  'Your watchlist is empty.',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My List',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 6),
                Text(
                  'Saved movies stay here for quick trailer replays and review follow-ups.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: GridView.builder(
                    itemCount: watchlist.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 14,
                          crossAxisSpacing: 14,
                          childAspectRatio: 0.52,
                        ),
                    itemBuilder: (context, index) {
                      final movie = watchlist[index];
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
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
