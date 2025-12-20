import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

import 'package:arena_invicta_mobile/main.dart'; 
import 'package:arena_invicta_mobile/global/widgets/app_colors.dart';
import 'package:arena_invicta_mobile/global/widgets/glassy_header.dart';
import 'package:arena_invicta_mobile/global/widgets/glassy_navbar.dart';
import 'package:arena_invicta_mobile/neal_auth/widgets/arena_invicta_drawer.dart';

// Import Tab Screens
import 'package:arena_invicta_mobile/naufal_leagues/screens/tabs/league_summary_tab.dart'; // <--- Import Baru
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

class _LeaguesPageState extends State<LeaguesPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    // Update Length menjadi 4
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final bool isAdmin = userProvider.isLoggedIn && 
        (userProvider.role == UserRole.admin || userProvider.role == UserRole.staff);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: ArenaColor.darkAmethyst,
      extendBody: true,
      drawer: ArenaInvictaDrawer(
        userProvider: userProvider,
        roleText: isAdmin ? "Admin" : "Member",
      ),
      body: Stack(
        children: [
          // --- KONTEN UTAMA (4 TAB) ---
          Padding(
            padding: const EdgeInsets.only(top: 170, bottom: 100), 
            child: TabBarView(
              controller: _tabController,
              children: const [
                LeagueSummaryTab(),   // Tab 1: Beranda / Summary
                LeagueStandingsTab(), // Tab 2: Klasemen
                LeagueMatchesTab(),   // Tab 3: Jadwal
                LeagueTeamsTab(),     // Tab 4: Tim
              ],
            ),
          ),

          // --- HEADER & TABBAR ---
          Positioned(
            top: 0, left: 0, right: 0,
            child: Container(
              color: ArenaColor.darkAmethyst, 
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GlassyHeader(
                    userProvider: userProvider,
                    scaffoldKey: _scaffoldKey,
                    title: "LEAGUES",
                    subtitle: "Season 23/24",
                    isHome: true,
                  ),
                  
                  // TabBar Scrollable (Karena ada 4 item, lebih aman isScrollable: true)
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: ArenaColor.darkAmethyst,
                      border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.1))),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      isScrollable: true, // Agar muat di layar kecil
                      tabAlignment: TabAlignment.start,
                      indicatorColor: ArenaColor.dragonFruit,
                      indicatorWeight: 3,
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.white60,
                      labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      tabs: const [
                        Tab(text: "BERANDA"),
                        Tab(text: "KLASEMEN"),
                        Tab(text: "JADWAL"),
                        Tab(text: "TIM"),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // --- NAVBAR ---
          GlassyNavbar(
            userProvider: userProvider,
            onFabTap: () => Navigator.of(context).popUntil((route) => route.isFirst),
            activeItem: NavbarItem.league,
          ),

          // --- FAB ADMIN ---
          if (isAdmin)
             Positioned(
              bottom: 110, 
              right: 20,
              child: FloatingActionButton(
                backgroundColor: ArenaColor.dragonFruit,
                child: const Icon(Icons.add, color: Colors.white),
                onPressed: () => _showAdminMenu(context),
              ),
             ),
        ],
      ),
    );
  }

  void _showAdminMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF2A2045),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Menu Admin", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _buildAdminItem(Icons.flag, "Tambah Tim Baru", () {
              Navigator.pop(ctx);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const TeamFormPage()));
            }),
            _buildAdminItem(Icons.leaderboard, "Tambah Data Klasemen", () {
              Navigator.pop(ctx);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const StandingFormPage()));
            }),
            _buildAdminItem(Icons.calendar_today, "Buat Jadwal Pertandingan", () {
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
      leading: Icon(icon, color: ArenaColor.dragonFruit),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      onTap: onTap,
    );
  }
}