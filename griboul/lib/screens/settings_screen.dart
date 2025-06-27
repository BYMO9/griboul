import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../utils/griboul_theme.dart';
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
      barrierColor: GriboulTheme.ink.withOpacity(0.8),
      builder:
          (context) => Dialog(
            backgroundColor: GriboulTheme.charcoal,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                0,
              ), // Sharp corners, NYT style
            ),
            child: Container(
              padding: const EdgeInsets.all(GriboulTheme.space4),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Sign Out', style: GriboulTheme.headline3),
                  const SizedBox(height: GriboulTheme.space2),
                  Text(
                    'You\'ll need to sign in again to access your builder account.',
                    style: GriboulTheme.body1.copyWith(
                      fontFamily: 'Georgia',
                      color: GriboulTheme.ash,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: GriboulTheme.space4),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            Navigator.pop(context);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: GriboulTheme.space2,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: GriboulTheme.smoke,
                                width: 1,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                'CANCEL',
                                style: GriboulTheme.button.copyWith(
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: GriboulTheme.space2),
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            HapticFeedback.mediumImpact();
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
                            padding: const EdgeInsets.symmetric(
                              vertical: GriboulTheme.space2,
                            ),
                            color: GriboulTheme.paper,
                            child: Center(
                              child: Text(
                                'SIGN OUT',
                                style: GriboulTheme.button.copyWith(
                                  color: GriboulTheme.ink,
                                  letterSpacing: 1.5,
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
      backgroundColor: GriboulTheme.ink,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(GriboulTheme.space3),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Navigator.pop(context);
                    },
                    child: Icon(
                      Icons.arrow_back,
                      color: GriboulTheme.paper,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: GriboulTheme.space2),
                  Text('Preferences', style: GriboulTheme.headline2),
                ],
              ),
            ),

            GriboulTheme.divider(),

            // Settings list
            Expanded(
              child: ListView(
                children: [
                  // Notifications section
                  _buildSectionHeader('NOTIFICATIONS'),
                  _buildToggleItem(
                    'Daily Recording Reminder',
                    'Get notified to share your daily update',
                    _dailyReminders,
                    (value) => setState(() => _dailyReminders = value),
                  ),
                  _buildToggleItem(
                    'Messages',
                    'New messages from fellow builders',
                    _messageNotifications,
                    (value) => setState(() => _messageNotifications = value),
                  ),
                  _buildToggleItem(
                    'Weekly Digest',
                    'Curated updates from the community',
                    _emailUpdates,
                    (value) => setState(() => _emailUpdates = value),
                  ),

                  const SizedBox(height: GriboulTheme.space4),

                  // Privacy section
                  _buildSectionHeader('PRIVACY'),
                  _buildListItem(
                    'Video Visibility',
                    'Control who can see your updates',
                    () {},
                  ),
                  _buildListItem(
                    'Blocked Accounts',
                    'Manage blocked builders',
                    () {},
                  ),

                  const SizedBox(height: GriboulTheme.space4),

                  // About section
                  _buildSectionHeader('ABOUT GRIBOUL'),
                  _buildListItem('Terms of Service', null, () {}),
                  _buildListItem('Privacy Policy', null, () {}),
                  _buildListItem('Version', '1.0.0', null, showArrow: false),

                  const SizedBox(height: GriboulTheme.space4),

                  // Account section
                  _buildSectionHeader('ACCOUNT'),
                  _buildListItem(
                    'Delete Account',
                    'Permanently remove your data',
                    () {},
                    isDestructive: true,
                  ),

                  const SizedBox(height: GriboulTheme.space4),

                  // Sign out button
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: GriboulTheme.space3,
                    ),
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.mediumImpact();
                        _showSignOutDialog();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: GriboulTheme.space2,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: GriboulTheme.smoke,
                            width: 1,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'SIGN OUT',
                            style: GriboulTheme.button.copyWith(
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: GriboulTheme.space10),
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
      padding: const EdgeInsets.fromLTRB(
        GriboulTheme.space3,
        GriboulTheme.space3,
        GriboulTheme.space3,
        GriboulTheme.space2,
      ),
      child: Text(
        title,
        style: GriboulTheme.overline.copyWith(
          color: GriboulTheme.ash,
          letterSpacing: 2.0,
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
      padding: const EdgeInsets.symmetric(
        horizontal: GriboulTheme.space3,
        vertical: GriboulTheme.space2,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: GriboulTheme.smoke, width: 0.5),
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
                  style: GriboulTheme.body1.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GriboulTheme.caption.copyWith(
                      fontFamily: 'Georgia',
                      color: GriboulTheme.ash,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Transform.scale(
            scale: 0.8,
            child: CupertinoSwitch(
              value: value,
              onChanged: (newValue) {
                HapticFeedback.lightImpact();
                onChanged(newValue);
              },
              activeColor: GriboulTheme.paper,
              trackColor: GriboulTheme.charcoal,
              thumbColor: value ? GriboulTheme.ink : GriboulTheme.ash,
            ),
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
      onTap:
          onTap != null
              ? () {
                HapticFeedback.lightImpact();
                onTap();
              }
              : null,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: GriboulTheme.space3,
          vertical: GriboulTheme.space2,
        ),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: GriboulTheme.smoke, width: 0.5),
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
                    style: GriboulTheme.body1.copyWith(
                      fontWeight: FontWeight.w500,
                      color:
                          isDestructive
                              ? GriboulTheme.recordRed
                              : GriboulTheme.paper,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: GriboulTheme.caption.copyWith(
                        fontFamily: subtitle == '1.0.0' ? 'Courier' : 'Georgia',
                        color: GriboulTheme.ash,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (showArrow)
              Icon(Icons.chevron_right, color: GriboulTheme.ash, size: 20),
          ],
        ),
      ),
    );
  }
}
