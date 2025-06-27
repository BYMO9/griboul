import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/griboul_theme.dart';
import '../widgets/circular_video_widget.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  final List<Map<String, dynamic>> _conversations = const [
    {
      'id': '1',
      'name': 'Sarah Chen',
      'lastMessage': 'Thanks for the AWS tips! Finally got it working',
      'time': '2 MIN AGO',
      'unread': true,
      'hasVideo': false,
      'building': 'AI Climate Dashboard',
    },
    {
      'id': '2',
      'name': 'Marcus Rodriguez',
      'lastMessage': 'Sent a video response',
      'time': '1 HOUR AGO',
      'unread': false,
      'hasVideo': true,
      'videoDuration': '2:18',
      'building': 'B2B SaaS Platform',
    },
    {
      'id': '3',
      'name': 'Amara Okafor',
      'lastMessage': 'Same struggle here. Want to connect on a call?',
      'time': 'YESTERDAY',
      'unread': false,
      'hasVideo': false,
      'building': 'EdTech for Africa',
    },
    {
      'id': '4',
      'name': 'David Kim',
      'lastMessage': 'Just shipped v2! Check out the demo',
      'time': '3 DAYS AGO',
      'unread': false,
      'hasVideo': false,
      'building': 'Open Source Tools',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GriboulTheme.ink,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(GriboulTheme.space3),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Correspondence',
                        style: GriboulTheme.headline1.copyWith(fontSize: 32),
                      ),
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          // New message
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
                            Icons.edit_outlined,
                            color: GriboulTheme.paper,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: GriboulTheme.space1),
                  Text(
                    'BUILDER TO BUILDER',
                    style: GriboulTheme.overline.copyWith(
                      color: GriboulTheme.ash,
                      letterSpacing: 2.0,
                    ),
                  ),
                ],
              ),
            ),

            GriboulTheme.divider(),

            // Conversations list
            Expanded(
              child:
                  _conversations.isEmpty
                      ? _buildEmptyState()
                      : ListView.separated(
                        itemCount: _conversations.length,
                        separatorBuilder:
                            (context, index) => GriboulTheme.divider(
                              indent:
                                  GriboulTheme.space3 + 72, // Align with text
                            ),
                        itemBuilder: (context, index) {
                          final conversation = _conversations[index];
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
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              border: Border.all(color: GriboulTheme.smoke, width: 2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.message_outlined,
              color: GriboulTheme.ash,
              size: 48,
            ),
          ),
          const SizedBox(height: GriboulTheme.space3),
          Text(
            'NO MESSAGES YET',
            style: GriboulTheme.overline.copyWith(
              color: GriboulTheme.ash,
              letterSpacing: 2.0,
            ),
          ),
          const SizedBox(height: GriboulTheme.space1),
          Text(
            'Start a conversation with fellow builders',
            style: GriboulTheme.body2.copyWith(
              fontFamily: 'Georgia',
              color: GriboulTheme.mist,
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
        HapticFeedback.lightImpact();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => ChatDetailScreen(
                  name: conversation['name'],
                  building: conversation['building'],
                ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(GriboulTheme.space3),
        color: GriboulTheme.ink,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar/Video thumbnail
            if (conversation['hasVideo'] == true)
              CircularVideoWidget(
                size: 56,
                thumbnailUrl: 'https://via.placeholder.com/56',
                duration: conversation['videoDuration'],
                showPlayButton: true,
              )
            else
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color:
                      conversation['unread'] == true
                          ? GriboulTheme.linkBlue.withOpacity(0.1)
                          : GriboulTheme.charcoal,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color:
                        conversation['unread'] == true
                            ? GriboulTheme.linkBlue
                            : GriboulTheme.smoke,
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    conversation['name'].split(' ').map((n) => n[0]).join(),
                    style: GriboulTheme.body1.copyWith(
                      fontWeight: FontWeight.w600,
                      color:
                          conversation['unread'] == true
                              ? GriboulTheme.linkBlue
                              : GriboulTheme.paper,
                    ),
                  ),
                ),
              ),

            const SizedBox(width: GriboulTheme.space2),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name and time
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          conversation['name'],
                          style: GriboulTheme.body1.copyWith(
                            fontWeight:
                                conversation['unread'] == true
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                          ),
                        ),
                      ),
                      Text(
                        conversation['time'],
                        style: GriboulTheme.overline.copyWith(
                          color:
                              conversation['unread'] == true
                                  ? GriboulTheme.paper
                                  : GriboulTheme.ash,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 2),

                  // Building what
                  Text(
                    conversation['building'],
                    style: GriboulTheme.caption.copyWith(
                      color: GriboulTheme.ash,
                    ),
                  ),

                  const SizedBox(height: GriboulTheme.space1),

                  // Last message
                  Row(
                    children: [
                      if (conversation['hasVideo'] == true) ...[
                        Icon(
                          Icons.videocam,
                          color: GriboulTheme.mist,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                      ],
                      Expanded(
                        child: Text(
                          conversation['lastMessage'],
                          style: GriboulTheme.body2.copyWith(
                            fontFamily: 'Georgia',
                            color:
                                conversation['unread'] == true
                                    ? GriboulTheme.paper
                                    : GriboulTheme.mist,
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
                margin: const EdgeInsets.only(
                  left: GriboulTheme.space2,
                  top: GriboulTheme.space2,
                ),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: GriboulTheme.linkBlue,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// Chat detail screen stub
class ChatDetailScreen extends StatelessWidget {
  final String name;
  final String building;

  const ChatDetailScreen({
    super.key,
    required this.name,
    required this.building,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GriboulTheme.ink,
      appBar: AppBar(
        backgroundColor: GriboulTheme.ink,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name, style: GriboulTheme.body1),
            Text(
              building,
              style: GriboulTheme.caption.copyWith(color: GriboulTheme.ash),
            ),
          ],
        ),
      ),
      body: const Center(child: Text('Chat detail implementation')),
    );
  }
}
