import 'package:flutter/material.dart';
import 'package:arena_invicta_mobile/global/widgets/app_colors.dart';
import 'package:arena_invicta_mobile/naufal_leagues/screens/tabs/league_summary_tab.dart';
import 'package:arena_invicta_mobile/naufal_leagues/screens/tabs/league_matches_tab.dart';
import 'package:arena_invicta_mobile/naufal_leagues/screens/tabs/league_standings_tab.dart';
import 'package:arena_invicta_mobile/naufal_leagues/screens/tabs/league_teams_tab.dart';

class LeagueDashboardPage extends StatefulWidget {
  const LeagueDashboardPage({super.key});

  @override
  State<LeagueDashboardPage> createState() => _LeagueDashboardPageState();
}

class _LeagueDashboardPageState extends State<LeagueDashboardPage> {
  @override
  Widget build(BuildContext context) {
    // DefaultTabController adalah pengatur navigasi 4 tab
    return DefaultTabController(
      length: 4, // Jumlah tab ada 4
      child: Scaffold(
        appBar: AppBar(
          title: const Text("League Dashboard", style: TextStyle(color: Colors.white)),
          backgroundColor: ArenaColor.darkAmethyst, // Sesuaikan warna tema
          iconTheme: const IconThemeData(color: Colors.white),
          // Bagian TabBar di bawah AppBar
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white54,
            indicatorColor: ArenaColor.dragonFruit, // Warna garis bawah tab aktif
            isScrollable: true, // Agar tab bisa digeser jika layar sempit
            tabs: [
              Tab(text: "Ringkasan"),
              Tab(text: "Pertandingan"),
              Tab(text: "Klasemen"),
              Tab(text: "Tim"),
            ],
          ),
        ),
        // Bagian Isi (Body) yang berubah sesuai Tab yang dipilih
        body: const TabBarView(
          children: [
            // Tab 1: Ringkasan
            LeagueSummaryTab(),
            
            // Tab 2: Pertandingan
            LeagueMatchesTab(),
            
            // Tab 3: Klasemen
            LeagueStandingsTab(),
            
            // Tab 4: Tim
            LeagueTeamsTab(),
          ],
        ),
      ),
    );
  }
}