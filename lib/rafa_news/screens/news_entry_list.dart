import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

// --- IMPORTS ---
import 'package:arena_invicta_mobile/global/widgets/app_colors.dart';
import 'package:arena_invicta_mobile/global/widgets/glassy_header.dart'; // WIDGET HEADER
import 'package:arena_invicta_mobile/global/widgets/glassy_navbar.dart'; // WIDGET NAVBAR

import 'package:arena_invicta_mobile/neal_auth/widgets/arena_invicta_drawer.dart'; 
import 'package:arena_invicta_mobile/rafa_news/models/news_entry.dart';
import 'package:arena_invicta_mobile/rafa_news/screens/news_detail_page.dart';
import 'package:arena_invicta_mobile/main.dart';
import 'package:arena_invicta_mobile/rafa_news/widgets/news_entry_card.dart';
import 'package:arena_invicta_mobile/rafa_news/screens/news_form_page.dart';

class NewsEntryListPage extends StatefulWidget {
  static const String routeName = '/news-entry-list';
  final String? initialCategory;

  const NewsEntryListPage({super.key, this.initialCategory});

  @override
  State<NewsEntryListPage> createState() => _NewsEntryListPageState();
}

class _NewsEntryListPageState extends State<NewsEntryListPage> {
  // 1. KITA BUTUH KEY INI UNTUK BUKA DRAWER
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String _selectedSport = "All";
  final List<String> _sportsFilters = ["All", "football", "basketball", "tennis", "volleyball", "motogp"];

  @override
  void initState() {
    super.initState();
    if (widget.initialCategory != null) {
      _selectedSport = widget.initialCategory!;
    }
  }

  Future<List<NewsEntry>> fetchNews(CookieRequest request) async {
    String url = 'https://neal-guarddin-arenainvicta.pbp.cs.ui.ac.id/show-news-json';
    if (_selectedSport != "All") {
      url += '?filter=${_selectedSport.toLowerCase()}';
    }

    try {
      final response = await request.get(url);
      List<NewsEntry> listNews = [];
      for (var d in response) {
        if (d != null) listNews.add(NewsEntry.fromJson(d));
      }
      return listNews;
    } catch (e) {
      debugPrint("Error fetching news: $e");
      return [];
    }
  }

