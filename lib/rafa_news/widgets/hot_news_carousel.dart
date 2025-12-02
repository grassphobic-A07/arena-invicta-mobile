import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:arena_invicta_mobile/global/widgets/app_colors.dart';
import 'package:arena_invicta_mobile/rafa_news/models/news_entry.dart';
import 'package:arena_invicta_mobile/rafa_news/screens/news_detail_page.dart';
import 'package:arena_invicta_mobile/global/environments.dart';
class HotNewsCarousel extends StatefulWidget {
  final List<NewsEntry> newsList;

  const HotNewsCarousel({super.key, required this.newsList});

  @override
  State<HotNewsCarousel> createState() => _HotNewsCarouselState();
}

class _HotNewsCarouselState extends State<HotNewsCarousel> {
  // viewportFraction: 1.0 so one image fills the screen width
  final PageController _pageController = PageController(viewportFraction: 1.0);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250, // Fixed height for the hero carousel area
      child: PageView.builder(
        controller: _pageController,
        itemCount: widget.newsList.length,
        itemBuilder: (context, index) {
          final news = widget.newsList[index];
          
          // Proxy URL for image
          final String proxyUrl = "$baseUrl/proxy-image/?url=${Uri.encodeComponent(news.thumbnail ?? '')}";

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NewsDetailPage(news: news),
                ),
              );
            },
            child: Stack(
              fit: StackFit.expand,
              children: [
                // 1. Full Width Background Image
                Image.network(
                  proxyUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: ArenaColor.darkAmethystLight,
                      child: const Center(
                        child: Icon(Icons.broken_image_rounded, color: Colors.white24, size: 50),
                      ),
                    );
                  },
                ),
                
                // 2. Gradient Overlay (To make text readable)
                Container(
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
                
                // 3. Text Content (Category & Title)
                Padding(
                  padding: const EdgeInsets.fromLTRB(24.0, 0, 24.0, 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Category Chip
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: ArenaColor.dragonFruit,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          news.sports,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // News Title
                      Text(
                        news.title,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}