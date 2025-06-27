import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../constants/colors.dart';
import '../constants/fonts.dart';

class UserAvatarWidget extends StatelessWidget {
  final String? imageUrl;
  final String name;
  final double size;
  final bool showBorder;
  final Color? borderColor;
  final bool isOnline;
  final Color? backgroundColor;

  const UserAvatarWidget({
    super.key,
    this.imageUrl,
    required this.name,
    this.size = 48,
    this.showBorder = false,
    this.borderColor,
    this.isOnline = false,
    this.backgroundColor,
  });

  String get _initials {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return 'U';

    if (parts.length == 1) {
      return parts[0].substring(0, 1).toUpperCase();
    } else {
      return '${parts[0].substring(0, 1)}${parts[parts.length - 1].substring(0, 1)}'
          .toUpperCase();
    }
  }

  Color get _avatarColor {
    if (backgroundColor != null) return backgroundColor!;

    // Generate consistent color based on name
    final hash = name.hashCode;
    final colors = [
      AppColors.accentBlue,
      AppColors.accentGreen,
      AppColors.accentRed,
      AppColors.textSecondary,
    ];
    return colors[hash.abs() % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border:
                showBorder
                    ? Border.all(
                      color:
                          borderColor ?? AppColors.textPrimary.withOpacity(0.2),
                      width: 2,
                    )
                    : null,
          ),
          child: ClipOval(
            child:
                imageUrl != null && imageUrl!.isNotEmpty
                    ? CachedNetworkImage(
                      imageUrl: imageUrl!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => _buildInitialsAvatar(),
                      errorWidget:
                          (context, url, error) => _buildInitialsAvatar(),
                    )
                    : _buildInitialsAvatar(),
          ),
        ),

        // Online indicator
        if (isOnline)
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: size * 0.3,
              height: size * 0.3,
              decoration: BoxDecoration(
                color: AppColors.accentGreen,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primaryBlack, width: 2),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInitialsAvatar() {
    return Container(
      color: _avatarColor.withOpacity(0.2),
      child: Center(
        child: Text(
          _initials,
          style: TextStyle(
            fontFamily: 'Georgia',
            fontSize: size * 0.4,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
