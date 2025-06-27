import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../constants/fonts.dart';
import '../constants/sizes.dart';
import 'chat_detail_screen.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  final List<Map<String, dynamic>> _mockConversations = const [
    {
      'id': '1',
      'name': 'Sarah Chen',
      'lastMessage': 'Thanks for the AWS tips! Finally got it working',
      'time': '2m ago',
      'unread': true,
      'avatar': 'SC',
    },
    {
      'id': '2',
      'name': 'Marcus Rodriguez',
      'lastMessage': 'Video message',
      'time': '1h ago',
      'unread': false,
      'avatar': 'MR',
      'isVideo': true,
    },
    {
      'id': '3',
      'name': 'Amara Okafor',
      'lastMessage': 'Same struggle here. Want to connect?',
      'time': '3h ago',
      'unread': false,
      'avatar': 'AO',
    },
    {
      'id': '4',
      'name': 'David Kim',
      'lastMessage': 'Just shipped v2! Check it out',
      'time': 'Yesterday',
      'unread': false,
      'avatar': 'DK',
    },
  ];

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
                  Text(
                    'Messages',
                    style: TextStyle(
                      fontFamily: 'Georgia',
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  Container(
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
                      Icons.edit_outlined,
                      color: AppColors.textPrimary,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),

            Container(
              height: 0.5,
              color: AppColors.textPrimary.withOpacity(0.2),
            ),

            // Conversations list
            Expanded(
              child:
                  _mockConversations.isEmpty
                      ? _buildEmptyState()
                      : ListView.separated(
                        itemCount: _mockConversations.length,
                        separatorBuilder:
                            (context, index) => Container(
                              height: 0.5,
                              margin: const EdgeInsets.only(left: 80),
                              color: AppColors.textPrimary.withOpacity(0.1),
                            ),
                        itemBuilder: (context, index) {
                          final conversation = _mockConversations[index];
                          return _buildConversationItem(context, conversation);
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.textTertiary, width: 2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.chat_bubble_outline,
              color: AppColors.textTertiary,
              size: 40,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'NO MESSAGES YET',
            style: TextStyle(
              fontFamily: 'Helvetica',
              fontSize: 11,
              letterSpacing: 1.5,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Connect with other builders',
            style: TextStyle(
              fontFamily: 'Georgia',
              fontSize: 16,
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConversationItem(
    BuildContext context,
    Map<String, dynamic> conversation,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ChatDetailScreen(),
            settings: RouteSettings(
              arguments: {
                'name': conversation['name'],
                'avatar': conversation['avatar'],
              },
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        color: AppColors.primaryBlack,
        child: Row(
          children: [
            // Avatar
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color:
                    conversation['unread'] == true
                        ? AppColors.accentBlue
                        : AppColors.surfaceBlack,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  conversation['avatar'],
                  style: TextStyle(
                    fontFamily: 'Georgia',
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        conversation['name'],
                        style: TextStyle(
                          fontFamily: 'Helvetica',
                          fontSize: 16,
                          fontWeight:
                              conversation['unread'] == true
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        conversation['time'],
                        style: TextStyle(
                          fontFamily: 'Helvetica',
                          fontSize: 12,
                          color:
                              conversation['unread'] == true
                                  ? AppColors.textPrimary
                                  : AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (conversation['isVideo'] == true) ...[
                        Icon(
                          Icons.videocam,
                          color: AppColors.textSecondary,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                      ],
                      Expanded(
                        child: Text(
                          conversation['lastMessage'],
                          style: TextStyle(
                            fontFamily: 'Georgia',
                            fontSize: 15,
                            color:
                                conversation['unread'] == true
                                    ? AppColors.textPrimary
                                    : AppColors.textSecondary,
                            fontWeight:
                                conversation['unread'] == true
                                    ? FontWeight.w500
                                    : FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Unread indicator
            if (conversation['unread'] == true)
              Container(
                margin: const EdgeInsets.only(left: 8),
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.accentBlue,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
