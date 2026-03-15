import 'package:flutter_test/flutter_test.dart';

import 'package:atm_movie/app/app.dart';
import 'package:atm_movie/features/auth/data/repositories/auth_repository.dart';
import 'package:atm_movie/features/auth/domain/models/app_user.dart';
import 'package:atm_movie/features/movies/data/models/home_movie_feed.dart';
import 'package:atm_movie/features/movies/data/repositories/movie_repository.dart';
import 'package:atm_movie/features/movies/domain/models/movie.dart';
import 'package:atm_movie/features/user_data/data/repositories/user_data_repository.dart';
import 'package:atm_movie/features/user_data/domain/models/app_profile.dart';
import 'package:atm_movie/features/user_data/domain/models/movie_comment.dart';

void main() {
  testWidgets('splash screen renders app branding', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      AtmMovieApp(
        movieRepository: _FakeMovieRepository(),
        authRepository: _FakeAuthRepository(),
        userDataRepository: _FakeUserDataRepository(),
      ),
    );

    expect(find.text('ATM Movie'), findsOneWidget);
    expect(
      find.text('Discover movies, watch trailers, and review what matters.'),
      findsOneWidget,
    );
  });
}

class _FakeMovieRepository implements MovieRepository {
  final Movie _movie = Movie(
    id: 1,
    title: 'Test Movie',
    overview: 'Overview',
    rating: 8.5,
    genreNames: const ['Drama'],
    releaseDate: DateTime(2026, 1, 1),
    posterUrl: null,
    backdropUrl: null,
    runtimeMinutes: 120,
    trailerCount: 1,
  );

  @override
  Future<HomeMovieFeed> fetchHomeFeed() async {
    return HomeMovieFeed(
      featuredMovie: _movie,
      topMovies: [_movie],
      newReleases: [_movie],
    );
  }

  @override
  Future<Movie> fetchMovieDetail(int movieId) async => _movie;

  @override
  Future<List<Movie>> fetchRecommendations(int movieId) async => [_movie];

  @override
  Future<List<Movie>> searchMovies(String query) async => [_movie];
}

class _FakeAuthRepository implements AuthRepository {
  @override
  Stream<AppUser?> authStateChanges() => Stream<AppUser?>.value(null);

  @override
  Future<AppUser?> getCurrentUser() async => null;

  @override
  Future<AppUser> signInAnonymously() {
    throw UnimplementedError();
  }

  @override
  Future<AppUser> signInWithEmail({
    required String email,
    required String password,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<AppUser> signInWithGoogle() {
    throw UnimplementedError();
  }

  @override
  Future<void> signOut() async {}

  @override
  Future<AppUser> signUpWithEmail({
    required String email,
    required String password,
  }) {
    throw UnimplementedError();
  }
}

class _FakeUserDataRepository implements UserDataRepository {
  @override
  Future<void> addComment({
    required Movie movie,
    required AppUser user,
    required String authorName,
    required String text,
  }) async {}

  @override
  Future<void> ensureProfile(AppUser user) async {}

  @override
  Future<void> removeMovieFromWatchlist({
    required String userId,
    required int movieId,
  }) async {}

  @override
  Future<void> saveMovieToWatchlist({
    required String userId,
    required Movie movie,
  }) async {}

  @override
  Future<void> updateProfile({
    required String userId,
    required String displayName,
    String? photoUrl,
  }) async {}

  @override
  Future<String> uploadProfilePhoto({
    required String userId,
    required List<int> bytes,
    required String fileExtension,
  }) async {
    return 'https://example.com/profile.jpg';
  }

  @override
  Stream<List<MovieComment>> watchComments(int movieId) {
    return Stream.value(const []);
  }

  @override
  Stream<List<MovieComment>> watchUserComments(String userId) {
    return Stream.value(const []);
  }

  @override
  Stream<AppProfile?> watchProfile(String userId) {
    return Stream.value(null);
  }

  @override
  Stream<List<Movie>> watchWatchlist(String userId) {
    return Stream.value(const []);
  }

  @override
  Future<void> deleteComment({
    required String userId,
    required int movieId,
    required String commentId,
  }) async {}
}
