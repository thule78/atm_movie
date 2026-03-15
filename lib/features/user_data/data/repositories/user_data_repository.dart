import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../../auth/domain/models/app_user.dart';
import '../../../movies/domain/models/movie.dart';
import '../../domain/models/app_profile.dart';
import '../../domain/models/movie_comment.dart';

abstract class UserDataRepository {
  Future<void> ensureProfile(AppUser user);
  Stream<AppProfile?> watchProfile(String userId);
  Future<void> updateProfile({
    required String userId,
    required String displayName,
    String? photoUrl,
  });
  Future<String> uploadProfilePhoto({
    required String userId,
    required List<int> bytes,
    required String fileExtension,
  });
  Stream<List<Movie>> watchWatchlist(String userId);
  Future<void> saveMovieToWatchlist({
    required String userId,
    required Movie movie,
  });
  Future<void> removeMovieFromWatchlist({
    required String userId,
    required int movieId,
  });
  Stream<List<MovieComment>> watchComments(int movieId);
  Stream<List<MovieComment>> watchUserComments(String userId);
  Future<void> addComment({
    required Movie movie,
    required AppUser user,
    required String authorName,
    required String text,
  });
  Future<void> deleteComment({
    required String userId,
    required int movieId,
    required String commentId,
  });
}

class FirestoreUserDataRepository implements UserDataRepository {
  FirestoreUserDataRepository({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  @override
  Future<void> ensureProfile(AppUser user) async {
    final docRef = _firestore.collection('users').doc(user.id);
    final snapshot = await docRef.get();

    final data = {
      'userId': user.id,
      'displayName': user.resolvedName,
      'email': user.email,
      'isAnonymous': user.isAnonymous,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (!snapshot.exists) {
      await docRef.set({...data, 'createdAt': FieldValue.serverTimestamp()});
      return;
    }

    await docRef.set(data, SetOptions(merge: true));
  }

  @override
  Stream<AppProfile?> watchProfile(String userId) {
    return _firestore.collection('users').doc(userId).snapshots().map((doc) {
      if (!doc.exists) {
        return null;
      }
      final data = doc.data()!;
      return AppProfile(
        userId: userId,
        displayName: (data['displayName'] as String?)?.trim().isNotEmpty == true
            ? data['displayName'] as String
            : 'Movie User',
        email: (data['email'] as String?)?.trim() ?? 'No email available',
        isAnonymous: data['isAnonymous'] as bool? ?? false,
        photoUrl: data['photoUrl'] as String?,
      );
    });
  }

  @override
  Future<void> updateProfile({
    required String userId,
    required String displayName,
    String? photoUrl,
  }) async {
    await _firestore.collection('users').doc(userId).set({
      'displayName': displayName.trim(),
      if (photoUrl != null) 'photoUrl': photoUrl,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  @override
  Future<String> uploadProfilePhoto({
    required String userId,
    required List<int> bytes,
    required String fileExtension,
  }) async {
    final normalizedExtension = fileExtension.toLowerCase().replaceAll('.', '');
    final ref = _storage.ref().child(
      'profile_photos/$userId/avatar.$normalizedExtension',
    );

    await ref.putData(
      Uint8List.fromList(bytes),
      SettableMetadata(
        contentType: _contentTypeForExtension(normalizedExtension),
      ),
    );

    return ref.getDownloadURL();
  }

  @override
  Stream<List<Movie>> watchWatchlist(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('watchlist')
        .orderBy('savedAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((doc) {
            final data = doc.data();
            return Movie(
              id: (data['movieId'] as num?)?.toInt() ?? int.parse(doc.id),
              title: data['title'] as String? ?? 'Untitled',
              overview:
                  data['overview'] as String? ?? 'Overview not available yet.',
              rating: (data['rating'] as num?)?.toDouble() ?? 0,
              genreNames: (data['genreNames'] as List<dynamic>? ?? const [])
                  .whereType<String>()
                  .toList(),
              releaseDate: DateTime.tryParse(
                data['releaseDate'] as String? ?? '',
              ),
              posterUrl: data['posterUrl'] as String?,
              backdropUrl: data['backdropUrl'] as String?,
              runtimeMinutes: data['runtimeMinutes'] as int?,
            );
          }).toList(),
        );
  }

  @override
  Future<void> saveMovieToWatchlist({
    required String userId,
    required Movie movie,
  }) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('watchlist')
        .doc(movie.id.toString())
        .set({
          'userId': userId,
          'movieId': movie.id,
          'title': movie.title,
          'overview': movie.overview,
          'rating': movie.rating,
          'genreNames': movie.genreNames,
          'releaseDate': movie.releaseDate?.toIso8601String(),
          'posterUrl': movie.posterUrl,
          'backdropUrl': movie.backdropUrl,
          'runtimeMinutes': movie.runtimeMinutes,
          'savedAt': FieldValue.serverTimestamp(),
        });
  }

  @override
  Future<void> removeMovieFromWatchlist({
    required String userId,
    required int movieId,
  }) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('watchlist')
        .doc(movieId.toString())
        .delete();
  }

  @override
  Stream<List<MovieComment>> watchComments(int movieId) {
    return _firestore
        .collection('movies')
        .doc(movieId.toString())
        .collection('comments')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((doc) {
            final data = doc.data();
            final timestamp = data['createdAt'] as Timestamp?;
            return MovieComment(
              id: doc.id,
              movieId: (data['movieId'] as num?)?.toInt() ?? movieId,
              movieTitle: data['movieTitle'] as String? ?? 'Movie',
              userId: data['userId'] as String? ?? '',
              authorName: data['authorName'] as String? ?? 'Movie User',
              text: data['text'] as String? ?? '',
              createdAt: timestamp?.toDate() ?? DateTime.now(),
            );
          }).toList(),
        );
  }

  @override
  Stream<List<MovieComment>> watchUserComments(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('comments')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((doc) {
            final data = doc.data();
            final timestamp = data['createdAt'] as Timestamp?;
            return MovieComment(
              id: doc.id,
              movieId: (data['movieId'] as num?)?.toInt() ?? 0,
              movieTitle: data['movieTitle'] as String? ?? 'Movie',
              userId: data['userId'] as String? ?? userId,
              authorName: data['authorName'] as String? ?? 'Movie User',
              text: data['text'] as String? ?? '',
              createdAt: timestamp?.toDate() ?? DateTime.now(),
            );
          }).toList(),
        );
  }

