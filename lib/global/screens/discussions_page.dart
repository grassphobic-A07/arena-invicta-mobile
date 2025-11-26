import 'package:arena_invicta_mobile/global/widgets/app_colors.dart';
import 'package:arena_invicta_mobile/global/widgets/glass_bottom_nav.dart';
import 'package:arena_invicta_mobile/main.dart';
import 'package:flutter/material.dart';

class DiscussionsPage extends StatelessWidget {
  const DiscussionsPage({super.key});

  static const routeName = '/discussions';

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
    final threads = [
      _Thread(
        title: 'Prediksi Liga Champions: City vs Madrid',
        author: 'astroball',
        replies: 128,
        views: 3.2,
        tags: ['Taktik', 'UCL'],
        timeAgo: '2h',
      ),
      _Thread(
        title: 'Formasi terbaik untuk menahan high press?',
        author: 'tikitaka_id',
        replies: 64,
        views: 1.4,
        tags: ['Coaching', 'Diskusi'],
        timeAgo: '4h',
      ),
      _Thread(
        title: 'Siapa striker muda paling klinis musim ini?',
        author: 'databall',
        replies: 42,
        views: 0.9,
        tags: ['Prospec', 'Statistik'],
        timeAgo: '6h',
      ),
    ];

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
            ],
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                  ...threads.map((t) => _ThreadCard(thread: t)),
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

  final _Thread thread;

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
                  thread.author.isNotEmpty ? thread.author[0].toUpperCase() : '?',
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
                      'oleh ${thread.author} · ${thread.timeAgo} yang lalu',
                      style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 12),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.more_vert, color: Colors.white54),
            ],
          ),
          const SizedBox(height: 10),
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
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.mode_comment_outlined, color: Colors.white54, size: 18),
              const SizedBox(width: 6),
              Text('${thread.replies}', style: const TextStyle(color: Colors.white70)),
              const SizedBox(width: 12),
              const Icon(Icons.visibility_outlined, color: Colors.white54, size: 18),
              const SizedBox(width: 6),
              Text('${thread.views.toStringAsFixed(1)}k', style: const TextStyle(color: Colors.white70)),
              const Spacer(),
              Text('Terakhir ${thread.timeAgo}', style: TextStyle(color: Colors.white.withOpacity(0.7))),
            ],
          ),
        ],
      ),
    );
  }
}

class _Thread {
  const _Thread({
    required this.title,
    required this.author,
    required this.replies,
    required this.views,
    required this.tags,
    required this.timeAgo,
  });

  final String title;
  final String author;
  final int replies;
  final double views;
  final List<String> tags;
  final String timeAgo;
}