  Widget _buildGlowCircle(Color color) {
    return Container(
      width: 250, height: 250,
      decoration: BoxDecoration(color: color.withOpacity(0.3), shape: BoxShape.circle),
      child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80), child: Container(color: Colors.transparent)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    final userProvider = context.watch<UserProvider>();

    // Logic Role Text untuk Drawer
    String roleText = "Guest";
    if (userProvider.isLoggedIn) {
      if (userProvider.role == UserRole.admin){
        roleText = "Admin";
      }
      else if (userProvider.role == UserRole.staff) {
        roleText = "Writer";
      } 
      else {
        roleText = "Member";
      }
    }

    return Scaffold(
      key: _scaffoldKey,
      drawer: ArenaInvictaDrawer(
        userProvider: userProvider,
        roleText: roleText, 
      ),
      backgroundColor: ArenaColor.darkAmethyst,
      resizeToAvoidBottomInset: false, 

      // --- TOMBOL TAMBAH BERITA (HANYA STAFF/ADMIN) ---
      floatingActionButton: (userProvider.isLoggedIn && (userProvider.role == UserRole.staff || userProvider.role == UserRole.admin))
          ? Padding(
              padding: const EdgeInsets.only(bottom: 80.0), // Naikkan dikit biar gak ketutup navbar
              child: FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const NewsFormPage()),
                  );
                },
                backgroundColor: ArenaColor.dragonFruit,
                child: const Icon(Icons.add, color: Colors.white),
              ),
            )
          : null,
      body: Stack(
        children: [
          // 1. BACKGROUND GLOWS
          Positioned(top: -50, right: -50, child: _buildGlowCircle(ArenaColor.purpleX11)),
          Positioned(bottom: 100, left: -50, child: _buildGlowCircle(ArenaColor.dragonFruit)),

          // 2. MAIN CONTENT
          Positioned.fill(
            child: Column(
              children: [
                // Spacer untuk Header
                SizedBox(height: MediaQuery.of(context).padding.top + 90),

                // --- FILTER KATEGORI (PINK GLOW + CUSTOM MARGIN) ---
                SizedBox(
                  height: 45,
                  child: Center(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      // Clip none agar glow tidak terpotong di kiri
                      clipBehavior: Clip.none, 
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // 1. Margin Awal Kiri (13px sesuai request)
                          const SizedBox(width: 25),

                          // 2. Loop Items
                          ..._sportsFilters.map((sport) {
                            final isSelected = _selectedSport.toLowerCase() == sport.toLowerCase();
                            
                            return Padding(
                              // Margin Kanan antar item (misal 12px agar tidak terlalu rapat)
                              // Item terakhir tidak perlu margin kanan jika ingin mepet, 
                              // tapi untuk scrollable list biasanya dikasih spacer di akhir juga.
                              padding: const EdgeInsets.only(right: 12), 
                              child: GestureDetector(
                                onTap: () => setState(() => _selectedSport = sport),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  // HAPUS MARGIN DI SINI KARENA SUDAH PAKAI PADDING DI LUAR
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: isSelected 
                                        ? ArenaColor.dragonFruit.withOpacity(0.1) 
                                        : ArenaColor.darkAmethystLight.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(100),
                                    border: Border.all(
                                      color: isSelected ? ArenaColor.dragonFruit : Colors.white.withOpacity(0.1),
                                      width: isSelected ? 2 : 1,
                                    ),
                                    boxShadow: isSelected 
                                        ? [BoxShadow(color: ArenaColor.dragonFruit.withOpacity(0.6), blurRadius: 15, spreadRadius: 1)] 
                                        : [],
                                  ),
                                  child: Text(
                                    sport == "All" ? "All" : sport[0].toUpperCase() + sport.substring(1),
                                    style: GoogleFonts.outfit(
                                      color: isSelected ? ArenaColor.dragonFruit : Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                          
                          // Opsional: Margin Akhir Kanan (misal 13px juga biar simetris saat di-scroll mentok kanan)
                          const SizedBox(width: 1), 
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // --- LIST BERITA ---
                Expanded(
                  child: FutureBuilder<List<NewsEntry>>(
                    future: fetchNews(request),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator(color: ArenaColor.dragonFruit));
                      } else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.search_off, size: 50, color: Colors.white24),
                              const SizedBox(height: 10),
                              Text("Tidak ada berita di kategori ini.", style: const TextStyle(color: Colors.white38)),
                            ],
                          ),
                        );
                      } else {
                        return ListView.builder(
                          padding: const EdgeInsets.fromLTRB(24, 0, 24, 120),
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            final news = snapshot.data![index];
                            return Column(
                              children: [
                                // PANGGIL WIDGET DARI FILE BARU
                                NewsEntryCard(
                                  news: news, // Kirim object news utuh
                                  onTap: () {
                                    Navigator.push(
                                      context, 
                                      MaterialPageRoute(builder: (context) => NewsDetailPage(news: news))
                                    );
                                  },
                                ),
                                const SizedBox(height: 32),
                              ],
                            );
                          },
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),

          // 3. HEADER (UBAH JADI MODE HOME / DRAWER)
          GlassyHeader(
            userProvider: userProvider,
            scaffoldKey: _scaffoldKey, // 3. Masukkan Key agar bisa buka drawer
            isHome: true, // 4. Set true agar iconnya jadi Burger Menu
            title: "ARENA INVICTA",
            subtitle: "Latest News 📰",
          ),

          // 4. NAVBAR
          GlassyNavbar(
            userProvider: userProvider,
            fabIcon: Icons.grid_view_rounded,
            onFabTap: () {
              Navigator.pop(context); // Kembali ke Home
            },
          ),
        ],
      ),
    );
  }
}