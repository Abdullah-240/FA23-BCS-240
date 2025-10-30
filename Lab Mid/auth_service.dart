import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AuthService extends ChangeNotifier {
  bool _signedIn = false;
  bool _isLoading = false;
  String? _errorMessage;

  bool get isSignedIn => _signedIn;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Simulate Google Sign-In (Fake for local testing)
  Future<void> signInWithGoogle() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Simulate a delay for loading spinner
      await Future.delayed(const Duration(seconds: 2));

      // Pretend sign-in successful
      _signedIn = true;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Sign-in failed: $e';
      notifyListeners();
    }
  }

  /// Simulate Sign-Out
  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1)); // just a short delay

    _signedIn = false;
    _isLoading = false;
    notifyListeners();
  }
}
