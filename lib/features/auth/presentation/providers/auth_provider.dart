import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../data/repositories/auth_repository.dart';
import '../../domain/models/app_user.dart';

enum AuthMode { signIn, signUp }

class AuthProvider extends ChangeNotifier {
  AuthProvider(this._authRepository) {
    _subscription = _authRepository.authStateChanges().listen((user) {
      _currentUser = user;
      _isReady = true;
      notifyListeners();
    });
  }

  final AuthRepository _authRepository;
  StreamSubscription<AppUser?>? _subscription;

  AppUser? _currentUser;
  bool _isReady = false;
  bool _isBusy = false;
  String? _errorMessage;
  AuthMode _authMode = AuthMode.signIn;

  AppUser? get currentUser => _currentUser;
  bool get isReady => _isReady;
  bool get isBusy => _isBusy;
  bool get isAuthenticated => _currentUser != null;
  String? get errorMessage => _errorMessage;
  AuthMode get authMode => _authMode;

  void setAuthMode(AuthMode mode) {
    if (_authMode == mode) {
      return;
    }
    _authMode = mode;
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    if (_errorMessage == null) {
      return;
    }
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> submitEmailAuth({
    required String email,
    required String password,
  }) async {
    return _runAuthAction(() async {
      if (_authMode == AuthMode.signIn) {
        await _authRepository.signInWithEmail(email: email, password: password);
      } else {
        await _authRepository.signUpWithEmail(email: email, password: password);
      }
    });
  }

  Future<bool> signInWithGoogle() async {
    return _runAuthAction(_authRepository.signInWithGoogle);
  }

  Future<bool> continueAsGuest() async {
    return _runAuthAction(_authRepository.signInAnonymously);
  }

  Future<bool> signOut() async {
    return _runAuthAction(_authRepository.signOut);
  }

  Future<bool> _runAuthAction(Future<dynamic> Function() action) async {
    _isBusy = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await action();
      return true;
    } on FirebaseAuthException catch (error) {
      _errorMessage = _mapFirebaseError(error);
      return false;
    } catch (_) {
      _errorMessage = 'Authentication failed. Please try again.';
      return false;
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }

  String _mapFirebaseError(FirebaseAuthException error) {
    switch (error.code) {
      case 'invalid-email':
        return 'The email address is invalid.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
        return 'No Firebase user exists for that email.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Email or password is incorrect.';
      case 'email-already-in-use':
        return 'That email is already registered.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'account-exists-with-different-credential':
        return 'This email already exists with another sign-in method.';
      case 'network-request-failed':
        return 'Network error. Check your connection and try again.';
      default:
        return error.message ?? 'Authentication failed. Please try again.';
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
