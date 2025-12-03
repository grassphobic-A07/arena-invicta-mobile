import 'package:arena_invicta_mobile/global/widgets/app_colors.dart';
import 'package:arena_invicta_mobile/rafa_news/models/news_entry.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:arena_invicta_mobile/global/environments.dart';
class NewsDetailPage extends StatelessWidget {
  final NewsEntry news;

  const NewsDetailPage({super.key, required this.news});

  @override
  Widget build(BuildContext context) {
    // URL Proxy Config (Sama seperti di card)
    final String proxyUrl = "$baseUrl/proxy-image/?url=${Uri.encodeComponent(news.thumbnail ?? '')}";

    return Scaffold(
      backgroundColor: ArenaColor.darkAmethyst,
      body: CustomScrollView(
        slivers: [
          // 1. App Bar dengan Gambar Hero
          SliverAppBar(
            expandedHeight: 300,
            backgroundColor: ArenaColor.darkAmethyst,
            pinned: true,
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black45,
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: "news_img_${news.id}",
                    child: Image.network(
                      proxyUrl, 
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: ArenaColor.darkAmethystLight,
                        child: const Icon(Icons.broken_image, color: Colors.white54),
                      ),
                    ),
                  ),
                  // Gradient bawah agar judul terbaca
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent, 
                          ArenaColor.darkAmethyst.withOpacity(0.9)
                        ],
                        stops: const [0.6, 1.0],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. Konten Berita
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tag Kategori & Tanggal
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: ArenaColor.dragonFruit.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: ArenaColor.dragonFruit),
                        ),
                        child: Text(
                          "${news.sports.toUpperCase()} • ${news.category.toUpperCase()}",
                          style: const TextStyle(
                            color: ArenaColor.dragonFruit,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Format tanggal sederhana YYYY-MM-DD
                      Text(
                        news.createdAt.toString().split(' ')[0], 
                        style: const TextStyle(color: Colors.white54, fontSize: 12)
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),

                  Text(
                    news.title,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      height: 1.2,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 12, 
                        backgroundColor: Colors.white24, 
                        child: Icon(Icons.person, size: 14, color: Colors.white)
                      ),
                      const SizedBox(width: 8),
                      Text(
                        news.author, 
                        style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)
                      ),
                      const Spacer(),
                      const Icon(Icons.visibility, size: 14, color: Colors.white38),
                      const SizedBox(width: 4),
                      Text(
                        "${news.newsViews} Views", 
                        style: const TextStyle(color: Colors.white38, fontSize: 12)
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                  const Divider(color: Colors.white10),
                  const SizedBox(height: 24),

                  // Konten Berita
                  Text(
                    news.content,
                    style: GoogleFonts.poppins(
                      color: Colors.white70,
                      fontSize: 16,
                      height: 1.8,
                    ),
                  ),
                  
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}