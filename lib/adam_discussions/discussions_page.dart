import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

// --- IMPORTS ---
import 'package:arena_invicta_mobile/global/widgets/app_colors.dart';
import 'package:arena_invicta_mobile/global/widgets/glassy_navbar.dart'; // GUNAKAN NAVBAR GLOBAL
import 'package:arena_invicta_mobile/global/environments.dart'; // Gunakan baseUrl

import 'package:arena_invicta_mobile/adam_discussions/create_discussion_page.dart';
import 'package:arena_invicta_mobile/adam_discussions/discussion_detail_page.dart';
import 'package:arena_invicta_mobile/neal_auth/screens/login.dart';
import 'package:arena_invicta_mobile/main.dart'; // Untuk UserProvider

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
          ), // Naikkan margin agar tidak ketutup navbar
          content: const Text('Silakan login untuk membuat diskusi.'),
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
      // Gunakan baseUrl agar konsisten
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
        _error = 'Gagal memuat diskusi: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();

    return Scaffold(
      // Background Gradient (Langsung di Scaffold body atau Stack paling bawah)
      backgroundColor: ArenaColor.darkAmethyst,
      body: Stack(
        children: [
          // 1. BACKGROUND GRADIENT (Sesuai style diskusi sebelumnya)
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

          // 2. MAIN CONTENT (SCROLLABLE)
          Positioned.fill(
            child: Column(
              children: [
                // AppBar Manual (Agar transparan)
                AppBar(
                  title: const Text(
                    'Discussions',
                    style: TextStyle(color: Colors.white),
                  ),
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  leading: IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.white,
                    ),
                    onPressed: () =>
                        Navigator.pop(context), // Kembali ke halaman sebelumnya
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.search, color: Colors.white),
                      onPressed: () {},
                    ),
                    if (!userProvider.isLoggedIn)
                      TextButton.icon(
                        onPressed: () =>
                            Navigator.pushNamed(context, LoginPage.routeName),
                        icon: const Icon(Icons.login, color: Colors.white),
                        label: const Text(
                          'Login',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                  ],
                ),

                // List Content
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _fetchThreads,
                    child: ListView(
                      physics: const BouncingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics(),
                      ),
                      // Padding bawah besar agar tidak tertutup Glassy Navbar
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                      children: [
                        _HeroCard(
                          title: 'Mulai Diskusi Baru',
                          subtitle:
                              'Bagikan opini, analisis taktik, atau tanya komunitas.',
                          ctaLabel: 'Tulis Diskusi',
                          onTap: _openCreate,
                        ),
                        const SizedBox(height: 16),

                        if (_isLoading)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 80),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: ArenaColor.purpleX11,
                              ),
                            ),
                          )
                        else if (_error != null)
                          _ErrorCard(message: _error!, onRetry: _fetchThreads)
                        else if (_threads.isEmpty)
                          const _EmptyState()
                        else
                          ..._threads.map(
                            (t) => _ThreadCard(
                              thread: t,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      DiscussionDetailPage(thread: t),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 3. GLASSY NAVBAR (GLOBAL)
          GlassyNavbar(
            userProvider: userProvider,
            // Ikon tengah di Discussions bisa digunakan untuk Refresh atau Kembali ke Home
            fabIcon: Icons.grid_view_rounded,
            onFabTap: () {
              // Jika user ingin kembali ke Home dari halaman diskusi
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
                        'oleh ${thread.authorDisplay} · ${thread.relativeTime}',
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
                  _formatCount(thread.viewsCount),
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
                  _formatCount(thread.upvoteCount),
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
                      'Terkait: ${thread.newsTitle}',
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
            'Gagal memuat',
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
              'Coba lagi',
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
                  'Belum ada diskusi',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Mulai topik pertama dan ajak komunitas berdiskusi.',
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

class DiscussionThread {
  const DiscussionThread({
    required this.id,
    required this.title,
    required this.authorDisplay,
    required this.createdAt,
    required this.commentCount,
    required this.upvoteCount,
    required this.viewsCount,
    this.body,
    this.newsId,
    this.newsTitle,
    this.newsSummary,
  });

  factory DiscussionThread.fromJson(Map<String, dynamic> json) {
    final author = json['author'] as Map<String, dynamic>? ?? {};
    final news = json['news'] as Map<String, dynamic>? ?? {};
    return DiscussionThread(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      body: json['body'] as String?,
      authorDisplay:
          author['display_name'] as String? ??
          author['username'] as String? ??
          'Anonim',
      createdAt:
          DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
      commentCount: json['comment_count'] as int? ?? 0,
      upvoteCount: json['upvote_count'] as int? ?? 0,
      viewsCount: json['views_count'] as int? ?? 0,
      newsId: news['uuid'] as String?,
      newsTitle: news['title'] as String?,
      newsSummary: news['summary'] as String?,
    );
  }

  final int id;
  final String title;
  final String? body;
  final String authorDisplay;
  final DateTime createdAt;
  final int commentCount;
  final int upvoteCount;
  final int viewsCount;
  final String? newsId;
  final String? newsTitle;
  final String? newsSummary;

  List<String> get tags {
    final list = <String>[];
    if (newsTitle != null) list.add('News');
    if (upvoteCount > 10) list.add('Populer');
    if (commentCount == 0) list.add('Belum Dijawab');
    return list;
  }

  String get relativeTime => _formatRelative(createdAt);
}

String _formatCount(int value) {
  if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(1)}m';
  if (value >= 1000) return '${(value / 1000).toStringAsFixed(1)}k';
  return value.toString();
}

String _formatRelative(DateTime dateTime) {
  final diff = DateTime.now().difference(dateTime);
  if (diff.inMinutes < 1) return 'Baru saja';
  if (diff.inHours < 1) return '${diff.inMinutes}m';
  if (diff.inHours < 24) return '${diff.inHours}h';
  if (diff.inDays < 7) return '${diff.inDays}d';
  final weeks = (diff.inDays / 7).floor();
  if (weeks < 4) return '${weeks}w';
  final months = (diff.inDays / 30).floor();
  if (months < 12) return '${months}mo';
  final years = (diff.inDays / 365).floor();
  return '${years}y';
}
