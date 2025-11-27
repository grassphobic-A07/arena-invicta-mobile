import 'package:arena_invicta_mobile/global/widgets/app_colors.dart';
import 'package:arena_invicta_mobile/rafa_news/models/news_entry.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NewsEntryCard extends StatelessWidget {
  final NewsEntry news;
  final VoidCallback onTap; // Callback saat kartu diklik

  const NewsEntryCard({
    super.key,
    required this.news,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // --- URL PROXY CONFIG ---
    // Ganti URL ini sesuai environment kamu (Localhost / Deploy)
    // Jika di Emulator Android: "http://10.0.2.2:8000"
    // Jika di Web/iOS Simulator: "http://127.0.0.1:8000"
    // Jika Deploy PBP: "https://neal-guarddin-arenainvicta.pbp.cs.ui.ac.id"
    
    const String baseUrl = "https://neal-guarddin-arenainvicta.pbp.cs.ui.ac.id";
    
    // Bangun URL gambar melewati Proxy Django agar tidak kena CORS/Error
    final String proxyUrl = "$baseUrl/news/image-proxy/?url=${Uri.encodeComponent(news.thumbnail ?? '')}";

    return GestureDetector(
      onTap: onTap, // Panggil fungsi navigasi yang dikirim dari parent
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        height: 140,
        decoration: BoxDecoration(
          // Style Glassmorphism
          color: ArenaColor.darkAmethystLight.withOpacity(0.3),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. GAMBAR (Kiri)
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  Hero(
                    tag: "news_img_${news.id}",
                    child: Container(
                      height: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.black26,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: (news.thumbnail != null && news.thumbnail!.isNotEmpty)
                            ? Image.network(
                                proxyUrl, // <-- Pake URL Proxy di sini
                                fit: BoxFit.cover,
                                width: double.infinity,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: ArenaColor.darkAmethystLight,
                                    child: const Center(
                                      child: Icon(Icons.broken_image, color: Colors.white54),
                                    ),
                                  );
                                },
                              )
                            : const Center(
                                child: Icon(Icons.image_not_supported, color: Colors.white54),
                              ),
                      ),
                    ),
                  ),
                  
                  // Badge LIVE (Opsional jika ada logika live)
                  if (news.isLive)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: [
                            BoxShadow(color: Colors.red.withOpacity(0.5), blurRadius: 8)
                          ],
                        ),
                        child: const Text(
                          "MATCH",
                          style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w900),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(width: 16),

            // 2. KONTEN (Kanan)
            Expanded(
              flex: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Kategori
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: ArenaColor.darkAmethystLight.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: ArenaColor.dragonFruit.withOpacity(0.3)),
                    ),
                    child: Text(
                      news.sports.toUpperCase(),
                      style: GoogleFonts.outfit(
                        color: ArenaColor.dragonFruit,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Judul
                  Text(
                    news.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      height: 1.1,
                    ),
                  ),

                  const SizedBox(height: 4),
                  
                  // Preview Konten
                  Text(
                    news.contentPreview,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white38, fontSize: 10),
                  ),

                  const Spacer(),

                  // Metadata Bawah
                  Row(
                    children: [
                      const Icon(Icons.access_time_rounded, size: 12, color: ArenaColor.darkAmethystLight),
                      const SizedBox(width: 4),
                      Text(
                        news.timeAgo, 
                        style: const TextStyle(color: Colors.white54, fontSize: 10),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          news.author,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.white54, fontSize: 10),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}