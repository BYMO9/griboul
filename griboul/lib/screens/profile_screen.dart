import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/colors.dart';
import '../constants/fonts.dart';
import '../constants/sizes.dart';
import '../providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    final profile = authProvider.userProfile ?? {};

    return Scaffold(
      backgroundColor: AppColors.primaryBlack,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Text(
                    'Builder',
                    style: TextStyle(
                      fontFamily: 'Georgia',
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/settings');
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppColors.textPrimary.withOpacity(0.3),
                          width: 1,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.settings_outlined,
                        color: AppColors.textPrimary,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Container(
              height: 0.5,
              color: AppColors.textPrimary.withOpacity(0.2),
            ),

            // Profile content
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // Profile header
                  _buildProfileHeader(user, profile),

                  const SizedBox(height: 32),

                  // Stats
                  _buildStats(),

                  const SizedBox(height: 32),

                  // Videos grid
                  Row(
                    children: [
                      Text(
                        'YOUR VIDEOS',
                        style: TextStyle(
                          fontFamily: 'Helvetica',
                          fontSize: 11,
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () {
                          // Toggle between public and private
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: AppColors.textPrimary.withOpacity(0.3),
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.lock_outline,
                                size: 14,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'PRIVATE (3)',
                                style: TextStyle(
                                  fontFamily: 'Helvetica',
                                  fontSize: 10,
                                  letterSpacing: 1.0,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  _buildVideoGrid(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(dynamic user, Map<String, dynamic> profile) {
    return Column(
      children: [
        // Avatar
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: AppColors.surfaceBlack,
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.textPrimary.withOpacity(0.2),
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              (profile['name'] ?? user?.displayName ?? 'U')
                  .substring(0, 1)
                  .toUpperCase(),
              style: const TextStyle(
                fontFamily: 'Georgia',
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),

        const SizedBox(height: 20),

        // Name
        Text(
          profile['name'] ?? user?.displayName ?? 'Unknown Builder',
          style: const TextStyle(
            fontFamily: 'Georgia',
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),

        const SizedBox(height: 8),

        // Location and building
        Text(
          '${profile['location'] ?? 'Earth'} • ${profile['age'] ?? '∞'} years old',
          style: TextStyle(
            fontFamily: 'Helvetica',
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),

        const SizedBox(height: 16),

        // What building
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.surfaceBlack,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            profile['building'] ?? 'Building something amazing',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Georgia',
              fontSize: 16,
              color: AppColors.textPrimary,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStats() {
    return Row(
      children: [
        Expanded(child: _buildStatItem('VIDEOS', '12')),
        Container(
          width: 1,
          height: 40,
          color: AppColors.textPrimary.withOpacity(0.1),
        ),
        Expanded(child: _buildStatItem('VIEWS', '1.2K')),
        Container(
          width: 1,
          height: 40,
          color: AppColors.textPrimary.withOpacity(0.1),
        ),
        Expanded(child: _buildStatItem('CONNECTIONS', '48')),
      ],
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Georgia',
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Helvetica',
            fontSize: 10,
            letterSpacing: 1.2,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildVideoGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
        childAspectRatio: 1,
      ),
      itemCount: 9,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceBlack,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Stack(
            children: [
              // Placeholder for video thumbnail
              Center(
                child: Icon(
                  Icons.play_circle_outline,
                  color: AppColors.textTertiary,
                  size: 32,
                ),
              ),

              // Duration
              Positioned(
                bottom: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlack.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: Text(
                    '2:34',
                    style: const TextStyle(
                      fontFamily: 'Helvetica',
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
