import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final Dio _dio = Dio();

  // Backend API URL - Updated with your IP address
  static String get apiUrl {
    // For physical device (iPhone), use your computer's IP address
    return 'http://192.168.192.76:3000/api';
  }

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with Google
  Future<User?> signInWithGoogle() async {
    try {
      print('Starting Google Sign In...');
      print('Backend URL: $apiUrl');

      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        print('User cancelled Google sign in');
        return null;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the credential
      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );

      print('Firebase sign in successful: ${userCredential.user?.email}');

      // Create/update user in backend
      await _createOrUpdateUserInBackend(userCredential.user!);

      return userCredential.user;
    } catch (e) {
      print('Error signing in with Google: $e');
      return null;
    }
  }

  // Sign in with Apple (placeholder for now)
  Future<User?> signInWithApple() async {
    try {
      // TODO: Implement Apple Sign In
      print('Apple Sign In not implemented yet');
      return null;
    } catch (e) {
      print('Error signing in with Apple: $e');
      return null;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await Future.wait([_auth.signOut(), _googleSignIn.signOut()]);
  }

  // Check if user is new
  Future<bool> isNewUser(User user) async {
    try {
      print('Checking if user is new: ${user.uid}');
      print('Check URL: $apiUrl/auth/check/${user.uid}');

      // Check if user exists in our backend
      final response = await _dio.get(
        '$apiUrl/auth/check/${user.uid}',
        options: Options(validateStatus: (status) => status! < 500),
      );

      print('User check response: ${response.data}');
      print('Status code: ${response.statusCode}');

      // If user doesn't exist or hasn't completed onboarding, they're new
      final exists = response.data['exists'] == true;
      final hasCompletedOnboarding =
          response.data['hasCompletedOnboarding'] == true;

      print(
        'User exists: $exists, Completed onboarding: $hasCompletedOnboarding',
      );

      return !exists || !hasCompletedOnboarding;
    } catch (e) {
      print('Error checking if user is new: $e');
      print('Backend might not be running or route not found');
      print('Treating as new user due to error');
      // If error (like connection refused), assume new user
      return true;
    }
  }

  // Get user profile from backend
  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final user = currentUser;
      if (user == null) return null;

      print('Getting user profile for: ${user.uid}');

      final response = await _dio.get(
        '$apiUrl/auth/me',
        options: Options(
          headers: {'Authorization': 'Bearer ${await user.getIdToken()}'},
        ),
      );

      print('User profile response: ${response.data}');
      return response.data['user'];
    } catch (e) {
      print('Error getting user profile: $e');
      return null;
    }
  }

  // Update user profile
  Future<bool> updateUserProfile(Map<String, dynamic> profileData) async {
    try {
      final user = currentUser;
      if (user == null) return false;

      print('Updating user profile: $profileData');

      await _dio.put(
        '$apiUrl/auth/me',
        data: profileData,
        options: Options(
          headers: {'Authorization': 'Bearer ${await user.getIdToken()}'},
        ),
      );

      return true;
    } catch (e) {
      print('Error updating user profile: $e');
      return false;
    }
  }

  // Mark onboarding as complete
  Future<bool> completeOnboarding(String introVideoUrl) async {
    try {
      final user = currentUser;
      if (user == null) return false;

      print('Completing onboarding with video: $introVideoUrl');

      await _dio.post(
        '$apiUrl/auth/onboarding/complete',
        data: {
          'introVideoUrl': introVideoUrl,
          'completedAt': DateTime.now().toIso8601String(),
        },
        options: Options(
          headers: {'Authorization': 'Bearer ${await user.getIdToken()}'},
        ),
      );

      return true;
    } catch (e) {
      print('Error completing onboarding: $e');
      return false;
    }
  }

  // Private method to create/update user in backend
  Future<void> _createOrUpdateUserInBackend(User user) async {
    try {
      print('Creating/updating user in backend: ${user.uid}');
      print('Backend URL: $apiUrl/auth/users');

      final idToken = await user.getIdToken();
      print('Got ID token: ${idToken?.substring(0, 20) ?? 'null'}...');

      final response = await _dio.post(
        '$apiUrl/auth/users',
        data: {'displayName': user.displayName, 'photoURL': user.photoURL},
        options: Options(
          headers: {'Authorization': 'Bearer $idToken'},
          validateStatus: (status) => status! < 500,
        ),
      );

      print('Backend response status: ${response.statusCode}');
      print('Backend response data: ${response.data}');
    } catch (e) {
      print('Error creating/updating user in backend: $e');
      if (e is DioException) {
        print('DioException type: ${e.type}');
        print('DioException message: ${e.message}');
        print('DioException response: ${e.response}');
      }
      // Don't throw - we still want the user to be able to use the app
    }
  }

  // Get ID token for API calls
  Future<String?> getIdToken() async {
    try {
      final user = currentUser;
      if (user == null) return null;

      return await user.getIdToken();
    } catch (e) {
      print('Error getting ID token: $e');
      return null;
    }
  }

  // Refresh user token
  Future<void> refreshToken() async {
    try {
      final user = currentUser;
      await user?.getIdToken(true);
    } catch (e) {
      print('Error refreshing token: $e');
    }
  }
}
