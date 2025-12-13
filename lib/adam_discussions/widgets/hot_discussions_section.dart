import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

import 'package:arena_invicta_mobile/global/widgets/app_colors.dart';
import 'package:arena_invicta_mobile/global/environments.dart';
import 'package:arena_invicta_mobile/adam_discussions/models/discussion_models.dart';
import 'package:arena_invicta_mobile/adam_discussions/screens/discussion_detail_page.dart';

class HotDiscussionsSection extends StatefulWidget {
  const HotDiscussionsSection({super.key});

  @override
  State<HotDiscussionsSection> createState() => _HotDiscussionsSectionState();
}

class _HotDiscussionsSectionState extends State<HotDiscussionsSection> {
  List<DiscussionThread> _threads = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchThreads();
  }

  Future<void> _fetchThreads() async {
    final request = context.read<CookieRequest>();
    try {
      final response = await request.get('$baseUrl/discussions/api/threads/');
      final rawThreads = (response['threads'] as List<dynamic>? ?? []);
      final threads = rawThreads
          .map((json) => DiscussionThread.fromJson(json as Map<String, dynamic>))
          .toList();
      
      // Sort by upvote count and take top 3
      threads.sort((a, b) => b.upvoteCount.compareTo(a.upvoteCount));
      
      if (mounted) {
        setState(() {
          _threads = threads.take(3).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: ArenaColor.dragonFruit,
            ),
          ),
        ),
      );
    }

    if (_threads.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Text(
          'No discussions yet',
          style: TextStyle(color: Colors.white.withOpacity(0.6)),
        ),
      );
    }

    return Column(
      children: _threads.map((thread) => _HotDiscussionCard(thread: thread)).toList(),
    );
  }
}

class _HotDiscussionCard extends StatelessWidget {
  const _HotDiscussionCard({required this.thread});

  final DiscussionThread thread;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => DiscussionDetailPage(thread: thread)),
        );
      },
      child: Container(
        margin: const EdgeInsets.fromLTRB(24, 0, 24, 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: ArenaColor.darkAmethystLight.withOpacity(0.3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            // Avatar with initial
            Container(
              width: 50,
              height: 50,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF9333EA), Color(0xFF4F46E5)],
                ),
              ),
              child: Text(
                thread.authorDisplay.isNotEmpty
                    ? thread.authorDisplay[0].toUpperCase()
                    : '?',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
            const SizedBox(width: 12),
            
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    thread.title,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (thread.newsTitle != null) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: ArenaColor.dragonFruit.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'News',
                            style: TextStyle(
                              color: ArenaColor.dragonFruit,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Icon(Icons.mode_comment_outlined, size: 12, color: Colors.white.withOpacity(0.5)),
                      const SizedBox(width: 4),
                      Text(
                        '${thread.commentCount}',
                        style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(width: 8),
            
            // Upvote count
            Column(
              children: [
                const Icon(Icons.keyboard_arrow_up_rounded, color: ArenaColor.dragonFruit, size: 22),
                Text(
                  formatCount(thread.upvoteCount),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
