import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

// --- IMPORTS ---
import 'package:arena_invicta_mobile/global/widgets/app_colors.dart';
import 'package:arena_invicta_mobile/global/widgets/glassy_header.dart'; 
import 'package:arena_invicta_mobile/global/widgets/glassy_navbar.dart'; 
import 'package:arena_invicta_mobile/global/environments.dart';

import 'package:arena_invicta_mobile/neal_auth/widgets/arena_invicta_drawer.dart'; 
import 'package:arena_invicta_mobile/rafa_news/screens/news_form_page.dart'; // Import Form

import 'package:arena_invicta_mobile/rafa_news/models/news_entry.dart';
import 'package:arena_invicta_mobile/rafa_news/screens/news_detail_page.dart';
import 'package:arena_invicta_mobile/rafa_news/widgets/news_entry_tile.dart'; 
import 'package:arena_invicta_mobile/main.dart'; 

class NewsEntryListPage extends StatefulWidget {
  static const String routeName = '/news-entry-list';
  final String? initialCategory;

  const NewsEntryListPage({super.key, this.initialCategory});

  @override
  State<NewsEntryListPage> createState() => _NewsEntryListPageState();
}

class _NewsEntryListPageState extends State<NewsEntryListPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String _selectedSport = "All";
  final List<String> _sportsFilters = ["All", "Football", "Basketball", "Tennis", "Volleyball", "Motogp"];

  @override
  void initState() {
    super.initState();
    if (widget.initialCategory != null) {
      _selectedSport = widget.initialCategory!;
    }
  }

  Future<List<NewsEntry>> fetchNews(CookieRequest request) async {
    String url = '$baseUrl/show-news-json'; 
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

    // Logic Role Text
    String roleText = "Guest";
    if (userProvider.isLoggedIn) {
      if (userProvider.role == UserRole.admin) roleText = "Admin";
      else if (userProvider.role == UserRole.staff) roleText = "Writer";
      else roleText = "Member";
    }

    return Scaffold(
      key: _scaffoldKey,
      drawer: ArenaInvictaDrawer(
        userProvider: userProvider,
        roleText: roleText,
      ),
      backgroundColor: ArenaColor.darkAmethyst,
      resizeToAvoidBottomInset: false, 
      
      // --- TOMBOL TAMBAH BERITA ---
      floatingActionButton: (userProvider.isLoggedIn && (userProvider.role == UserRole.staff || userProvider.role == UserRole.admin))
          ? Padding(
              padding: const EdgeInsets.only(bottom: 90.0, right: 8.0), 
              child: FloatingActionButton(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const NewsFormPage()),
                  );
                  if (result == true) {
                    setState(() {});
                  }
                },
                backgroundColor: ArenaColor.dragonFruit,
                child: const Icon(Icons.add, color: Colors.white, size: 29.0,),
              ),
            )
          : null,

      body: Stack(
        children: [
          // 1. Background Glows
          Positioned(top: -50, right: -50, child: _buildGlowCircle(ArenaColor.purpleX11)),
          Positioned(bottom: 100, left: -50, child: _buildGlowCircle(ArenaColor.dragonFruit)),

          // 2. MAIN CONTENT
          Positioned.fill(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(top: 110, bottom: 120), 
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  
                  // A. FILTER KATEGORI (CHIPS)
                  SizedBox(
                    height: 45,
                    child: Center(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        clipBehavior: Clip.none, 
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(width: 25), 
                            
                            ..._sportsFilters.map((sport) {
                              final isSelected = _selectedSport.toLowerCase() == sport.toLowerCase();
                              return Padding(
                                padding: const EdgeInsets.only(right: 12), 
                                child: GestureDetector(
                                  onTap: () => setState(() => _selectedSport = sport),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
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
                                      sport, 
                                      style: GoogleFonts.outfit(
                                        color: Colors.white.withOpacity(0.8),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // B. LIST BERITA
                  FutureBuilder<List<NewsEntry>>(
                    future: fetchNews(request),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Padding(
                          padding: EdgeInsets.only(top: 100),
                          child: Center(child: CircularProgressIndicator(color: ArenaColor.dragonFruit)),
                        );
                      } else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.only(top: 100),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(Icons.search_off, size: 50, color: Colors.white24),
                                SizedBox(height: 10),
                                Text("Tidak ada berita di kategori ini.", style: TextStyle(color: Colors.white38)),
                              ],
                            ),
                          ),
                        );
                      } else {
                        return ListView.builder(
                          shrinkWrap: true, 
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            final news = snapshot.data![index];
                            return NewsEntryTile( 
                              news: news,
                              onTap: () async {
                                final result = await Navigator.push(
                                  context, 
                                  MaterialPageRoute(builder: (context) => NewsDetailPage(news: news))
                                );
                                // Refresh jika kembali setelah edit/delete
                                if (result == true) setState(() {});
                              },
                            );
                          },
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),

          // 3. HEADER
          GlassyHeader(
            userProvider: userProvider,
            scaffoldKey: _scaffoldKey, 
            isHome: false, 
            title: "ARENA INVICTA",
            subtitle: "Latest News 📰",
          ),

          // 4. NAVBAR
          GlassyNavbar(
            userProvider: userProvider,
            fabIcon: Icons.grid_view_rounded, 
            onFabTap: () {
              Navigator.pop(context); 
            },
          ),
        ],
      ),
    );
  }
}