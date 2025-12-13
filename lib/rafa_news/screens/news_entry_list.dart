import 'dart:ui'; // PENTING: Untuk ImageFilter
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
import 'package:arena_invicta_mobile/rafa_news/screens/news_form_page.dart'; 

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

  // --- STATE VARIABLES ---
  List<NewsEntry> _newsList = [];
  bool _isLoading = true; 
  bool _isError = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialCategory != null) {
      _selectedSport = widget.initialCategory!;
    }
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData({bool showLoading = true}) async {
    final request = context.read<CookieRequest>();
    
    if (showLoading) {
      setState(() {
        _isLoading = true;
        _isError = false;
      });
    }

    String url = '$baseUrl/show-news-json'; 
    if (_selectedSport != "All") {
      url += '?filter=${_selectedSport.toLowerCase()}';
    }

    try {
      final response = await request.get(url);
      List<NewsEntry> tempList = [];
      for (var d in response) {
        if (d != null) tempList.add(NewsEntry.fromJson(d));
      }

      if (mounted) {
        setState(() {
          _newsList = tempList;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching news: $e");
      if (mounted) {
        setState(() {
          _isError = true;
          _isLoading = false;
        });
      }
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
    final userProvider = context.watch<UserProvider>();

    String roleText = "Guest";
    if (userProvider.isLoggedIn) {
      if (userProvider.role == UserRole.admin) roleText = "Admin";
      else if (userProvider.role == UserRole.staff) roleText = "Writer";
      else roleText = "Member";
    }

    // Hitung posisi Sticky Header (Header + Chips)
    // Header ~70-80px (tergantung status bar)
    final double headerTop = MediaQuery.of(context).padding.top + 70; 
    // Tinggi area Chips ~50px
    final double listTopPadding = headerTop + 50;

    return Scaffold(
      key: _scaffoldKey,
      drawer: ArenaInvictaDrawer(
        userProvider: userProvider,
        roleText: roleText,
      ),
      backgroundColor: ArenaColor.darkAmethyst,
      resizeToAvoidBottomInset: false, 
      
      floatingActionButton: (userProvider.isLoggedIn && (userProvider.role == UserRole.staff || userProvider.role == UserRole.admin))
          ? Padding(
              padding: const EdgeInsets.only(bottom: 110.0, right: 10.0), 
              child: FloatingActionButton(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const NewsFormPage()),
                  );
                  if (result == true) {
                    _loadData(showLoading: false);
                  }
                },
                backgroundColor: ArenaColor.dragonFruit,
                child: const Icon(Icons.add, color: Colors.white),
              ),
            )
          : null,

      body: Stack(
        children: [
          // 1. Background Glows
          Positioned(top: -50, right: -50, child: _buildGlowCircle(ArenaColor.purpleX11)),
          Positioned(bottom: 100, left: -50, child: _buildGlowCircle(ArenaColor.dragonFruit)),

          // 2. MAIN CONTENT (LIST BERITA)
          // Berada di layer paling bawah agar scroll di belakang header
          Positioned.fill(
            child: SingleChildScrollView(
              // Padding atas disesuaikan agar item pertama muncul pas di bawah chips
              padding: EdgeInsets.only(top: listTopPadding + 10, bottom: 120), 
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_isLoading)
                    const Padding(
                      padding: EdgeInsets.only(top: 100),
                      child: Center(child: CircularProgressIndicator(color: ArenaColor.dragonFruit)),
                    )
                  else if (_isError || _newsList.isEmpty)
                    const Padding(
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
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true, 
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: _newsList.length,
                      itemBuilder: (context, index) {
                        final news = _newsList[index];
                        return NewsEntryTile( 
                          news: news,
                          onTap: () async {
                            await Navigator.push(
                              context, 
                              MaterialPageRoute(builder: (context) => NewsDetailPage(news: news))
                            );
                            // Silent refresh saat kembali
                            _loadData(showLoading: false);
                          },
                        );
                      },
                    ),
                ],
              ),
            ),
          ),

          // 3. HEADER (TITLE)
          GlassyHeader(
            userProvider: userProvider,
            scaffoldKey: _scaffoldKey, 
            isHome: false, 
            title: "ARENA INVICTA",
            subtitle: "Latest News",
          ),

          // 4. STICKY CATEGORY CHIPS (GLASSY STYLE)
          // Posisinya Fixed, Container Transparan, Buttonnya Glassy
          Positioned(
            top: headerTop, 
            left: 0,
            right: 0,
            child: SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: _sportsFilters.length,
                itemBuilder: (context, index) {
                  final sport = _sportsFilters[index];
                  final isSelected = _selectedSport.toLowerCase() == sport.toLowerCase();
                  
                  return Padding(
                    padding: const EdgeInsets.only(right: 12), 
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _selectedSport = sport);
                        _loadData(showLoading: true);
                      },
                      // --- EFEK GLASSY UNTUK SETIAP BUTTON ---
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), // Blur
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              // Warna semi-transparan
                              color: isSelected 
                                  ? ArenaColor.dragonFruit.withOpacity(0.8) 
                                  : Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected 
                                    ? ArenaColor.dragonFruit 
                                    : Colors.white.withOpacity(0.1),
                              ),
                            ),
                            child: Text(
                              sport, 
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // 5. NAVBAR
          GlassyNavbar(
            userProvider: userProvider,
            fabIcon: Icons.grid_view_rounded, 
            activeItem: NavbarItem.news,
            onFabTap: () {
              Navigator.pop(context); 
            },
          ),
        ],
      ),
    );
  }
}