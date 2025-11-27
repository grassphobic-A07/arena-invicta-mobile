import 'dart:ui';
import 'package:arena_invicta_mobile/global/widgets/app_colors.dart';
import 'package:arena_invicta_mobile/rafa_news/models/news_entry.dart';
import 'package:arena_invicta_mobile/rafa_news/widgets/news_entry_card.dart';
import 'package:arena_invicta_mobile/rafa_news/screens/news_detail_page.dart'; // Pastikan import ini ada
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class NewsEntryListPage extends StatefulWidget {
  static const String routeName = '/news-entry-list';

  const NewsEntryListPage({super.key});

  @override
  State<NewsEntryListPage> createState() => _NewsEntryListPageState();
}

class _NewsEntryListPageState extends State<NewsEntryListPage> {
  // Filter State
  String _selectedSport = "All";
  
  // List Kategori Olahraga (Sesuai Django SPORTS_CHOICES)
  final List<String> _sportsFilters = ["All", "football", "basketball", "tennis", "volleyball", "motogp"];

  // --- FUNGSI FETCH DATA DARI DJANGO ---
  Future<List<NewsEntry>> fetchNews(CookieRequest request) async {
    // Ganti URL ini dengan URL deploy kamu jika sudah di-deploy
    // Jika di emulator: http://10.0.2.2:8000/show-news-json
    String url = 'https://neal-guarddin-arenainvicta.pbp.cs.ui.ac.id/show-news-json';
    
    // Tambahkan parameter filter jika user memilih kategori tertentu
    if (_selectedSport != "All") {
      url += '?filter=${_selectedSport.toLowerCase()}';
    }

    try {
      final response = await request.get(url);

      // Konversi JSON List menjadi List<NewsEntry>
      List<NewsEntry> listNews = [];
      for (var d in response) {
        if (d != null) {
          listNews.add(NewsEntry.fromJson(d));
        }
      }
      return listNews;
    } catch (e) {
      // Handle error koneksi atau parsing
      debugPrint("Error fetching news: $e");
      return []; // Return list kosong agar tidak crash
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      backgroundColor: ArenaColor.darkAmethyst,
      body: Stack(
        children: [
          // 1. Background Glow (Hiasan Latar Belakang)
          Positioned(top: -50, right: -50, child: _buildGlowCircle(ArenaColor.purpleX11)),
          Positioned(bottom: 100, left: -50, child: _buildGlowCircle(ArenaColor.dragonFruit)),

          // 2. Content Utama
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Header ---
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    children: [
                      // Tombol Back Custom
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white.withOpacity(0.1)),
                          ),
                          child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "SPORTPULSE DAILY",
                            style: GoogleFonts.outfit(
                              color: ArenaColor.dragonFruit, 
                              fontSize: 10, 
                              letterSpacing: 1.5, 
                              fontWeight: FontWeight.bold
                            ),
                          ),
                          Text(
                            "Latest News 📰",
                            style: GoogleFonts.outfit(
                              color: Colors.white, 
                              fontSize: 24, 
                              fontWeight: FontWeight.bold
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),

                // --- Filter Kategori (Sports Chips) ---
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    scrollDirection: Axis.horizontal,
                    itemCount: _sportsFilters.length,
                    itemBuilder: (context, index) {
                      final sport = _sportsFilters[index];
                      final isSelected = _selectedSport == sport;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedSport = sport;
                          });
                          // FutureBuilder akan otomatis re-fetch karena build dijalankan ulang
                        },
                        child: Container(
                          margin: const EdgeInsets.only(right: 10),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected 
                                ? ArenaColor.dragonFruit 
                                : ArenaColor.darkAmethystLight.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected ? ArenaColor.dragonFruit : Colors.transparent,
                            ),
                            boxShadow: isSelected 
                                ? [BoxShadow(color: ArenaColor.dragonFruit.withOpacity(0.4), blurRadius: 10)] 
                                : [],
                          ),
                          child: Text(
                            sport.toUpperCase(),
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.white54,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 24),

                // --- List Berita (FutureBuilder) ---
                Expanded(
                  child: FutureBuilder<List<NewsEntry>>(
                    future: fetchNews(request),
                    builder: (context, AsyncSnapshot<List<NewsEntry>> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator(color: ArenaColor.purpleX11));
                      } else {
                        if (snapshot.hasError) {
                           return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.error_outline, size: 40, color: Colors.redAccent),
                                const SizedBox(height: 10),
                                Text(
                                  "Gagal memuat berita.",
                                  style: const TextStyle(color: Colors.white54),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          );
                        }
                        
                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.search_off, size: 50, color: Colors.white24),
                                const SizedBox(height: 10),
                                Text(
                                  "Tidak ada berita untuk kategori $_selectedSport", 
                                  style: const TextStyle(color: Colors.white38)
                                ),
                              ],
                            ),
                          );
                        } else {
                          // Data berhasil diambil
                          List<NewsEntry> newsList = snapshot.data!;
                          
                          return ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            itemCount: newsList.length,
                            itemBuilder: (context, index) {
                              // Menggunakan widget NewsEntryCard yang sudah dibuat sebelumnya
                              return NewsEntryCard(
                                news: newsList[index],
                                onTap: () {
                                  // Navigasi ke detail page
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => NewsDetailPage(news: newsList[index]),
                                    ),
                                  );
                                },
                              );
                            },
                          );
                        }
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper untuk membuat lingkaran glow di background
  Widget _buildGlowCircle(Color color) {
    return Container(
      width: 250,
      height: 250,
      decoration: BoxDecoration(
        color: color.withOpacity(0.3),
        shape: BoxShape.circle,
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
        child: Container(color: Colors.transparent),
      ),
    );
  }
}