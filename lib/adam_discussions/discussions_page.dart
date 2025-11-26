import 'package:arena_invicta_mobile/global/widgets/app_colors.dart';
import 'package:arena_invicta_mobile/global/widgets/glass_bottom_nav.dart';
import 'package:arena_invicta_mobile/main.dart';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

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

  Future<void> _fetchThreads() async {
    final request = context.read<CookieRequest>();
    try {
      final response = await request.get("https://neal-guarddin-arenainvicta.pbp.cs.ui.ac.id/discussions/api/threads/");
      final rawThreads = (response['threads'] as List<dynamic>? ?? []);
      setState(() {
        _threads = rawThreads.map((json) => DiscussionThread.fromJson(json as Map<String, dynamic>)).toList();
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

  void _handleNavTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, MyApp.routeName);
        break;
      case 1:
        // Already here.
        break;
      case 2:
        // Placeholder for analytics/stats tab.
        break;
      case 3:
        // Placeholder for profile tab.
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.topLeft,
                radius: 1.2,
                colors: [
                  Color(0xFF9333EA),
                  Color(0xFF2A1B54),
                ],
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.bottomRight,
                radius: 1.2,
                colors: [
                  Color(0xFF4A49A0),
                  Color(0xFF2A1B54),
                ],
              ),
            ),
          ),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: const Text('Discussions'),
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {},
              ),
              TextButton.icon(
                onPressed: () => Navigator.pushNamed(context, LoginPage.routeName),
                icon: const Icon(Icons.login, color: Colors.white),
                label: const Text(
                  'Login',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: _fetchThreads,
              child: ListView(
                physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 140),
                children: [
                  _HeroCard(
                    title: 'Mulai Diskusi Baru',
                    subtitle: 'Bagikan opini, analisis taktik, atau tanya komunitas.',
                    ctaLabel: 'Tulis Diskusi',
                    onTap: () {},
                  ),
                  const SizedBox(height: 12),
                  _FilterChips(
                    filters: const ['Semua', 'Trending', 'Belum Terjawab', 'Favorit'],
                    onSelected: (_) {},
                  ),
                  const SizedBox(height: 12),
                  if (_isLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 80),
                      child: Center(child: CircularProgressIndicator(color: ArenaColor.purpleX11)),
                    )
                  else if (_error != null)
                    _ErrorCard(message: _error!, onRetry: _fetchThreads)
                  else if (_threads.isEmpty)
                    const _EmptyState()
                  else ..._threads.map((t) => _ThreadCard(thread: t)),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: GlassBottomNavBar(
            activeIndex: 1,
            onItemTap: (index) => _handleNavTap(context, index),
            onCenterTap: () {},
          ),
        ),
      ],
    );
  }
}

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
          colors: [
            Color(0xFF4A49A0),
            Color(0xFF2A1B54),
          ],
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
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13),
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: onTap,
            child: Text(ctaLabel),
          ),
        ],
      ),
    );
  }
}

class _FilterChips extends StatefulWidget {
  const _FilterChips({required this.filters, required this.onSelected});

  final List<String> filters;
  final ValueChanged<String> onSelected;

  @override
  State<_FilterChips> createState() => _FilterChipsState();
}

class _FilterChipsState extends State<_FilterChips> {
  int active = 0;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(widget.filters.length, (index) {
          final selected = index == active;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(widget.filters[index]),
              selected: selected,
              onSelected: (_) {
                setState(() => active = index);
                widget.onSelected(widget.filters[index]);
              },
              selectedColor: ArenaColor.purpleX11.withOpacity(0.9),
              backgroundColor: Colors.white.withOpacity(0.08),
              labelStyle: TextStyle(color: Colors.white.withOpacity(selected ? 1 : 0.8)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: BorderSide(color: Colors.white.withOpacity(0.1)),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _ThreadCard extends StatelessWidget {
  const _ThreadCard({required this.thread});

  final DiscussionThread thread;

  @override
  Widget build(BuildContext context) {
    return Container(
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
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF9333EA), Color(0xFF4F46E5)],
                  ),
                ),
                child: Text(
                  thread.authorDisplay.isNotEmpty ? thread.authorDisplay[0].toUpperCase() : '?',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
                      style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 12),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.more_vert, color: Colors.white54),
            ],
          ),
          const SizedBox(height: 10),
          if (thread.tags.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: -4,
              children: thread.tags
                  .map(
                    (tag) => Chip(
                      label: Text(tag),
                      labelStyle: const TextStyle(color: Colors.white, fontSize: 12),
                      backgroundColor: Colors.white.withOpacity(0.08),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.white.withOpacity(0.1)),
                      ),
                    ),
                  )
                  .toList(),
            ),
          if (thread.tags.isNotEmpty) const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.mode_comment_outlined, color: Colors.white54, size: 18),
              const SizedBox(width: 6),
              Text('${thread.commentCount}', style: const TextStyle(color: Colors.white70)),
              const SizedBox(width: 12),
              const Icon(Icons.visibility_outlined, color: Colors.white54, size: 18),
              const SizedBox(width: 6),
              Text(_formatCount(thread.viewsCount), style: const TextStyle(color: Colors.white70)),
              const Spacer(),
              const Icon(Icons.thumb_up_alt_outlined, color: Colors.white54, size: 18),
              const SizedBox(width: 6),
              Text(_formatCount(thread.upvoteCount), style: const TextStyle(color: Colors.white70)),
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
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                  if (thread.newsSummary != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      thread.newsSummary ?? '',
                      style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 12),
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
            style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 15, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(message, style: TextStyle(color: Colors.white.withOpacity(0.8))),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh, color: Colors.white),
            label: const Text('Coba lagi', style: TextStyle(color: Colors.white)),
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
                const Text('Belum ada diskusi', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text('Mulai topik pertama dan ajak komunitas berdiskusi.', style: TextStyle(color: Colors.white.withOpacity(0.8))),
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
    this.newsTitle,
    this.newsSummary,
  });

  factory DiscussionThread.fromJson(Map<String, dynamic> json) {
    final author = json['author'] as Map<String, dynamic>? ?? {};
    final news = json['news'] as Map<String, dynamic>? ?? {};
    return DiscussionThread(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      authorDisplay: author['display_name'] as String? ?? author['username'] as String? ?? 'Anonim',
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
      commentCount: json['comment_count'] as int? ?? 0,
      upvoteCount: json['upvote_count'] as int? ?? 0,
      viewsCount: json['views_count'] as int? ?? 0,
      newsTitle: news['title'] as String?,
      newsSummary: news['summary'] as String?,
    );
  }

  final int id;
  final String title;
  final String authorDisplay;
  final DateTime createdAt;
  final int commentCount;
  final int upvoteCount;
  final int viewsCount;
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
