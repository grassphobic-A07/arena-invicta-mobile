import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

import 'package:arena_invicta_mobile/global/widgets/app_colors.dart';
import 'package:arena_invicta_mobile/global/environments.dart';
import 'package:arena_invicta_mobile/adam_discussions/models/discussion_models.dart';
import 'package:arena_invicta_mobile/neal_auth/screens/login.dart';
import 'package:arena_invicta_mobile/main.dart';
import 'package:arena_invicta_mobile/rafa_news/models/news_entry.dart';
import 'package:arena_invicta_mobile/rafa_news/screens/news_detail_page.dart';

class DiscussionDetailPage extends StatefulWidget {
  const DiscussionDetailPage({super.key, required this.thread});

  final DiscussionThread thread;

  @override
  State<DiscussionDetailPage> createState() => _DiscussionDetailPageState();
}

class _DiscussionDetailPageState extends State<DiscussionDetailPage> {
  List<DiscussionComment> _comments = [];
  bool _isLoading = true;
  String? _error;
  bool _userHasUpvoted = false;
  int _upvoteCount = 0;
  int _viewsCount = 0;
  String? _currentUsername;
  final _commentController = TextEditingController();
  bool _isSubmittingComment = false;

  @override
  void initState() {
    super.initState();
    _upvoteCount = widget.thread.upvoteCount;
    _viewsCount = widget.thread.viewsCount + 1; // bump view locally on open
    _fetchDetail();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _fetchDetail() async {
    final request = context.read<CookieRequest>();
    try {
      final response = await request.get(
        '$baseUrl/discussions/api/threads/${widget.thread.id}/',
      );
      final commentsJson = response['comments'] as List<dynamic>? ?? [];
      setState(() {
        _comments = commentsJson
            .map((c) => DiscussionComment.fromJson(c as Map<String, dynamic>))
            .toList();
        _userHasUpvoted = response['thread']?['user_has_upvoted'] ?? false;
        _upvoteCount =
            response['thread']?['upvote_count'] ?? widget.thread.upvoteCount;
        _viewsCount = response['thread']?['views_count'] ?? _viewsCount;
        _currentUsername = response['current_username'] as String?;
        _isLoading = false;
        _error = null;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Gagal memuat detail: $e';
      });
    }
  }

  Future<void> _toggleUpvote() async {
    final user = context.read<UserProvider>();
    if (!user.isLoggedIn) {
      _showLoginPrompt();
      return;
    }

    // Optimistic UI update
    final previousUpvoted = _userHasUpvoted;
    final previousCount = _upvoteCount;
    setState(() {
      _userHasUpvoted = !_userHasUpvoted;
      _upvoteCount += _userHasUpvoted ? 1 : -1;
    });

    final request = context.read<CookieRequest>();
    try {
      final response = await request.post(
        '$baseUrl/discussions/api/threads/${widget.thread.id}/upvote/',
        {},
      );
      if (response['ok'] == true) {
        setState(() {
          _userHasUpvoted = response['state'] == 'added';
          _upvoteCount = response['upvote_count'] ?? _upvoteCount;
        });
      } else {
        // Revert on failure
        setState(() {
          _userHasUpvoted = previousUpvoted;
          _upvoteCount = previousCount;
        });
      }
    } catch (e) {
      // Revert on error
      setState(() {
        _userHasUpvoted = previousUpvoted;
        _upvoteCount = previousCount;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
            content: Text('Gagal memperbarui upvote: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  Future<void> _submitComment() async {
    final content = _commentController.text.trim();
    if (content.isEmpty) return;

    final user = context.read<UserProvider>();
    if (!user.isLoggedIn) {
      _showLoginPrompt();
      return;
    }

    setState(() => _isSubmittingComment = true);

    final request = context.read<CookieRequest>();
    try {
      final response = await request.postJson(
        '$baseUrl/discussions/api/threads/${widget.thread.id}/comments/',
        jsonEncode({'content': content}),
      );
      if (response['ok'] == true && mounted) {
        _commentController.clear();
        final newComment = DiscussionComment.fromJson(
          response['comment'] as Map<String, dynamic>,
        );
        setState(() {
          _comments.add(newComment);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.only(bottom: 16, left: 16, right: 16),
            content: Text('Komentar berhasil ditambahkan!'),
            backgroundColor: Colors.green,
          ),
        );
      } else if (mounted) {
        final msg = response['error'] ?? 'Gagal menambah komentar.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
            content: Text(msg),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
            content: Text('Error: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmittingComment = false);
    }
  }

  void _showLoginPrompt() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
        content: const Text('Silakan login terlebih dahulu.'),
        action: SnackBarAction(
          label: 'Login',
          textColor: Colors.white,
          onPressed: () => Navigator.pushNamed(context, LoginPage.routeName),
        ),
      ),
    );
  }

  Future<void> _editComment(DiscussionComment comment) async {
    final controller = TextEditingController(text: comment.content);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ArenaColor.darkAmethyst,
        title: const Text(
          'Edit Komentar',
          style: TextStyle(color: Colors.white),
        ),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Tulis komentar...',
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
            filled: true,
            fillColor: Colors.white.withOpacity(0.08),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Batal',
              style: TextStyle(color: Colors.white.withOpacity(0.7)),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: ArenaColor.dragonFruit,
            ),
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Simpan', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty && result != comment.content) {
      final request = context.read<CookieRequest>();
      try {
        final response = await request.postJson(
          '$baseUrl/discussions/api/comments/${comment.id}/',
          jsonEncode({'content': result}),
        );
        if (response['ok'] == true && mounted) {
          setState(() {
            final index = _comments.indexWhere((c) => c.id == comment.id);
            if (index != -1) {
              _comments[index] = DiscussionComment(
                id: comment.id,
                content: response['content'] ?? result,
                authorDisplay: comment.authorDisplay,
                authorUsername: comment.authorUsername,
                createdAt: comment.createdAt,
                parentId: comment.parentId,
              );
            }
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              behavior: SnackBarBehavior.floating,
              margin: EdgeInsets.only(bottom: 16, left: 16, right: 16),
              content: Text('Komentar berhasil diperbarui!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
              content: Text('Gagal mengedit komentar: $e'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    }
  }

  Future<void> _deleteComment(DiscussionComment comment) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ArenaColor.darkAmethyst,
        title: const Text(
          'Hapus Komentar',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Yakin ingin menghapus komentar ini?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Batal',
              style: TextStyle(color: Colors.white.withOpacity(0.7)),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final request = context.read<CookieRequest>();
      try {
        final response = await request.post(
          '$baseUrl/discussions/api/comments/${comment.id}/delete/',
          {},
        );
        if (response['ok'] == true && mounted) {
          setState(() {
            _comments.removeWhere((c) => c.id == comment.id);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              behavior: SnackBarBehavior.floating,
              margin: EdgeInsets.only(bottom: 16, left: 16, right: 16),
              content: Text('Komentar berhasil dihapus!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
              content: Text('Gagal menghapus komentar: $e'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    }
  }

  Future<void> _navigateToNews() async {
    final newsId = widget.thread.newsId;
    if (newsId == null) return;

    final request = context.read<CookieRequest>();
    try {
      // Fetch news data (no trailing slash)
      final response = await request.get('$baseUrl/news/$newsId/json-data');
      if (response != null && mounted) {
        final news = NewsEntry.fromJson(response);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => NewsDetailPage(news: news)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
            content: Text('Gagal memuat berita: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final thread = widget.thread;

    return Scaffold(
      backgroundColor: ArenaColor.darkAmethyst,
      body: Stack(
        children: [
          // Background gradients
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topLeft,
                  radius: 1.2,
                  colors: [Color(0xFF9333EA), Color(0xFF2A1B54)],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.bottomRight,
                  radius: 1.2,
                  colors: [Color(0xFF4A49A0), Color(0xFF2A1B54)],
                ),
              ),
            ),
          ),

          // Content
          Column(
            children: [
              // AppBar
              AppBar(
                title: const Text(
                  'Diskusi',
                  style: TextStyle(color: Colors.white),
                ),
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.white,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),

              // Main content
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: ArenaColor.purpleX11,
                        ),
                      )
                    : _error != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _error!,
                                style: const TextStyle(color: Colors.white70),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _fetchDetail,
                                child: const Text('Coba Lagi'),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                        children: [
                          // Thread content card
                          _buildThreadCard(thread),
                          const SizedBox(height: 20),

                          // Comments section
                          Text(
                            'Komentar (${_comments.length})',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),

                          if (_comments.isEmpty)
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Belum ada komentar. Jadilah yang pertama!',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.6),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            )
                          else
                            ..._comments.map((c) => _buildCommentCard(c)),
                        ],
                      ),
              ),

              // Comment input
              _buildCommentInput(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildThreadCard(DiscussionThread thread) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Author row
          Row(
            children: [
              Container(
                height: 44,
                width: 44,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
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
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      thread.authorDisplay,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      thread.relativeTime,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Title
          Text(
            thread.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          // Body
          if (thread.body != null && thread.body!.isNotEmpty)
            Text(
              thread.body!,
              style: TextStyle(
                color: Colors.white.withOpacity(0.85),
                fontSize: 14,
                height: 1.5,
              ),
            ),

          // Related news
          if (thread.newsTitle != null) ...[
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _navigateToNews,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white.withOpacity(0.06)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.newspaper,
                          color: ArenaColor.dragonFruit,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            thread.newsTitle!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              fontSize: 13,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Icon(
                          Icons.chevron_right_rounded,
                          color: Colors.white.withOpacity(0.4),
                          size: 20,
                        ),
                      ],
                    ),
                    if (thread.newsSummary != null &&
                        thread.newsSummary!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        thread.newsSummary!,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 12,
                          height: 1.4,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],

          const SizedBox(height: 16),
          const Divider(color: Colors.white12),
          const SizedBox(height: 12),

          // Stats row
          Row(
            children: [
              // Upvote button
              GestureDetector(
                onTap: _toggleUpvote,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _userHasUpvoted
                        ? ArenaColor.dragonFruit.withOpacity(0.2)
                        : Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _userHasUpvoted
                          ? ArenaColor.dragonFruit
                          : Colors.white.withOpacity(0.1),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _userHasUpvoted
                            ? Icons.thumb_up
                            : Icons.thumb_up_outlined,
                        color: _userHasUpvoted
                            ? ArenaColor.dragonFruit
                            : Colors.white70,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '$_upvoteCount',
                        style: TextStyle(
                          color: _userHasUpvoted
                              ? ArenaColor.dragonFruit
                              : Colors.white70,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              const Icon(
                Icons.mode_comment_outlined,
                color: Colors.white54,
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                '${_comments.length}',
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(width: 16),
              const Icon(
                Icons.visibility_outlined,
                color: Colors.white54,
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                '$_viewsCount',
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCommentCard(DiscussionComment comment) {
    final isOwner =
        _currentUsername != null && _currentUsername == comment.authorUsername;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 32,
                width: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: ArenaColor.purpleX11.withOpacity(0.3),
                ),
                child: Text(
                  comment.authorDisplay.isNotEmpty
                      ? comment.authorDisplay[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      comment.authorDisplay,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      comment.relativeTime,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              if (isOwner)
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert,
                    color: Colors.white.withOpacity(0.5),
                    size: 20,
                  ),
                  color: ArenaColor.darkAmethyst,
                  onSelected: (value) {
                    if (value == 'edit') {
                      _editComment(comment);
                    } else if (value == 'delete') {
                      _deleteComment(comment);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, color: Colors.white70, size: 18),
                          SizedBox(width: 8),
                          Text('Edit', style: TextStyle(color: Colors.white)),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.redAccent, size: 18),
                          SizedBox(width: 8),
                          Text(
                            'Hapus',
                            style: TextStyle(color: Colors.redAccent),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            comment.content,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentInput() {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: ArenaColor.darkAmethyst.withOpacity(0.95),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1))),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _commentController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Tulis komentar...',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
                filled: true,
                fillColor: Colors.white.withOpacity(0.08),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _submitComment(),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: _isSubmittingComment ? null : _submitComment,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: ArenaColor.dragonFruit,
                shape: BoxShape.circle,
              ),
              child: _isSubmittingComment
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(
                      Icons.send_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
