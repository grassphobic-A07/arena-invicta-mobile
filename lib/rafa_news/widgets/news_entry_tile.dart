import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:arena_invicta_mobile/global/widgets/app_colors.dart';
import 'package:arena_invicta_mobile/rafa_news/models/news_entry.dart';

class NewsEntryTile extends StatelessWidget {
  final NewsEntry news;
  final VoidCallback onTap;

  const NewsEntryTile({
    super.key,
    required this.news,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Proxy URL Logic (Sama seperti sebelumnya)
    const String baseUrl = "https://neal-guarddin-arenainvicta.pbp.cs.ui.ac.id";
    final String proxyUrl = "$baseUrl/proxy-image/?url=${Uri.encodeComponent(news.thumbnail ?? '')}";

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          // Background semi-transparan glassmorphism
          color: ArenaColor.darkAmethystLight.withOpacity(0.3),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            // 1. GAMBAR THUMBNAIL (KIRI)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 80, // Ukuran fix biar rapi
                height: 80,
                child: Image.network(
                  proxyUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: ArenaColor.darkAmethystLight,
                      child: const Icon(Icons.broken_image_rounded, color: Colors.white24),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(width: 16),

            // 2. KONTEN TEKS (TENGAH)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Chip Kategori Kecil
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: ArenaColor.dragonFruit.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      news.sports.toUpperCase(),
                      style: GoogleFonts.outfit(
                        color: ArenaColor.dragonFruit,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 8),

                  // Judul Berita
                  Text(
                    news.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      height: 1.2,
                    ),
                  ),

                  const SizedBox(height: 6),

                  // Metadata (Author & Views)
                  Row(
                    children: [
                      const Icon(Icons.person, size: 12, color: Colors.white54),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          news.author,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.white54, fontSize: 10),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.visibility, size: 12, color: Colors.white54),
                      const SizedBox(width: 4),
                      Text(
                        "${news.newsViews}",
                        style: const TextStyle(color: Colors.white54, fontSize: 10),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(width: 12),

            // 3. TOMBOL PANAH (KANAN - Opsional)
            // Memberi hint bahwa ini bisa diklik
            const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white24, size: 16),
          ],
        ),
      ),
    );
  }
}