import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:arena_invicta_mobile/global/widgets/app_colors.dart';
import 'package:arena_invicta_mobile/rafa_news/models/news_entry.dart'; // Import Model
import 'package:arena_invicta_mobile/global/environments.dart';
class NewsEntryCard extends StatelessWidget {
  final NewsEntry news; 
  final VoidCallback onTap;

  const NewsEntryCard({
    super.key,
    required this.news,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final String proxyUrl = "$baseUrl/proxy-image/?url=${Uri.encodeComponent(news.thumbnail ?? '')}";

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 220,
        width: double.infinity,
        // 1. CONTAINER LUAR: HANYA UNTUK SHADOW
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          color: ArenaColor.darkAmethyst,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        // 2. CLIPRRRECT: MEMOTONG GAMBAR
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: Stack(
            children: [
              // A. GAMBAR BACKGROUND
              Positioned.fill(
                child: Image.network(
                  proxyUrl,
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.high,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: ArenaColor.darkAmethystLight,
                      child: const Center(
                        child: Icon(
                          Icons.broken_image_rounded, 
                          color: Colors.white24, 
                          size: 50,
                        ),
                      ),
                    );
                  },
                ),
              ),

              // B. GRADIENT OVERLAY
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        ArenaColor.darkAmethyst.withOpacity(0.9),
                      ],
                      stops: const [0.4, 1.0],
                    ),
                  ),
                ),
              ),

              // C. KONTEN TEKS & TAG
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: ArenaColor.dragonFruit.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: ArenaColor.dragonFruit.withOpacity(0.8)),
                      ),
                      child: Text(
                        news.sports, // Ambil dari object news
                        style: GoogleFonts.poppins(
                          color: ArenaColor.dragonFruit,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      news.title, // Ambil dari object news
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${news.newsViews} Views • ${news.author}", 
                      style: GoogleFonts.poppins(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}