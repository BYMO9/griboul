import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _user;
  Map<String, dynamic>? _userProfile;
  bool _isLoading = false;
  String? _error;
  bool _hasCompletedOnboarding = false;

  // Getters
  User? get user => _user;
  Map<String, dynamic>? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;
  bool get hasCompletedOnboarding => _hasCompletedOnboarding;

  AuthProvider() {
    _init();
  }

  void _init() {
    // Listen to auth state changes
    _authService.authStateChanges.listen((User? user) async {
      _user = user;
      if (user != null) {
        await loadUserProfile();
      } else {
        _userProfile = null;
        _hasCompletedOnboarding = false;
      }
      notifyListeners();
    });
  }

  // Load user profile from backend
  Future<void> loadUserProfile() async {
    if (_user == null) return;

    try {
      _isLoading = true;
      notifyListeners();

      final profile = await _authService.getUserProfile();
      _userProfile = profile;
      _hasCompletedOnboarding = profile?['hasCompletedOnboarding'] ?? false;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Sign in with Google - UPDATED METHOD HERE
  Future<bool> signInWithGoogle() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      print('AuthProvider: Starting Google sign in...');
      final user = await _authService.signInWithGoogle();

      if (user != null) {
        print('AuthProvider: Sign in successful for ${user.email}');
        _user = user;

        // Don't wait for profile load, let it happen async
        loadUserProfile().then((_) {
          print('AuthProvider: Profile loaded');
        });

        _isLoading = false;
        notifyListeners();
        return true;
      }

      print('AuthProvider: Sign in returned null');
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      print('AuthProvider: Sign in error: $e');
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Sign in with Apple
  Future<bool> signInWithApple() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final user = await _authService.signInWithApple();
      if (user != null) {
        _user = user;
        await loadUserProfile();
        _isLoading = false;
        notifyListeners();
        return true;
      }

      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Complete onboarding
  Future<bool> completeOnboarding(String introVideoUrl) async {
    try {
      _isLoading = true;
      notifyListeners();

      final success = await _authService.completeOnboarding(introVideoUrl);
      if (success) {
        _hasCompletedOnboarding = true;
        await loadUserProfile();
      }

      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update user profile
  Future<bool> updateProfile(Map<String, dynamic> profileData) async {
    try {
      _isLoading = true;
      notifyListeners();

      // TEMPORARY: Since backend doesn't exist, just update local state
      _userProfile = {..._userProfile ?? {}, ...profileData};

      if (profileData.containsKey('hasCompletedOnboarding')) {
        _hasCompletedOnboarding = profileData['hasCompletedOnboarding'] == true;
      }

      _isLoading = false;
      notifyListeners();
      return true;

      /* ORIGINAL CODE - uncomment when backend is ready
      final success = await _authService.updateUserProfile(profileData);
      if (success) {
        await loadUserProfile();
      }

      _isLoading = false;
      notifyListeners();
      return success;
      */
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _authService.signOut();
      _user = null;
      _userProfile = null;
      _hasCompletedOnboarding = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
