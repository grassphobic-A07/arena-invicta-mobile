import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

import 'package:arena_invicta_mobile/global/widgets/app_colors.dart';
import 'package:arena_invicta_mobile/global/widgets/glassy_header.dart';
import 'package:arena_invicta_mobile/global/widgets/glassy_navbar.dart';
import 'package:arena_invicta_mobile/global/environments.dart';

import 'package:arena_invicta_mobile/adam_discussions/screens/create_discussion_page.dart';
import 'package:arena_invicta_mobile/adam_discussions/screens/discussion_detail_page.dart';
import 'package:arena_invicta_mobile/adam_discussions/models/discussion_models.dart';
import 'package:arena_invicta_mobile/neal_auth/screens/login.dart';
import 'package:arena_invicta_mobile/main.dart';

class DiscussionsPage extends StatefulWidget {
  const DiscussionsPage({super.key});

  static const routeName = '/discussions';

  @override
  State<DiscussionsPage> createState() => _DiscussionsPageState();
}

class _DiscussionsPageState extends State<DiscussionsPage> {
  List<DiscussionThread> _threads = [];
  bool _isLoading = true;
  String? _error;
  String _searchQuery = '';

  Widget _buildGlowCircle(Color color) {
    return Container(
      width: 320,
      height: 320,
      decoration: BoxDecoration(
        color: color.withOpacity(0.22),
        shape: BoxShape.circle,
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 90, sigmaY: 90),
        child: const SizedBox.shrink(),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _fetchThreads();
  }

  Future<void> _openCreate() async {
    final user = context.read<UserProvider>();
    if (!user.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.only(
            bottom: 120,
            left: 16,
            right: 16,
          ), 
          content: const Text('Please log in to create a discussion.'),
          action: SnackBarAction(
            label: 'Login',
            textColor: Colors.white,
            onPressed: () => Navigator.pushNamed(context, LoginPage.routeName),
          ),
        ),
      );
      return;
    }

    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const CreateDiscussionPage()),
    );
    if (created == true) {
      _fetchThreads();
    }
  }

  Future<void> _fetchThreads() async {
    final request = context.read<CookieRequest>();
    try {
      final response = await request.get("$baseUrl/discussions/api/threads/");
      final rawThreads = (response['threads'] as List<dynamic>? ?? []);
      setState(() {
        _threads = rawThreads
            .map(
              (json) => DiscussionThread.fromJson(json as Map<String, dynamic>),
            )
            .toList();
        _isLoading = false;
        _error = null;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Failed to load discussions: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final query = _searchQuery.trim().toLowerCase();
    final filteredThreads = _threads.where((t) {
      if (query.isEmpty) return true;
      final titleMatch = t.title.toLowerCase().contains(query);
      final authorMatch = t.authorDisplay.toLowerCase().contains(query);
      final tagsMatch = t.tags.any((tag) => tag.toLowerCase().contains(query));
      return titleMatch || authorMatch || tagsMatch;
    }).toList();

    // Hitung posisi top agar pas di bawah header
    final double headerHeight = MediaQuery.of(context).padding.top + 80;
    final double searchBarHeight = 60;
    final double contentPaddingTop = headerHeight + searchBarHeight + 10;

    return Scaffold(
      backgroundColor: ArenaColor.darkAmethyst,
      resizeToAvoidBottomInset: false, 
      body: Stack(
        children: [
          // 0. GLOWS (background)
          Positioned(top: -120, left: -90, child: _buildGlowCircle(ArenaColor.dragonFruit)),
          Positioned(bottom: -140, right: -110, child: _buildGlowCircle(ArenaColor.purpleX11)),

          // 1. MAIN CONTENT (LIST VIEW)
          // List ini ada di layer paling bawah, jadi dia akan scroll di "belakang" Search Bar
          Positioned.fill(
            child: RefreshIndicator(
              onRefresh: _fetchThreads,
              child: ListView(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                padding: EdgeInsets.fromLTRB(16, contentPaddingTop, 16, 120),
                children: [
                  if (userProvider.isLoggedIn) ...[
                    _HeroCard(
                      title: 'Start a New Discussion',
                      subtitle: 'Share opinions, tactical analyses, or ask the community.',
                      ctaLabel: 'Start Discussion',
                      onTap: _openCreate,
                    ),
                    const SizedBox(height: 16),
                  ],

                  if (_isLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 80),
                      child: Center(
                        child: CircularProgressIndicator(color: ArenaColor.dragonFruit),
                      ),
                    )
                  else if (_error != null)
                    _ErrorCard(message: _error!, onRetry: _fetchThreads)
                  else if (_threads.isEmpty)
                    const _EmptyState()
                  else if (filteredThreads.isEmpty)
                    _EmptySearchState(
                      query: _searchQuery,
                      onClear: () => setState(() => _searchQuery = ''),
                    )
                  else
                    ...filteredThreads.map(
                      (t) => _ThreadCard(
                        thread: t,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DiscussionDetailPage(thread: t),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // 2. HEADER
          GlassyHeader(
            userProvider: userProvider,
            isHome: false,
            title: 'Arena Invicta',
            subtitle: 'Discussions',
          ),

          // 3. SEARCH BAR (FIXED & GLASSY)
          // Posisinya fixed di bawah header, content akan lewat di belakangnya
          Positioned(
            top: headerHeight - 5, // Sedikit overlap biar rapi
            left: 24,
            right: 24,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), // Efek blur (invisible container)
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1), // Transparan
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: TextField(
                    style: const TextStyle(color: Colors.white),
                    onChanged: (value) => setState(() => _searchQuery = value),
                    decoration: InputDecoration(
                      hintText: "Find a discussion...",
                      hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                      prefixIcon: const Icon(Icons.search, color: Colors.white54),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // 4. NAVBAR
          GlassyNavbar(
            userProvider: userProvider,
            fabIcon: Icons.grid_view_rounded,
            activeItem: NavbarItem.discussions,
            onFabTap: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}

// --- WIDGETS PENDUKUNG (TETAP SAMA) ---

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.title,
    required this.subtitle,
    required this.ctaLabel,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final String ctaLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF4A49A0), Color(0xFF2A1B54)],
        ),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          const Icon(Icons.edit, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: ArenaColor.dragonFruit,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: onTap,
            child: Text(ctaLabel),
          ),
        ],
      ),
    );
  }
}

class _EmptySearchState extends StatelessWidget {
  const _EmptySearchState({required this.query, required this.onClear});

  final String query;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        children: [
          Icon(Icons.search_off, color: Colors.white.withOpacity(0.6)),
          const SizedBox(height: 8),
          Text(
            'No results for "$query"',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 6),
          TextButton(
            onPressed: onClear,
            child: const Text(
              'Clear search',
              style: TextStyle(color: ArenaColor.dragonFruit),
            ),
          ),
        ],
      ),
    );
  }
}

class _ThreadCard extends StatelessWidget {
  const _ThreadCard({required this.thread, required this.onTap});

  final DiscussionThread thread;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.06)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  height: 36,
                  width: 36,
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
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        thread.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'by ${thread.authorDisplay} · ${thread.relativeTime}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.75),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.white.withOpacity(0.4),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (thread.tags.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: thread.tags
                    .map(
                      (tag) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: ArenaColor.dragonFruit.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          tag,
                          style: const TextStyle(
                            color: ArenaColor.dragonFruit,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            if (thread.tags.isNotEmpty) const SizedBox(height: 10),
            Row(
              children: [
                const Icon(
                  Icons.mode_comment_outlined,
                  color: Colors.white54,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Text(
                  '${thread.commentCount}',
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(width: 12),
                const Icon(
                  Icons.visibility_outlined,
                  color: Colors.white54,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Text(
                  formatCount(thread.viewsCount),
                  style: const TextStyle(color: Colors.white70),
                ),
                const Spacer(),
                const Icon(
                  Icons.thumb_up_alt_outlined,
                  color: Colors.white54,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Text(
                  formatCount(thread.upvoteCount),
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
            if (thread.newsTitle != null) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white.withOpacity(0.06)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Related: ${thread.newsTitle}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    if (thread.newsSummary != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        thread.newsSummary ?? '',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.75),
                          fontSize: 12,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Failed to load',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(message, style: TextStyle(color: Colors.white.withOpacity(0.8))),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh, color: Colors.white),
            label: const Text(
              'Try again',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Row(
        children: [
          const Icon(Icons.inbox_outlined, color: Colors.white54),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'No discussions yet',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Start the first topic and invite the community to chat.',
                  style: TextStyle(color: Colors.white.withOpacity(0.8)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}