import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'firebase_options.dart';

// Screens
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/feed_screen.dart';
import 'screens/search_screen.dart';
import 'screens/record_screen.dart';
import 'screens/messages_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/video_player_screen.dart';

// Services
import 'services/auth_service.dart';

// Providers
import 'providers/auth_provider.dart';
import 'providers/video_provider.dart';
import 'providers/feed_provider.dart';

// Theme
import 'utils/theme.dart';

// Navigation
import 'widgets/main_navigation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Load environment variables
  await dotenv.load(fileName: ".env");

  runApp(const GriboulApp());
}

class GriboulApp extends StatelessWidget {
  const GriboulApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => VideoProvider()),
        ChangeNotifierProvider(create: (_) => FeedProvider()),
      ],
      child: MaterialApp(
        title: 'Griboul',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const AuthWrapper(),
        routes: {
          '/splash': (context) => const SplashScreen(),
          '/login': (context) => const LoginScreen(),
          '/onboarding': (context) => const OnboardingScreen(),
          '/main': (context) => const MainNavigation(),
          '/feed': (context) => const FeedScreen(),
          '/search': (context) => const SearchScreen(),
          '/record': (context) => const RecordScreen(),
          '/messages': (context) => const MessagesScreen(),
          '/profile': (context) => const ProfileScreen(),
          '/settings': (context) => const SettingsScreen(),
          '/video-player': (context) => const VideoPlayerScreen(),
        },
      ),
    );
  }
}

// Auth Wrapper to handle authentication state
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return StreamBuilder(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        print(
          'Auth state: ${snapshot.connectionState}, Has data: ${snapshot.hasData}',
        );

        // Show splash screen while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen();
        }

        // If user is logged in
        if (snapshot.hasData && snapshot.data != null) {
          print('User is logged in: ${snapshot.data!.email}');

          // Check if user has completed onboarding
          return FutureBuilder<bool>(
            future: authService.isNewUser(snapshot.data!),
            builder: (context, onboardingSnapshot) {
              print(
                'Onboarding check: ${onboardingSnapshot.connectionState}, Is new: ${onboardingSnapshot.data}',
              );

              if (onboardingSnapshot.connectionState ==
                  ConnectionState.waiting) {
                return const SplashScreen();
              }

              // If new user, show onboarding
              if (onboardingSnapshot.data == true) {
                print('Showing onboarding screen');
                return const OnboardingScreen();
              }

              // Otherwise, show main app
              print('Showing main app');
              return const MainNavigation();
            },
          );
        }

        // If not logged in, show login screen
        print('User not logged in, showing login screen');
        return const LoginScreen();
      },
    );
  }
}
