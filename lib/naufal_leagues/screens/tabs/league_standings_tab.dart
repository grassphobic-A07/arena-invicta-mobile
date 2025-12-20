import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

import 'package:arena_invicta_mobile/main.dart'; // UserProvider
import 'package:arena_invicta_mobile/global/widgets/app_colors.dart';
import 'package:arena_invicta_mobile/naufal_leagues/services/league_service.dart';
import 'package:arena_invicta_mobile/naufal_leagues/models/standing.dart';
import 'package:arena_invicta_mobile/naufal_leagues/screens/standing_form_page.dart';

class LeagueStandingsTab extends StatefulWidget {
  const LeagueStandingsTab({super.key});

  @override
  State<LeagueStandingsTab> createState() => _LeagueStandingsTabState();
}

class _LeagueStandingsTabState extends State<LeagueStandingsTab> {
  late Future<List<Standing>> _futureStandings;
  final Map<int, String> _teamNameMap = {};

  @override
  void initState() {
    super.initState();
    final request = context.read<CookieRequest>();
    _futureStandings = _fetchAllData(request);
  }

  Future<List<Standing>> _fetchAllData(CookieRequest request) async {
    try {
      final teams = await LeagueService().fetchTeams(request);
      _teamNameMap.clear();
      for (var team in teams) {
        _teamNameMap[team.pk] = team.fields.name;
      }
      return await LeagueService().fetchStandings(request);
    } catch (e) {
      throw Exception("Gagal: $e");
    }
  }

  Future<void> _refresh() async {
    setState(() {
      final request = context.read<CookieRequest>();
      _futureStandings = _fetchAllData(request);
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final isAdmin = userProvider.isLoggedIn && 
        (userProvider.role == UserRole.admin || userProvider.role == UserRole.staff);

    return Column(
      children: [
        // --- 1. HEADER TABEL ---
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3), // Latar header lebih gelap
            border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.1))),
          ),
          child: Row(
            children: [
              _headerText("Pos", width: 35),
              Expanded(child: _headerText("Klub", align: TextAlign.left)),
              _headerText("M", width: 35),   // Main
              _headerText("M", width: 35),   // Menang (Opsional)
              _headerText("K", width: 35),   // Kalah (Opsional)
              _headerText("GD", width: 40),  // Goal Difference
              _headerText("Pts", width: 40, isBold: true), // Poin
            ],
          ),
        ),

        // --- 2. ISI TABEL (LIST) ---
        Expanded(
          child: FutureBuilder<List<Standing>>(
            future: _futureStandings,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: ArenaColor.dragonFruit));
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return RefreshIndicator(
                  onRefresh: _refresh,
                  child: ListView(
                    children: const [
                       SizedBox(height: 100),
                       Center(child: Text("Belum ada data klasemen.", style: TextStyle(color: Colors.white70))),
                    ],
                  ),
                );
              }

              final data = snapshot.data!;
              
              return RefreshIndicator(
                onRefresh: _refresh,
                color: ArenaColor.dragonFruit,
                backgroundColor: const Color(0xFF2A2045),
                child: ListView.builder(
                  padding: EdgeInsets.zero, // Padding dihandle container per item
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    final standing = data[index];
                    final teamName = _teamNameMap[standing.fields.team] ?? "Team";
                    
                    // Logic Warna Posisi
                    Color rowColor = Colors.transparent;
                    Color posColor = Colors.white;
                    
                    if (index == 0) {
                      posColor = Colors.amberAccent; // Juara = Emas
                    } else if (index >= data.length - 3 && data.length > 5) {
                      posColor = Colors.redAccent;   // Degradasi = Merah
                    }

                    return InkWell(
                      // Admin bisa tap untuk edit/delete
                      onTap: isAdmin ? () => _showOptions(context, standing, teamName) : null,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        decoration: BoxDecoration(
                          color: rowColor,
                          border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.05))),
                        ),
                        child: Row(
                          children: [
                            // Posisi
                            SizedBox(
                              width: 35,
                              child: Text(
                                "${index + 1}",
                                style: TextStyle(color: posColor, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            
                            // Nama Tim
                            Expanded(
                              child: Text(
                                teamName,
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            
                            // Statistik
                            _cellText("${standing.fields.played}", width: 35),
                            _cellText("${standing.fields.win}", width: 35, color: Colors.white54),
                            _cellText("${standing.fields.loss}", width: 35, color: Colors.white54),
                            _cellText("${standing.fields.gd}", width: 40, color: standing.fields.gd > 0 ? Colors.greenAccent : (standing.fields.gd < 0 ? Colors.redAccent : Colors.white)),
                            _cellText("${standing.fields.points}", width: 40, isBold: true),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // Helper Widgets
  Widget _headerText(String text, {double? width, TextAlign align = TextAlign.center, bool isBold = false}) {
    final style = TextStyle(
      color: Colors.white54, 
      fontSize: 12, 
      fontWeight: isBold ? FontWeight.bold : FontWeight.normal
    );
    
    if (width != null) {
      return SizedBox(width: width, child: Text(text, textAlign: align, style: style));
    }
    return Text(text, textAlign: align, style: style);
  }

  Widget _cellText(String text, {double? width, Color color = Colors.white, bool isBold = false}) {
    final style = TextStyle(
      color: color, 
      fontSize: 13, 
      fontWeight: isBold ? FontWeight.bold : FontWeight.normal
    );

    if (width != null) {
      return SizedBox(width: width, child: Text(text, textAlign: TextAlign.center, style: style));
    }
    return Text(text, style: style);
  }

  void _showOptions(BuildContext context, Standing standing, String teamName) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF2A2045),
        title: Text("Kelola $teamName", style: const TextStyle(color: Colors.white)),
        actions: [
          TextButton(
            child: const Text("Edit Statistik", style: TextStyle(color: Colors.blueAccent)),
            onPressed: () async {
              Navigator.pop(ctx);
              final res = await Navigator.push(
                context, 
                MaterialPageRoute(builder: (_) => StandingFormPage(standing: standing))
              );
              if (res == true) _refresh();
            },
          ),
          TextButton(
            child: const Text("Hapus", style: TextStyle(color: Colors.redAccent)),
            onPressed: () async {
              Navigator.pop(ctx);
              _confirmDelete(context, standing);
            },
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, Standing standing) {
     final req = context.read<CookieRequest>();
     LeagueService().deleteStanding(req, standing.pk).then((_) {
       _refresh();
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Data dihapus")));
     });
  }
}