import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../constants/colors.dart';
import '../constants/fonts.dart';
import '../constants/sizes.dart';
import '../providers/auth_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _dailyReminders = true;
  bool _messageNotifications = true;
  bool _emailUpdates = false;

  void _showSignOutDialog() {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            backgroundColor: AppColors.surfaceBlack,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(0),
            ),
            child: Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Sign Out?',
                    style: TextStyle(
                      fontFamily: 'Georgia',
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'You\'ll need to sign in again to access your account.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Georgia',
                      fontSize: 16,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: AppColors.textPrimary.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                'CANCEL',
                                style: TextStyle(
                                  fontFamily: 'Helvetica',
                                  fontSize: 12,
                                  letterSpacing: 1.2,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            Navigator.pop(context);
                            final authProvider = Provider.of<AuthProvider>(
                              context,
                              listen: false,
                            );
                            await authProvider.signOut();
                            if (mounted) {
                              Navigator.of(context).pushNamedAndRemoveUntil(
                                '/login',
                                (route) => false,
                              );
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            color: AppColors.accentRed,
                            child: Center(
                              child: Text(
                                'SIGN OUT',
                                style: TextStyle(
                                  fontFamily: 'Helvetica',
                                  fontSize: 12,
                                  letterSpacing: 1.2,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.arrow_back,
                      color: AppColors.textPrimary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Settings',
                    style: TextStyle(
                      fontFamily: 'Georgia',
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),

            Container(
              height: 0.5,
              color: AppColors.textPrimary.withOpacity(0.2),
            ),

            // Settings list
            Expanded(
              child: ListView(
                children: [
                  // Notifications section
                  _buildSectionHeader('NOTIFICATIONS'),
                  _buildToggleItem(
                    'Daily Reminders',
                    'Get notified to record your daily video',
                    _dailyReminders,
                    (value) => setState(() => _dailyReminders = value),
                  ),
                  _buildToggleItem(
                    'Messages',
                    'New messages from other builders',
                    _messageNotifications,
                    (value) => setState(() => _messageNotifications = value),
                  ),
                  _buildToggleItem(
                    'Email Updates',
                    'Weekly digest and product updates',
                    _emailUpdates,
                    (value) => setState(() => _emailUpdates = value),
                  ),

                  const SizedBox(height: 32),

                  // Account section
                  _buildSectionHeader('ACCOUNT'),
                  _buildListItem(
                    'Privacy',
                    'Control who can see your videos',
                    () {},
                  ),
                  _buildListItem(
                    'Blocked Users',
                    'Manage blocked accounts',
                    () {},
                  ),
                  _buildListItem(
                    'Delete Account',
                    'Permanently delete your account',
                    () {},
                    isDestructive: true,
                  ),

                  const SizedBox(height: 32),

                  // About section
                  _buildSectionHeader('ABOUT'),
                  _buildListItem('Terms of Service', null, () {}),
                  _buildListItem('Privacy Policy', null, () {}),
                  _buildListItem('Version', '1.0.0', null, showArrow: false),

                  const SizedBox(height: 32),

                  // Sign out button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: GestureDetector(
                      onTap: _showSignOutDialog,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: AppColors.accentRed.withOpacity(0.1),
                          border: Border.all(
                            color: AppColors.accentRed,
                            width: 1,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'SIGN OUT',
                            style: TextStyle(
                              fontFamily: 'Helvetica',
                              fontSize: 14,
                              letterSpacing: 1.2,
                              fontWeight: FontWeight.w600,
                              color: AppColors.accentRed,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Text(
        title,
        style: TextStyle(
          fontFamily: 'Helvetica',
          fontSize: 11,
          letterSpacing: 1.5,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildToggleItem(
    String title,
    String? subtitle,
    bool value,
    Function(bool) onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.textPrimary.withOpacity(0.1),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Helvetica',
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: 'Georgia',
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          CupertinoSwitch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.accentGreen,
          ),
        ],
      ),
    );
  }

  Widget _buildListItem(
    String title,
    String? subtitle,
    VoidCallback? onTap, {
    bool showArrow = true,
    bool isDestructive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: AppColors.textPrimary.withOpacity(0.1),
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Helvetica',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color:
                          isDestructive
                              ? AppColors.accentRed
                              : AppColors.textPrimary,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontFamily: 'Georgia',
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (showArrow)
              Icon(
                Icons.chevron_right,
                color: AppColors.textTertiary,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
