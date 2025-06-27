import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../utils/griboul_theme.dart';
import '../widgets/circular_video_widget.dart';
import '../providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    final profile = authProvider.userProfile ?? {};

    return Scaffold(
      backgroundColor: GriboulTheme.ink,
      body: CustomScrollView(
        slivers: [
          // Header
          SliverToBoxAdapter(
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  // Top bar
                  Container(
                    padding: const EdgeInsets.all(GriboulTheme.space3),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Builder Profile', style: GriboulTheme.headline2),
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            Navigator.pushNamed(context, '/settings');
                          },
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: GriboulTheme.smoke,
                                width: 1,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.settings_outlined,
                              color: GriboulTheme.paper,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  GriboulTheme.divider(),

                  // Profile header
                  Padding(
                    padding: const EdgeInsets.all(GriboulTheme.space3),
                    child: Column(
                      children: [
                        // Avatar
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: GriboulTheme.charcoal,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: GriboulTheme.smoke,
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              (profile['name'] ?? user?.displayName ?? 'U')
                                  .substring(0, 1)
                                  .toUpperCase(),
                              style: GriboulTheme.display.copyWith(
                                fontSize: 48,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: GriboulTheme.space3),

                        // Name
                        Text(
                          profile['name'] ??
                              user?.displayName ??
                              'Unknown Builder',
                          style: GriboulTheme.headline1.copyWith(fontSize: 32),
                        ),

                        const SizedBox(height: GriboulTheme.space1),

                        // Location and age
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              (profile['location'] ?? 'Earth').toUpperCase(),
                              style: GriboulTheme.overline.copyWith(
                                color: GriboulTheme.ash,
                                letterSpacing: 2.0,
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: GriboulTheme.space2,
                              ),
                              width: 3,
                              height: 3,
                              decoration: BoxDecoration(
                                color: GriboulTheme.ash,
                                shape: BoxShape.circle,
                              ),
                            ),
                            Text(
                              '${profile['age'] ?? '∞'} YEARS OLD',
                              style: GriboulTheme.overline.copyWith(
                                color: GriboulTheme.ash,
                                letterSpacing: 2.0,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: GriboulTheme.space3),

                        // What building - Editorial style
                        Container(
                          padding: const EdgeInsets.all(GriboulTheme.space3),
                          margin: const EdgeInsets.symmetric(
                            horizontal: GriboulTheme.space3,
                          ),
                          decoration: BoxDecoration(
                            color: GriboulTheme.charcoal,
                            borderRadius: BorderRadius.circular(
                              GriboulTheme.radiusMedium,
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(
                                'BUILDING',
                                style: GriboulTheme.overline.copyWith(
                                  color: GriboulTheme.ash,
                                  letterSpacing: 2.0,
                                ),
                              ),
                              const SizedBox(height: GriboulTheme.space1),
                              Text(
                                profile['building'] ?? 'Something amazing',
                                style: GriboulTheme.body1.copyWith(
                                  fontFamily: 'Georgia',
                                  fontSize: 18,
                                  height: 1.5,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Stats row
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: GriboulTheme.space3,
                    ),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(color: GriboulTheme.smoke),
                        bottom: BorderSide(color: GriboulTheme.smoke),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(child: _buildStat('VIDEOS', '12')),
                        Container(
                          width: 1,
                          height: 40,
                          color: GriboulTheme.smoke,
                        ),
                        Expanded(child: _buildStat('VIEWS', '1.2K')),
                        Container(
                          width: 1,
                          height: 40,
                          color: GriboulTheme.smoke,
                        ),
                        Expanded(child: _buildStat('CONNECTIONS', '48')),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Section header
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(GriboulTheme.space3),
              child: Row(
                children: [
                  Text(
                    'YOUR JOURNEY',
                    style: GriboulTheme.overline.copyWith(
                      color: GriboulTheme.ash,
                      letterSpacing: 2.0,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      // Toggle view
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: GriboulTheme.space2,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: GriboulTheme.smoke, width: 1),
                        borderRadius: BorderRadius.circular(
                          GriboulTheme.radiusSmall,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.lock_outline,
                            size: 14,
                            color: GriboulTheme.ash,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'PRIVATE (3)',
                            style: GriboulTheme.overline.copyWith(
                              fontSize: 10,
                              color: GriboulTheme.ash,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Video grid
          SliverPadding(
            padding: const EdgeInsets.symmetric(
              horizontal: GriboulTheme.space3,
            ),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 2,
                mainAxisSpacing: 2,
                childAspectRatio: 1,
              ),
              delegate: SliverChildBuilderDelegate((context, index) {
                return _buildVideoThumbnail(index);
              }, childCount: 9),
            ),
          ),

          // Bottom padding
          const SliverToBoxAdapter(
            child: SizedBox(height: GriboulTheme.space10),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: GriboulTheme.headline2.copyWith(fontFamily: 'Georgia'),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GriboulTheme.overline.copyWith(
            color: GriboulTheme.ash,
            fontSize: 10,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildVideoThumbnail(int index) {
    final durations = [
      '2:34',
      '1:45',
      '3:12',
      '4:01',
      '2:56',
      '1:23',
      '3:45',
      '2:18',
      '5:00',
    ];
    final statuses = [
      CircularVideoStatus.lateNight,
      CircularVideoStatus.debugging,
      CircularVideoStatus.celebrating,
      null,
      CircularVideoStatus.struggling,
      null,
      CircularVideoStatus.building,
      null,
      CircularVideoStatus.lateNight,
    ];

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        // Navigate to video
      },
      child: Container(
        decoration: BoxDecoration(
          color: GriboulTheme.charcoal,
          borderRadius: BorderRadius.circular(GriboulTheme.radiusSmall),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Placeholder for video thumbnail
            Center(
              child: Icon(
                Icons.play_circle_outline,
                color: GriboulTheme.ash,
                size: 32,
              ),
            ),

            // Duration
            Positioned(
              bottom: 4,
              right: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: GriboulTheme.ink.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(GriboulTheme.radiusSmall),
                ),
                child: Text(
                  durations[index],
                  style: GriboulTheme.mono.copyWith(
                    fontSize: 10,
                    color: GriboulTheme.paper,
                  ),
                ),
              ),
            ),

            // Status badge if applicable
            if (statuses[index] != null)
              Positioned(
                top: 4,
                left: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: GriboulTheme.ink.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(
                      GriboulTheme.radiusSmall,
                    ),
                  ),
                  child: Text(
                    statuses[index]!.label,
                    style: GriboulTheme.overline.copyWith(
                      fontSize: 8,
                      color: statuses[index]!.color,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
