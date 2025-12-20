import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:intl/intl.dart';

import 'package:arena_invicta_mobile/main.dart';
import 'package:arena_invicta_mobile/global/widgets/app_colors.dart';
import 'package:arena_invicta_mobile/naufal_leagues/models/match.dart';
import 'package:arena_invicta_mobile/naufal_leagues/models/standing.dart';
import 'package:arena_invicta_mobile/naufal_leagues/models/team.dart';
import 'package:arena_invicta_mobile/naufal_leagues/services/league_service.dart';

class LeagueSummaryTab extends StatefulWidget {
  const LeagueSummaryTab({super.key});

  @override
  State<LeagueSummaryTab> createState() => _LeagueSummaryTabState();
}

class _LeagueSummaryTabState extends State<LeagueSummaryTab> {
  // Data State
  Match? _nextMatch;
  List<Standing> _topStandings = [];
  Map<int, String> _teamNameMap = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSummaryData();
  }

  Future<void> _fetchSummaryData() async {
    final request = context.read<CookieRequest>();
    try {
      // Panggil 3 API secara paralel agar cepat
      final results = await Future.wait([
        LeagueService().fetchMatches(request),
        LeagueService().fetchStandings(request),
        LeagueService().fetchTeams(request),
      ]);

      final matches = results[0] as List<Match>;
      final standings = results[1] as List<Standing>;
      final teams = results[2] as List<Team>;

      // 1. Mapping Nama Tim
      _teamNameMap = {for (var t in teams) t.pk: t.fields.name};

      // 2. Cari Next Match (Status != FINISHED, urutkan tanggal terdekat)
      final upcoming = matches.where((m) => m.fields.status != "FINISHED").toList();
      upcoming.sort((a, b) => a.fields.date.compareTo(b.fields.date));
      Match? next = upcoming.isNotEmpty ? upcoming.first : null;

      // 3. Cari Top 3 Klasemen
      // Asumsi API standing sudah terurut poinnya, kita ambil 3 pertama
      final top3 = standings.take(3).toList();

      if (mounted) {
        setState(() {
          _nextMatch = next;
          _topStandings = top3;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching summary: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: ArenaColor.dragonFruit));
    }

    return RefreshIndicator(
      onRefresh: _fetchSummaryData,
      color: ArenaColor.dragonFruit,
      backgroundColor: const Color(0xFF2A2045),
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // --- SECTION 1: NEXT MATCH ---
          const Text("Pertandingan Berikutnya", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _nextMatch != null 
              ? _buildNextMatchCard(_nextMatch!)
              : _buildEmptyState("Tidak ada jadwal mendatang."),
          
          const SizedBox(height: 30),

          // --- SECTION 2: TOP KLASEMEN ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Puncak Klasemen", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              // Indikator kecil 3 besar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: Colors.amber.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                child: const Text("Top 3", style: TextStyle(color: Colors.amber, fontSize: 12, fontWeight: FontWeight.bold)),
              )
            ],
          ),
          const SizedBox(height: 12),
          _topStandings.isNotEmpty 
              ? Column(children: _topStandings.map((s) => _buildStandingRow(s)).toList())
              : _buildEmptyState("Belum ada data klasemen."),
        ],
      ),
    );
  }

  // Widget: Kartu Big Match
  Widget _buildNextMatchCard(Match match) {
    final homeName = _teamNameMap[match.fields.homeTeam] ?? "Team Home";
    final awayName = _teamNameMap[match.fields.awayTeam] ?? "Team Away";
    final dateStr = DateFormat('EEEE, dd MMM yyyy').format(match.fields.date);
    final timeStr = DateFormat('HH:mm').format(match.fields.date);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [ArenaColor.dragonFruit, Color(0xFF2A2045)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: ArenaColor.dragonFruit.withOpacity(0.4), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Column(
        children: [
          Text(dateStr, style: const TextStyle(color: Colors.white70, fontSize: 12)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(homeName, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                child: Text(timeStr, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
              ),
              Expanded(child: Text(awayName, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16))),
            ],
          ),
          const SizedBox(height: 16),
          const Text("VS", style: TextStyle(color: Colors.white38, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // Widget: Baris Klasemen Mini
  Widget _buildStandingRow(Standing standing) {
    final teamName = _teamNameMap[standing.fields.team] ?? "Team";
    // Cari index untuk menentukan nomor urut (sedikit hacky karena data sudah di-slice)
    final index = _topStandings.indexOf(standing) + 1;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: index == 1 ? Colors.amber : Colors.white24, width: 4)),
      ),
      child: Row(
        children: [
          Text("$index", style: const TextStyle(color: Colors.white54, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(width: 16),
          Expanded(child: Text(teamName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
          Text("${standing.fields.points} Pts", style: const TextStyle(color: ArenaColor.dragonFruit, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String msg) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
      child: Text(msg, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white54)),
    );
  }
}