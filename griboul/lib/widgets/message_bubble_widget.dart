import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../constants/fonts.dart';
import '../constants/sizes.dart';
import 'user_avatar_widget.dart';
import 'video_thumbnail_widget.dart';

enum MessageType { text, video, image }

class MessageBubbleWidget extends StatelessWidget {
  final String message;
  final MessageType type;
  final bool isMe;
  final String time;
  final String? senderName;
  final String? senderAvatar;
  final String? mediaUrl;
  final String? mediaDuration;
  final VoidCallback? onMediaTap;
  final bool showAvatar;

  const MessageBubbleWidget({
    super.key,
    required this.message,
    required this.type,
    required this.isMe,
    required this.time,
    this.senderName,
    this.senderAvatar,
    this.mediaUrl,
    this.mediaDuration,
    this.onMediaTap,
    this.showAvatar = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Avatar for other users
          if (!isMe && showAvatar) ...[
            UserAvatarWidget(
              name: senderName ?? 'User',
              size: 32,
              imageUrl: senderAvatar,
            ),
            const SizedBox(width: 8),
          ] else if (!isMe && !showAvatar) ...[
            const SizedBox(width: 40), // Space for avatar alignment
          ],

          // Message content
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              child: Column(
                crossAxisAlignment:
                    isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  // Sender name (for group chats)
                  if (!isMe && senderName != null && showAvatar) ...[
                    Padding(
                      padding: const EdgeInsets.only(left: 12, bottom: 4),
                      child: Text(
                        senderName!,
                        style: TextStyle(
                          fontFamily: 'Helvetica',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],

                  // Bubble
                  Container(
                    padding:
                        type == MessageType.text
                            ? const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            )
                            : EdgeInsets.zero,
                    decoration: BoxDecoration(
                      color:
                          isMe
                              ? AppColors.accentBlue.withOpacity(0.2)
                              : AppColors.surfaceBlack,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: Radius.circular(isMe ? 16 : 4),
                        bottomRight: Radius.circular(isMe ? 4 : 16),
                      ),
                    ),
                    child: _buildMessageContent(),
                  ),
                ],
              ),
            ),
          ),

          if (isMe) const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildMessageContent() {
    switch (type) {
      case MessageType.text:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message,
              style: TextStyle(
                fontFamily: 'Georgia',
                fontSize: 16,
                color: AppColors.textPrimary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              time,
              style: TextStyle(
                fontFamily: 'Helvetica',
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        );

      case MessageType.video:
        return ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              VideoThumbnailWidget(
                thumbnailUrl: mediaUrl,
                duration: mediaDuration ?? '0:00',
                width: 200,
                height: 200,
                onTap: onMediaTap,
                borderRadius: BorderRadius.zero,
              ),
              Positioned(
                bottom: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlack.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    time,
                    style: const TextStyle(
                      fontFamily: 'Helvetica',
                      fontSize: 11,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );

      case MessageType.image:
        return ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              Container(
                width: 200,
                height: 200,
                color: AppColors.surfaceBlack,
                child:
                    mediaUrl != null
                        ? Image.network(mediaUrl!, fit: BoxFit.cover)
                        : const Icon(
                          Icons.image,
                          color: AppColors.textTertiary,
                          size: 48,
                        ),
              ),
              Positioned(
                bottom: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlack.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    time,
                    style: const TextStyle(
                      fontFamily: 'Helvetica',
                      fontSize: 11,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
    }
  }
}