  @override
  Future<void> addComment({
    required Movie movie,
    required AppUser user,
    required String authorName,
    required String text,
  }) async {
    final movieRef = _firestore.collection('movies').doc(movie.id.toString());
    final commentRef = _firestore
        .collection('movies')
        .doc(movie.id.toString())
        .collection('comments')
        .doc();
    final userCommentRef = _firestore
        .collection('users')
        .doc(user.id)
        .collection('comments')
        .doc(commentRef.id);

    final payload = {
      'commentId': commentRef.id,
      'movieId': movie.id,
      'movieTitle': movie.title,
      'userId': user.id,
      'authorName': authorName,
      'text': text.trim(),
      'createdAt': FieldValue.serverTimestamp(),
    };

    final batch = _firestore.batch();
    batch.set(
      movieRef,
      {
        'movieId': movie.id,
        'title': movie.title,
        'posterUrl': movie.posterUrl,
        'backdropUrl': movie.backdropUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
    batch.set(commentRef, payload);
    batch.set(userCommentRef, payload);
    await batch.commit();
  }

  @override
  Future<void> deleteComment({
    required String userId,
    required int movieId,
    required String commentId,
  }) async {
    await _firestore
        .collection('movies')
        .doc(movieId.toString())
        .collection('comments')
        .doc(commentId)
        .delete();
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('comments')
        .doc(commentId)
        .delete();
  }

  String _contentTypeForExtension(String extension) {
    switch (extension) {
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      default:
        return 'image/jpeg';
    }
  }
}
