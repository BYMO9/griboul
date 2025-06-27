import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/colors.dart';
import '../constants/fonts.dart';
import '../constants/sizes.dart';

class ChatDetailScreen extends StatefulWidget {
  const ChatDetailScreen({super.key});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _messages = [
    {
      'id': '1',
      'text':
          'Hey! Saw your video about the AWS struggles. I went through the same thing last month.',
      'isMe': false,
      'time': '2:30 PM',
      'type': 'text',
    },
    {
      'id': '2',
      'text': 'Thanks! Yeah it\'s been a nightmare. How did you solve it?',
      'isMe': true,
      'time': '2:32 PM',
      'type': 'text',
    },
    {
      'id': '3',
      'text': 'Let me show you what worked for me',
      'isMe': false,
      'time': '2:33 PM',
      'type': 'text',
    },
    {
      'id': '4',
      'duration': '1:24',
      'isMe': false,
      'time': '2:33 PM',
      'type': 'video',
    },
    {
      'id': '5',
      'text':
          'This is brilliant! Finally got it working. Really appreciate the help 🙏',
      'isMe': true,
      'time': '3:15 PM',
      'type': 'text',
    },
  ];

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    setState(() {
      _messages.add({
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'text': _messageController.text,
        'isMe': true,
        'time': 'Now',
        'type': 'text',
      });
    });

    _messageController.clear();
    _scrollToBottom();
    HapticFeedback.lightImpact();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final userData =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final userName = userData?['name'] ?? 'Unknown';
    final userAvatar = userData?['avatar'] ?? 'U';

    return Scaffold(
      backgroundColor: AppColors.primaryBlack,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: AppColors.textPrimary.withOpacity(0.2),
                    width: 0.5,
                  ),
                ),
              ),
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
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceBlack,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        userAvatar,
                        style: const TextStyle(
                          fontFamily: 'Georgia',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userName,
                          style: const TextStyle(
                            fontFamily: 'Helvetica',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          'Active now',
                          style: TextStyle(
                            fontFamily: 'Helvetica',
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
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
                      Icons.videocam_outlined,
                      color: AppColors.textPrimary,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),

            // Messages
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(20),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  return _buildMessage(message);
                },
              ),
            ),

            // Input area
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: AppColors.textPrimary.withOpacity(0.2),
                    width: 0.5,
                  ),
                ),
              ),
              child: Row(
                children: [
                  // Video message button
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      // Open video recording
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceBlack,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.videocam,
                        color: AppColors.textPrimary,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Text input
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.surfaceBlack,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: _messageController,
                        style: const TextStyle(
                          fontFamily: 'Georgia',
                          fontSize: 16,
                          color: AppColors.textPrimary,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Type a message...',
                          hintStyle: TextStyle(
                            fontFamily: 'Georgia',
                            fontSize: 16,
                            color: AppColors.textTertiary,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Send button
                  GestureDetector(
                    onTap: _sendMessage,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: AppColors.accentBlue,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.send,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessage(Map<String, dynamic> message) {
    final bool isMe = message['isMe'] ?? false;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.surfaceBlack,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  'S',
                  style: const TextStyle(
                    fontFamily: 'Georgia',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],

          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              padding:
                  message['type'] == 'video'
                      ? EdgeInsets.zero
                      : const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
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
              child:
                  message['type'] == 'video'
                      ? _buildVideoMessage(message)
                      : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            message['text'],
                            style: TextStyle(
                              fontFamily: 'Georgia',
                              fontSize: 16,
                              color: AppColors.textPrimary,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            message['time'],
                            style: TextStyle(
                              fontFamily: 'Helvetica',
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
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

  Widget _buildVideoMessage(Map<String, dynamic> message) {
    return GestureDetector(
      onTap: () {
        // Play video
      },
      child: Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          color: AppColors.surfaceBlack,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Icon(
              Icons.play_circle_filled,
              color: AppColors.textPrimary,
              size: 48,
            ),
            Positioned(
              bottom: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlack.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.videocam,
                      color: AppColors.textPrimary,
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      message['duration'],
                      style: const TextStyle(
                        fontFamily: 'Helvetica',
                        fontSize: 11,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
