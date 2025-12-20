import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

import 'package:arena_invicta_mobile/global/widgets/app_colors.dart';
import 'package:arena_invicta_mobile/naufal_leagues/models/team.dart'; 
// PERBAIKAN DI SINI: Gunakan 'as' untuk menghindari konflik nama 'Fields'
import 'package:arena_invicta_mobile/naufal_leagues/models/standing.dart' as standing_model;
import 'package:arena_invicta_mobile/naufal_leagues/services/league_service.dart';

class TeamDetailPage extends StatefulWidget {
  final Team team;

  const TeamDetailPage({super.key, required this.team});

  @override
  State<TeamDetailPage> createState() => _TeamDetailPageState();
}

class _TeamDetailPageState extends State<TeamDetailPage> {
  // Gunakan alias 'standing_model' untuk mengakses class Standing
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
        // Gunakan alias 'standing_model' saat membuat dummy object
        orElse: () => standing_model.Standing(
          model: "leagues.standing", 
          pk: -1, 
          // CONTOH KONFLIK SEBELUMNYA: 'Fields' sekarang spesifik milik standing_model
          fields: standing_model.Fields(
            league: 1, team: -1, season: "-", played: 0, win: 0, draw: 0, loss: 0, gf: 0, ga: 0, gd: 0, points: 0
          )
        ), 
      );

      if (stats.pk != -1) {
        setState(() => _teamStats = stats);
      }
    } catch (e) {
      debugPrint("Gagal load stats: $e");
    } finally {
      setState(() => _isLoadingStats = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ArenaColor.darkAmethyst,
      appBar: AppBar(
        title: Text(widget.team.fields.name),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // --- HEADER ---
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: ArenaColor.dragonFruit,
                    child: Text(
                      widget.team.fields.shortName,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.team.fields.name,
                    style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Didirikan Tahun ${widget.team.fields.foundedYear}",
                    style: const TextStyle(color: Colors.white54),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // --- STATISTIK ---
            const Align(
              alignment: Alignment.centerLeft,
              child: Text("Statistik Musim Ini", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 10),
            
            _isLoadingStats
              ? const Center(child: CircularProgressIndicator(color: ArenaColor.dragonFruit))
              : _teamStats != null
                  ? _buildStatCard(_teamStats!.fields) // Kirim fields dari objek standing
                  : Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
                      child: const Text("Tim ini belum memiliki data pertandingan di klasemen.", style: TextStyle(color: Colors.white54), textAlign: TextAlign.center),
                    ),
          ],
        ),
      ),
    );
  }

  // Parameter juga harus spesifik: Fields milik Standing
  Widget _buildStatCard(standing_model.Fields stats) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2045),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10)],
      ),
      child: Column(
        children: [
           Row(
             mainAxisAlignment: MainAxisAlignment.spaceAround,
             children: [
               _statItem("Main", stats.played),
               _statItem("Poin", stats.points, isHighlight: true),
               _statItem("GD", stats.gd),
             ],
           ),
           const Divider(color: Colors.white10, height: 30),
           Row(
             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
             children: [
               _statItemSmall("W", stats.win, Colors.greenAccent),
               _statItemSmall("D", stats.draw, Colors.grey),
               _statItemSmall("L", stats.loss, Colors.redAccent),
             ],
           )
        ],
      ),
    );
  }

  Widget _statItem(String label, int value, {bool isHighlight = false}) {
    return Column(
      children: [
        Text(value.toString(), style: TextStyle(color: isHighlight ? ArenaColor.dragonFruit : Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
      ],
    );
  }
  
  Widget _statItemSmall(String label, int value, Color color) {
    return Row(
      children: [
        Container(
          width: 10, height: 10, 
          decoration: BoxDecoration(color: color, shape: BoxShape.circle)
        ),
        const SizedBox(width: 6),
        Text("$value $label", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ],
    );
  }
}