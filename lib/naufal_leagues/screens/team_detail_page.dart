import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

import 'package:arena_invicta_mobile/global/widgets/app_colors.dart';
import 'package:arena_invicta_mobile/naufal_leagues/models/team.dart'; 
import 'package:arena_invicta_mobile/naufal_leagues/models/standing.dart' as standing_model;
import 'package:arena_invicta_mobile/naufal_leagues/services/league_service.dart';

class TeamDetailPage extends StatefulWidget {
  final Team team;

  const TeamDetailPage({super.key, required this.team});

  @override
  State<TeamDetailPage> createState() => _TeamDetailPageState();
}

class _TeamDetailPageState extends State<TeamDetailPage> {
  standing_model.Standing? _teamStats;
  bool _isLoadingStats = true;

  @override
  void initState() {
    super.initState();
    _fetchTeamStats();
  }

  Future<void> _fetchTeamStats() async {
    final request = context.read<CookieRequest>();
    try {
      final standings = await LeagueService().fetchStandings(request);
      
      final stats = standings.firstWhere(
        (s) => s.fields.team == widget.team.pk,
        orElse: () => standing_model.Standing(
          model: "leagues.standing", 
          pk: -1, 
          fields: standing_model.Fields(
            league: 1, team: -1, season: "-", played: 0, win: 0, draw: 0, loss: 0, gf: 0, ga: 0, gd: 0, points: 0
          )
        ), 
      );

      if (stats.pk != -1) {
        if (mounted) setState(() => _teamStats = stats);
      }
    } catch (e) {
      debugPrint("Gagal load stats: $e");
    } finally {
      if (mounted) setState(() => _isLoadingStats = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ArenaColor.darkAmethyst,
      appBar: AppBar(
        title: const Text("Detail Tim"), // Title umum agar tidak redundan
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // --- HEADER NAMA TIM (Tanpa Logo & Tahun) ---
            const SizedBox(height: 20),
            Text(
              widget.team.fields.name,
              style: const TextStyle(
                color: Colors.white, 
                fontSize: 28, // Font lebih besar agar menonjol
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: ArenaColor.dragonFruit.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: ArenaColor.dragonFruit),
              ),
              child: Text(
                widget.team.fields.shortName,
                style: const TextStyle(color: ArenaColor.dragonFruit, fontWeight: FontWeight.bold),
              ),
            ),
            
            const SizedBox(height: 40),

            // --- STATISTIK ---
            const Align(
              alignment: Alignment.centerLeft,
              child: Text("Statistik Musim Ini", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 16),
            
            _isLoadingStats
              ? const Center(child: CircularProgressIndicator(color: ArenaColor.dragonFruit))
              : _teamStats != null
                  ? _buildStatCard(_teamStats!.fields)
                  : Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05), 
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Column(
                        children: const [
                          Icon(Icons.query_stats, color: Colors.white24, size: 48),
                          SizedBox(height: 12),
                          Text(
                            "Belum ada data pertandingan di klasemen.", 
                            style: TextStyle(color: Colors.white54), 
                            textAlign: TextAlign.center
                          ),
                        ],
                      ),
                    ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(standing_model.Fields stats) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF2A2045),
            const Color(0xFF2A2045).withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Column(
        children: [
           // Main Stats Row
           Row(
             mainAxisAlignment: MainAxisAlignment.spaceBetween,
             children: [
               _statItemLarge("Poin", stats.points, true),
               Container(width: 1, height: 40, color: Colors.white10),
               _statItemLarge("Main", stats.played, false),
               Container(width: 1, height: 40, color: Colors.white10),
               _statItemLarge("GD", stats.gd, false),
             ],
           ),
           const SizedBox(height: 24),
           const Divider(color: Colors.white10),
           const SizedBox(height: 24),
           // Detail W-D-L Row
           Row(
             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
             children: [
               _statItemSmall("Menang", stats.win, Colors.greenAccent),
               _statItemSmall("Seri", stats.draw, Colors.grey),
               _statItemSmall("Kalah", stats.loss, Colors.redAccent),
             ],
           )
        ],
      ),
    );
  }

  Widget _statItemLarge(String label, int value, bool isPrimary) {
    return Column(
      children: [
        Text(
          value.toString(), 
          style: TextStyle(
            color: isPrimary ? ArenaColor.dragonFruit : Colors.white, 
            fontSize: 32, 
            fontWeight: FontWeight.bold
          )
        ),
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 14)),
      ],
    );
  }
  
  Widget _statItemSmall(String label, int value, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Text(
            "$value", 
            style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
      ],
    );
  }
}