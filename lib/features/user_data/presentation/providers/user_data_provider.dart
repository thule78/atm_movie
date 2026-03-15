import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../auth/domain/models/app_user.dart';
import '../../data/repositories/user_data_repository.dart';
import '../../domain/models/app_profile.dart';
import '../../domain/models/movie_comment.dart';
import '../../../movies/domain/models/movie.dart';

class UserDataProvider extends ChangeNotifier {
  UserDataProvider(this._repository);

  final UserDataRepository _repository;
  StreamSubscription<AppProfile?>? _profileSubscription;
  StreamSubscription<List<Movie>>? _watchlistSubscription;

  AppUser? _currentUser;
  AppProfile? _profile;
  List<Movie> _watchlist = const [];
  bool _isUpdatingProfile = false;
  String? _profileError;
  final Set<int> _pendingWatchlistIds = {};
  final Map<int, bool> _commentSubmitting = {};

  AppProfile? get profile => _profile;
  List<Movie> get watchlist => _watchlist;
  bool get isUpdatingProfile => _isUpdatingProfile;
  String? get profileError => _profileError;
  String? get currentUserId => _currentUser?.id;

  void syncAuthUser(AppUser? user) {
    if (_currentUser?.id == user?.id) {
      return;
    }

    _currentUser = user;
    _profileSubscription?.cancel();
    _watchlistSubscription?.cancel();
    _profile = null;
    _watchlist = const [];
    _profileError = null;
    _pendingWatchlistIds.clear();
    _commentSubmitting.clear();

    if (user == null) {
      notifyListeners();
      return;
    }

    _repository.ensureProfile(user);
    _profileSubscription = _repository.watchProfile(user.id).listen((profile) {
      _profile = profile;
      notifyListeners();
    });
    _watchlistSubscription = _repository.watchWatchlist(user.id).listen((
      movies,
    ) {
      _watchlist = movies;
      notifyListeners();
    });
    notifyListeners();
  }

  bool isInWatchlist(int movieId) {
    return _watchlist.any((movie) => movie.id == movieId);
  }

  bool isWatchlistActionPending(int movieId) {
    return _pendingWatchlistIds.contains(movieId);
  }

  Future<void> toggleWatchlist(Movie movie) async {
    final user = _currentUser;
    if (user == null) {
      _profileError = 'Sign in before managing your watchlist.';
      notifyListeners();
      return;
    }

    _pendingWatchlistIds.add(movie.id);
    _profileError = null;
    notifyListeners();

    try {
      if (isInWatchlist(movie.id)) {
        await _repository.removeMovieFromWatchlist(
          userId: user.id,
          movieId: movie.id,
        );
      } else {
        await _repository.saveMovieToWatchlist(userId: user.id, movie: movie);
      }
    } on FirebaseException catch (error) {
      _profileError =
          error.message ?? 'Firestore rejected the watchlist update.';
    } catch (_) {
      _profileError = 'Could not update your watchlist right now.';
    } finally {
      _pendingWatchlistIds.remove(movie.id);
      notifyListeners();
    }
  }

  Future<void> updateProfile({
    required String displayName,
    List<int>? photoBytes,
    String? photoExtension,
  }) async {
    final user = _currentUser;
    if (user == null) {
      _profileError = 'Sign in before editing your profile.';
      notifyListeners();
      return;
    }

    _isUpdatingProfile = true;
    _profileError = null;
    notifyListeners();

    try {
      String? uploadedPhotoUrl;
      if (photoBytes != null && photoExtension != null) {
        uploadedPhotoUrl = await _repository.uploadProfilePhoto(
          userId: user.id,
          bytes: photoBytes,
          fileExtension: photoExtension,
        );
      }
      await _repository.updateProfile(
        userId: user.id,
        displayName: displayName,
        photoUrl: uploadedPhotoUrl,
      );
    } on FirebaseException catch (error) {
      _profileError = error.message ?? 'Firestore rejected the profile update.';
    } catch (_) {
      _profileError = 'Could not update your profile right now.';
    } finally {
      _isUpdatingProfile = false;
      notifyListeners();
    }
  }

  Stream<List<MovieComment>> commentsStream(int movieId) {
    return _repository.watchComments(movieId);
  }

  Stream<List<MovieComment>> myCommentsStream() {
    final userId = _currentUser?.id;
    if (userId == null) {
      return const Stream<List<MovieComment>>.empty();
    }
    return _repository.watchUserComments(userId);
  }

  bool isSubmittingComment(int movieId) {
    return _commentSubmitting[movieId] ?? false;
  }

  Future<bool> addComment({required Movie movie, required String text}) async {
    final user = _currentUser;
    if (user == null) {
      _profileError = 'Sign in before posting comments.';
      notifyListeners();
      return false;
    }

    _commentSubmitting[movie.id] = true;
    _profileError = null;
    notifyListeners();

    try {
      await _repository.addComment(
        movie: movie,
        user: user,
        authorName: _profile?.displayName ?? user.resolvedName,
        text: text,
      );
      return true;
    } on FirebaseException catch (error) {
      _profileError = error.message ?? 'Firestore rejected the comment.';
      return false;
    } catch (_) {
      _profileError = 'Could not post your comment right now.';
      return false;
    } finally {
      _commentSubmitting[movie.id] = false;
      notifyListeners();
    }
  }

  Future<bool> deleteComment(MovieComment comment) async {
    final user = _currentUser;
    if (user == null || user.id != comment.userId) {
      _profileError = 'You can only delete your own comments.';
      notifyListeners();
      return false;
    }

    try {
      await _repository.deleteComment(
        userId: user.id,
        movieId: comment.movieId,
        commentId: comment.id,
      );
      return true;
    } on FirebaseException catch (error) {
      _profileError = error.message ?? 'Firestore rejected the delete request.';
      return false;
    } catch (_) {
      _profileError = 'Could not delete your comment right now.';
      return false;
    }
  }

  @override
  void dispose() {
    _profileSubscription?.cancel();
    _watchlistSubscription?.cancel();
    super.dispose();
  }
}
