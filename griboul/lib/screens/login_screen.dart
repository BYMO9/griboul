import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:dio/dio.dart';
import '../constants/colors.dart';
import '../constants/fonts.dart';
import '../constants/sizes.dart';
import '../constants/strings.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.signInWithGoogle();

    if (!success && mounted) {
      // Show error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.error ?? 'Sign in failed'),
          backgroundColor: AppColors.accentRed,
        ),
      );
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _testBackendConnection() async {
    print('Testing backend connection...');

    // Try different URLs based on platform
    final urls = [
      'http://192.168.192.76:3000/health', // Your computer's IP
      'http://localhost:3000/health',
      'http://10.0.2.2:3000/health', // Android emulator
      'http://127.0.0.1:3000/health', // Alternative localhost
    ];

    bool connected = false;
    String workingUrl = '';

    for (String url in urls) {
      try {
        print('Trying URL: $url');
        final dio = Dio();
        dio.options.connectTimeout = const Duration(seconds: 5);
        dio.options.receiveTimeout = const Duration(seconds: 5);

        final response = await dio.get(url);
        print('Success with $url: ${response.data}');

        connected = true;
        workingUrl = url;
        break;
      } catch (e) {
        print('Failed with $url: $e');
      }
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            connected
                ? 'Backend connected at $workingUrl!'
                : 'Backend connection failed. Make sure backend is running.',
          ),
          backgroundColor:
              connected ? AppColors.accentGreen : AppColors.accentRed,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBlack,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.lg),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // Logo and tagline
              Column(
                children: [
                  Text(
                        AppStrings.appName,
                        style: TextStyle(
                          fontFamily: AppFonts.primary,
                          fontSize: 64,
                          fontWeight: AppFonts.bold,
                          color: AppColors.textPrimary,
                          letterSpacing: AppFonts.tightSpacing,
                          height: 1.0,
                        ),
                      )
                      .animate()
                      .fadeIn(duration: 600.ms)
                      .scale(
                        begin: const Offset(0.9, 0.9),
                        end: const Offset(1, 1),
                        duration: 500.ms,
                        curve: Curves.easeOut,
                      ),

                  const SizedBox(height: AppSizes.md),

                  Text(
                    AppStrings.tagline.toUpperCase(),
                    style: TextStyle(
                      fontFamily: AppFonts.secondary,
                      fontSize: 14,
                      fontWeight: AppFonts.medium,
                      color: AppColors.textSecondary,
                      letterSpacing: 3.0,
                    ),
                  ).animate().fadeIn(delay: 300.ms, duration: 600.ms),

                  const SizedBox(height: AppSizes.xxl),

                  // Description
                  Text(
                        'Share your daily building journey\nin authentic 5-minute videos',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: AppFonts.secondary,
                          fontSize: AppFonts.body1,
                          fontWeight: AppFonts.regular,
                          color: AppColors.textSecondary,
                          height: 1.6,
                        ),
                      )
                      .animate()
                      .fadeIn(delay: 500.ms, duration: 600.ms)
                      .slideY(begin: 0.1, end: 0, delay: 500.ms),
                ],
              ),

              const Spacer(flex: 3),

              // Sign in buttons
              Column(
                children: [
                  // Google Sign In
                  _buildSignInButton(
                        onPressed: _isLoading ? null : _handleGoogleSignIn,
                        icon: 'assets/icons/google.png',
                        label: AppStrings.continueWithGoogle,
                        isLoading: _isLoading,
                      )
                      .animate()
                      .fadeIn(delay: 700.ms, duration: 600.ms)
                      .slideY(begin: 0.2, end: 0, delay: 700.ms),

                  const SizedBox(height: AppSizes.md),

                  // Apple Sign In (coming soon)
                  _buildSignInButton(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Apple Sign In coming soon'),
                            ),
                          );
                        },
                        icon: 'assets/icons/apple.png',
                        label: AppStrings.continueWithApple,
                        isApple: true,
                      )
                      .animate()
                      .fadeIn(delay: 800.ms, duration: 600.ms)
                      .slideY(begin: 0.2, end: 0, delay: 800.ms),

                  const SizedBox(height: AppSizes.lg),

                  // Test Backend Connection Button
                  TextButton(
                    onPressed: _testBackendConnection,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.lg,
                        vertical: AppSizes.sm,
                      ),
                    ),
                    child: Text(
                      'Test Backend Connection',
                      style: TextStyle(
                        fontFamily: AppFonts.secondary,
                        fontSize: 14,
                        fontWeight: AppFonts.medium,
                        color: AppColors.textSecondary,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ).animate().fadeIn(delay: 900.ms, duration: 600.ms),
                ],
              ),

              const Spacer(),

              // Terms text
              Padding(
                padding: const EdgeInsets.only(bottom: AppSizes.lg),
                child: Text(
                  'By continuing, you agree to our Terms of Service\nand Privacy Policy',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: AppFonts.secondary,
                    fontSize: AppFonts.caption,
                    fontWeight: AppFonts.regular,
                    color: AppColors.textTertiary,
                    height: 1.4,
                  ),
                ),
              ).animate().fadeIn(delay: 1000.ms, duration: 600.ms),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSignInButton({
    required VoidCallback? onPressed,
    required String icon,
    required String label,
    bool isApple = false,
    bool isLoading = false,
  }) {
    return SizedBox(
      width: double.infinity,
      height: AppSizes.buttonHeight,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor:
              isApple ? AppColors.textPrimary : AppColors.primaryBlack,
          foregroundColor:
              isApple ? AppColors.primaryBlack : AppColors.textPrimary,
          side: BorderSide(
            color: isApple ? AppColors.textPrimary : AppColors.divider,
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusCircle),
          ),
        ),
        child:
            isLoading
                ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isApple ? AppColors.primaryBlack : AppColors.textPrimary,
                    ),
                  ),
                )
                : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // For now, use a placeholder icon
                    Icon(isApple ? Icons.apple : Icons.g_mobiledata, size: 24),
                    const SizedBox(width: AppSizes.sm),
                    Text(
                      label,
                      style: TextStyle(
                        fontFamily: AppFonts.secondary,
                        fontSize: AppFonts.button,
                        fontWeight: AppFonts.medium,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
      ),
    );
  }
}

// Alternative simple version without icons
class LoginScreenSimple extends StatelessWidget {
  const LoginScreenSimple({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBlack,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Griboul',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                final authProvider = Provider.of<AuthProvider>(
                  context,
                  listen: false,
                );
                authProvider.signInWithGoogle();
              },
              child: const Text('Continue with Google'),
            ),
          ],
        ),
      ),
    );
  }
}
