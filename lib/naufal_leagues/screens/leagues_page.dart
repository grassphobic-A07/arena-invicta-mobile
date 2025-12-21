import 'dart:ui'; // Wajib untuk ImageFilter
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

import 'package:arena_invicta_mobile/main.dart'; 
import 'package:arena_invicta_mobile/global/widgets/app_colors.dart';
import 'package:arena_invicta_mobile/global/widgets/glassy_header.dart';
import 'package:arena_invicta_mobile/global/widgets/glassy_navbar.dart';
import 'package:arena_invicta_mobile/neal_auth/widgets/arena_invicta_drawer.dart';

// Import Tab Screens
import 'package:arena_invicta_mobile/naufal_leagues/screens/tabs/league_summary_tab.dart';
import 'package:arena_invicta_mobile/naufal_leagues/screens/tabs/league_standings_tab.dart';
import 'package:arena_invicta_mobile/naufal_leagues/screens/tabs/league_matches_tab.dart';
import 'package:arena_invicta_mobile/naufal_leagues/screens/tabs/league_teams_tab.dart';

import 'package:arena_invicta_mobile/naufal_leagues/screens/match_form_page.dart';
import 'package:arena_invicta_mobile/naufal_leagues/screens/team_form_page.dart';
import 'package:arena_invicta_mobile/naufal_leagues/screens/standing_form_page.dart';

class LeaguesPage extends StatefulWidget {
  const LeaguesPage({super.key});

  @override
  State<LeaguesPage> createState() => _LeaguesPageState();
}

class _LeaguesPageState extends State<LeaguesPage> {
  // CATATAN: Kita menghapus manual _tabController agar bisa pakai DefaultTabController
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // --- EFEK GLOW BACKGROUND ---
  Widget _buildGlowCircle(Color color) {
    return Container(
      width: 300,
      height: 300,
      decoration: BoxDecoration(
        color: color.withOpacity(0.2), 
        shape: BoxShape.circle,
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80), 
        child: const SizedBox.shrink(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final bool isAdmin = userProvider.isLoggedIn && 
        (userProvider.role == UserRole.admin || userProvider.role == UserRole.staff);
    
    final double headerHeight = MediaQuery.of(context).padding.top + 130; 

    // PERBAIKAN UTAMA DI SINI:
    // Kita bungkus Scaffold dengan DefaultTabController.
    // Ini memungkinkan widget anak (seperti Summary Tab) memanggil:
    // DefaultTabController.of(context).animateTo(index)
    return DefaultTabController(
      length: 4, // Jumlah Tab
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: ArenaColor.darkAmethyst, 
        extendBody: true, 
        extendBodyBehindAppBar: true, 
        drawer: ArenaInvictaDrawer(
          userProvider: userProvider,
          roleText: isAdmin ? "Admin" : "Member",
        ),
        body: Stack(
          children: [
            // --- LAYER 0: GLOW BACKGROUND ---
            Positioned(top: -100, left: -100, child: _buildGlowCircle(ArenaColor.dragonFruit)),
            Positioned(bottom: -100, right: -100, child: _buildGlowCircle(ArenaColor.purpleX11)),

            // --- LAYER 1: KONTEN UTAMA (TabBarView) ---
            Padding(
              padding: EdgeInsets.only(top: headerHeight, bottom: 0),
              child: const TabBarView(
                // controller: _tabController, <-- HAPUS INI (Biar otomatis)
                children: [
                  LeagueSummaryTab(),   // Index 0
                  LeagueMatchesTab(),   // Index 1
                  LeagueStandingsTab(), // Index 2
                  LeagueTeamsTab(),     // Index 3
                ],
              ),
            ),

            // --- LAYER 2: HEADER & TABBAR (GLASSY) ---
            Positioned(
              top: 0, left: 0, right: 0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 2.A: Header Global
                  GlassyHeader(
                    userProvider: userProvider,
                    scaffoldKey: _scaffoldKey,
                    isHome: false,           
                    title: "Arena Invicta",  
                    subtitle: "Leagues",     
                  ),
                  
                  // 2.B: TabBar Transparan
                  ClipRRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), 
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05), 
                          border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.1))),
                        ),
                        child: const TabBar(
                          // controller: _tabController, <-- HAPUS INI JUGA
                          isScrollable: true,
                          tabAlignment: TabAlignment.start,
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          indicatorColor: ArenaColor.dragonFruit,
                          indicatorWeight: 3,
                          labelColor: Colors.white,
                          unselectedLabelColor: Colors.white60,
                          labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          dividerColor: Colors.transparent,
                          tabs: [
                            Tab(text: "Ringkasan"),
                            Tab(text: "Pertandingan"),
                            Tab(text: "Klasemen"),
                            Tab(text: "Tim"),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // --- LAYER 3: NAVBAR (Floating) ---
            GlassyNavbar(
              userProvider: userProvider,
              onFabTap: () => Navigator.of(context).popUntil((route) => route.isFirst),
              activeItem: NavbarItem.league,
            ),

            // --- LAYER 4: FAB ADMIN ---
            if (isAdmin)
               Positioned(
                bottom: 110, 
                right: 20,
                child: FloatingActionButton(
                  heroTag: "league_admin_fab",
                  backgroundColor: ArenaColor.dragonFruit,
                  child: const Icon(Icons.add, color: Colors.white),
                  onPressed: () => _showAdminMenu(context),
                ),
               ),
          ],
        ),
      ),
    );
  }

  void _showAdminMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: const Color(0xFF2A2045).withOpacity(0.95),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 20), decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
            const Text("Menu Admin", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _buildAdminItem(Icons.flag_rounded, "Tambah Tim Baru", () {
              Navigator.pop(ctx);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const TeamFormPage()));
            }),
            _buildAdminItem(Icons.leaderboard_rounded, "Tambah Data Klasemen", () {
              Navigator.pop(ctx);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const StandingFormPage()));
            }),
            _buildAdminItem(Icons.calendar_month_rounded, "Buat Jadwal Pertandingan", () {
              Navigator.pop(ctx);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const MatchFormPage()));
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: ArenaColor.dragonFruit.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: ArenaColor.dragonFruit),
      ),
      title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      trailing: const Icon(Icons.chevron_right, color: Colors.white24),
      onTap: onTap,
    );
  }
}