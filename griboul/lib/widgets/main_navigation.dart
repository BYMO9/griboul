import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import '../utils/griboul_theme.dart';
import '../screens/feed_screen.dart';
import '../screens/search_screen.dart';
import '../screens/record_screen.dart';
import '../screens/messages_screen.dart';
import '../screens/profile_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const FeedScreen(),
    const SearchScreen(),
    const MessagesScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    if (index == 2) {
      // Record button - opens as overlay
      _openRecordScreen();
      return;
    }

    // Adjust index for screens array (skip record button)
    int screenIndex = index > 2 ? index - 1 : index;

    setState(() {
      _currentIndex = screenIndex;
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
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
        fullscreenDialog: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GriboulTheme.ink,
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: GriboulTheme.smoke, width: 0.5),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Container(
            height: 60,
            color: GriboulTheme.ink,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildNavItem(
                  label: 'FEED',
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home,
                  index: 0,
                  isActive: _currentIndex == 0,
                ),
                _buildNavItem(
                  label: 'SEARCH',
                  icon: Icons.search_outlined,
                  activeIcon: Icons.search,
                  index: 1,
                  isActive: _currentIndex == 1,
                ),
                _buildRecordButton(),
                _buildNavItem(
                  label: 'INBOX',
                  icon: Icons.message_outlined,
                  activeIcon: Icons.message,
                  index: 3,
                  isActive: _currentIndex == 2,
                ),
                _buildNavItem(
                  label: 'YOU',
                  icon: Icons.person_outline,
                  activeIcon: Icons.person,
                  index: 4,
                  isActive: _currentIndex == 3,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required String label,
    required IconData icon,
    required IconData activeIcon,
    required int index,
    required bool isActive,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _onItemTapped(index),
        behavior: HitTestBehavior.opaque,
        child: Container(
          color: Colors.transparent,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isActive ? activeIcon : icon,
                color: isActive ? GriboulTheme.paper : GriboulTheme.ash,
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: GriboulTheme.overline.copyWith(
                  fontSize: 9,
                  letterSpacing: 1.0,
                  color: isActive ? GriboulTheme.paper : GriboulTheme.ash,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecordButton() {
    return Expanded(
      child: GestureDetector(
        onTap: () => _onItemTapped(2),
        behavior: HitTestBehavior.opaque,
        child: Container(
          color: Colors.transparent,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: GriboulTheme.recordRed,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.add, color: GriboulTheme.paper, size: 20),
              ),
              const SizedBox(height: 2),
              Text(
                'RECORD',
                style: GriboulTheme.overline.copyWith(
                  fontSize: 9,
                  letterSpacing: 1.0,
                  color: GriboulTheme.recordRed,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Alternative cleaner navigation without labels
class MinimalMainNavigation extends StatefulWidget {
  const MinimalMainNavigation({super.key});

  @override
  State<MinimalMainNavigation> createState() => _MinimalMainNavigationState();
}

class _MinimalMainNavigationState extends State<MinimalMainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const FeedScreen(),
    const SearchScreen(),
    const MessagesScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    if (index == 2) {
      _openRecordScreen();
      return;
    }

    int screenIndex = index > 2 ? index - 1 : index;

    setState(() {
      _currentIndex = screenIndex;
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
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
        fullscreenDialog: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GriboulTheme.ink,
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: GriboulTheme.ink,
          border: Border(
            top: BorderSide(color: GriboulTheme.smoke, width: 0.5),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Container(
            height: 56,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildMinimalNavItem(
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home,
                  index: 0,
                  isActive: _currentIndex == 0,
                ),
                _buildMinimalNavItem(
                  icon: Icons.search,
                  activeIcon: Icons.search,
                  index: 1,
                  isActive: _currentIndex == 1,
                ),
                _buildMinimalRecordButton(),
                _buildMinimalNavItem(
                  icon: Icons.chat_bubble_outline,
                  activeIcon: Icons.chat_bubble,
                  index: 3,
                  isActive: _currentIndex == 2,
                ),
                _buildMinimalNavItem(
                  icon: Icons.person_outline,
                  activeIcon: Icons.person,
                  index: 4,
                  isActive: _currentIndex == 3,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMinimalNavItem({
    required IconData icon,
    required IconData activeIcon,
    required int index,
    required bool isActive,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _onItemTapped(index),
        behavior: HitTestBehavior.opaque,
        child: Container(
          color: Colors.transparent,
          child: Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color:
                    isActive
                        ? GriboulTheme.paper.withOpacity(0.1)
                        : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                isActive ? activeIcon : icon,
                color: isActive ? GriboulTheme.paper : GriboulTheme.ash,
                size: isActive ? 26 : 24,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMinimalRecordButton() {
    return Expanded(
      child: GestureDetector(
        onTap: () => _onItemTapped(2),
        behavior: HitTestBehavior.opaque,
        child: Container(
          color: Colors.transparent,
          child: Center(
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: GriboulTheme.recordRed,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: GriboulTheme.recordRed.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(Icons.videocam, color: GriboulTheme.paper, size: 22),
            ),
          ),
        ),
      ),
    );
  }
}

/// Tab-style navigation (NYT inspired)
class TabStyleMainNavigation extends StatefulWidget {
  const TabStyleMainNavigation({super.key});

  @override
  State<TabStyleMainNavigation> createState() => _TabStyleMainNavigationState();
}

class _TabStyleMainNavigationState extends State<TabStyleMainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const FeedScreen(),
    const SearchScreen(),
    const MessagesScreen(),
    const ProfileScreen(),
  ];

  final List<String> _titles = ['Griboul', 'Search', 'Messages', 'Profile'];

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
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
        fullscreenDialog: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GriboulTheme.ink,
      body: SafeArea(
        child: Column(
          children: [
            // Top navigation bar
            Container(
              height: 56,
              padding: const EdgeInsets.symmetric(
                horizontal: GriboulTheme.space3,
              ),
              child: Row(
                children: [
                  // Title
                  Text(_titles[_currentIndex], style: GriboulTheme.headline2),
                  const Spacer(),
                  // Record button
                  GestureDetector(
                    onTap: _openRecordScreen,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: GriboulTheme.space2,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: GriboulTheme.recordRed,
                        borderRadius: BorderRadius.circular(
                          GriboulTheme.radiusCircle,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.add, color: GriboulTheme.paper, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            'RECORD',
                            style: GriboulTheme.overline.copyWith(
                              color: GriboulTheme.paper,
                              fontSize: 11,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Tab bar
            Container(
              height: 44,
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: GriboulTheme.smoke, width: 0.5),
                  bottom: BorderSide(color: GriboulTheme.smoke, width: 0.5),
                ),
              ),
              child: Row(
                children: [
                  _buildTab('FEED', 0),
                  _buildTab('SEARCH', 1),
                  _buildTab('INBOX', 2),
                  _buildTab('YOU', 3),
                ],
              ),
            ),

            // Content
            Expanded(
              child: IndexedStack(index: _currentIndex, children: _screens),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String label, int index) {
    final isActive = _currentIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => _onItemTapped(index),
        behavior: HitTestBehavior.opaque,
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isActive ? GriboulTheme.paper : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: GriboulTheme.overline.copyWith(
                color: isActive ? GriboulTheme.paper : GriboulTheme.ash,
                letterSpacing: 1.5,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
