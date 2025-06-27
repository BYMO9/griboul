import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import '../constants/colors.dart';
import '../constants/sizes.dart';
import '../screens/feed_screen.dart';
import '../screens/record_screen.dart';
import '../screens/messages_screen.dart';
import '../screens/profile_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _recordButtonController;
  late Animation<double> _recordButtonAnimation;

  final List<Widget> _screens = [
    const FeedScreen(),
    const MessagesScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _recordButtonController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _recordButtonAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _recordButtonController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _recordButtonController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    HapticFeedback.lightImpact();
  }

  void _openRecordScreen() {
    HapticFeedback.heavyImpact();
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder:
            (context, animation, secondaryAnimation) => const RecordScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
              ),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
        fullscreenDialog: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Container(
        height: 100,
        child: Stack(
          children: [
            // Blurred background
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    height: 84,
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlack.withOpacity(0.8),
                      border: Border(
                        top: BorderSide(
                          color: AppColors.textPrimary.withOpacity(0.1),
                          width: 0.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Navigation items
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                top: false,
                child: Container(
                  height: 84,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Home
                      _buildNavItem(
                        icon: Icons.home_outlined,
                        activeIcon: Icons.home,
                        label: 'HOME',
                        index: 0,
                      ),

                      // Spacer for record button
                      const SizedBox(width: 60),

                      // Messages
                      _buildNavItem(
                        icon: Icons.message_outlined,
                        activeIcon: Icons.message,
                        label: 'MESSAGES',
                        index: 1,
                      ),

                      // Builder
                      _buildNavItem(
                        icon: Icons.account_circle_outlined,
                        activeIcon: Icons.account_circle,
                        label: 'BUILDER',
                        index: 2,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Floating record button
            Positioned(
              bottom: 25,
              left: MediaQuery.of(context).size.width / 2 - 35,
              child: GestureDetector(
                onTap: _openRecordScreen,
                child: AnimatedBuilder(
                  animation: _recordButtonAnimation,
                  builder: (context, child) {
                    return Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            AppColors.recordRed,
                            AppColors.recordRed.withOpacity(0.8),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.recordRed.withOpacity(
                              0.3 + (_recordButtonAnimation.value * 0.2),
                            ),
                            blurRadius:
                                20 + (_recordButtonAnimation.value * 10),
                            spreadRadius:
                                2 + (_recordButtonAnimation.value * 3),
                          ),
                          BoxShadow(
                            color: AppColors.primaryBlack.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Pulse ring
                          Container(
                            width: 70 + (_recordButtonAnimation.value * 10),
                            height: 70 + (_recordButtonAnimation.value * 10),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.recordRed.withOpacity(
                                  0.3 - (_recordButtonAnimation.value * 0.3),
                                ),
                                width: 2,
                              ),
                            ),
                          ),
                          // Inner content
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppColors.recordRed.withOpacity(0.9),
                                  AppColors.recordRed,
                                ],
                              ),
                            ),
                            child: const Icon(
                              Icons.videocam,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
  }) {
    final isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () => _onItemTapped(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon with glow effect when selected
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color:
                    isSelected
                        ? AppColors.textPrimary.withOpacity(0.1)
                        : Colors.transparent,
              ),
              child: Icon(
                isSelected ? activeIcon : icon,
                color:
                    isSelected
                        ? AppColors.textPrimary
                        : AppColors.textSecondary.withOpacity(0.7),
                size: isSelected ? 26 : 24,
              ),
            ),
            const SizedBox(height: 4),
            // Label with better typography
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontFamily: 'Helvetica',
                fontSize: isSelected ? 11 : 10,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color:
                    isSelected
                        ? AppColors.textPrimary
                        : AppColors.textSecondary.withOpacity(0.7),
                letterSpacing: isSelected ? 1.2 : 1.0,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}
