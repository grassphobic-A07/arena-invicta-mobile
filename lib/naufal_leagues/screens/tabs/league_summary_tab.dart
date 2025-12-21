import 'dart:ui'; // Wajib untuk ImageFilter
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:intl/intl.dart';

import 'package:arena_invicta_mobile/global/widgets/app_colors.dart';
import 'package:arena_invicta_mobile/naufal_leagues/services/league_service.dart';
// Import Model & Detail Pages
import 'package:arena_invicta_mobile/naufal_leagues/models/team.dart' as team_model;
import 'package:arena_invicta_mobile/naufal_leagues/screens/team_detail_page.dart';
import 'package:arena_invicta_mobile/naufal_leagues/screens/match_detail_page.dart';

class LeagueSummaryTab extends StatefulWidget {
  const LeagueSummaryTab({super.key});

  @override
  State<LeagueSummaryTab> createState() => _LeagueSummaryTabState();
}

class _LeagueSummaryTabState extends State<LeagueSummaryTab> {
  late Future<Map<String, dynamic>> _dashboardFuture;
  final LeagueService _service = LeagueService();

  @override
  void initState() {
    super.initState();
    final request = context.read<CookieRequest>();
    _dashboardFuture = _service.fetchDashboardData(request);
  }

  Future<void> _refreshData() async {
    final request = context.read<CookieRequest>();
    setState(() {
      _dashboardFuture = _service.fetchDashboardData(request);
    });
  }

  // --- NAVIGASI KE TEAM DETAIL ---
  void _navigateToTeamDetail(int teamId, String teamName) {
    final tempTeam = team_model.Team(
      model: "leagues.team",
      pk: teamId,
      fields: team_model.Fields(
        name: teamName,
        league: 0,
        shortName: "",
        foundedYear: null,
      ),
    );

    Navigator.push(
      context, 
      MaterialPageRoute(builder: (context) => TeamDetailPage(team: tempTeam)),
    );
  }

  // --- NAVIGASI KE MATCH DETAIL ---
  void _navigateToMatchDetail(Map<String, dynamic> matchData) {
    int matchId = matchData['id'] ?? 0;
    if (matchId != 0) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MatchDetailPage(matchId: matchId)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("ID Pertandingan tidak valid."))
      );
    }
  }

  // --- FUNGSI PINDAH TAB (JIKA TOMBOL LIHAT SEMUA DIKLIK) ---
  void _switchToTab(int index) {
    // DefaultTabController digunakan untuk mengontrol TabBar dari child widget
    try {
      DefaultTabController.of(context).animateTo(index);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Navigasi tab tidak tersedia saat ini."))
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refreshData,
      color: ArenaColor.dragonFruit,
      child: FutureBuilder<Map<String, dynamic>>(
        future: _dashboardFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: ArenaColor.dragonFruit));
          } else if (snapshot.hasError || !snapshot.hasData || snapshot.data!['status'] == 'error') {
             return const Center(child: Text("Gagal memuat data dashboard.", style: TextStyle(color: Colors.white70)));
          }

          final data = snapshot.data!;
          // Ambil top 5 saja untuk ringkasan
          final standings = (data['standings'] as List).take(5).toList(); 
          final recentMatches = data['recent_matches'] as List;
          final upcomingMatches = data['upcoming_matches'] as List;
          
          const leagueName = "Premier League"; 

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 100), 
            children: [
              // --- HERO TITLE ---
              _buildGradientTitle(leagueName),
              const SizedBox(height: 24),

              // --- KLASEMEN CARD (Standings) ---
              _buildGlassCard(
                title: "Standings", // Judul Baru
                icon: Icons.emoji_events_rounded, // Icon Piala
                iconColor: Colors.amber,
                // Tombol Lihat Semua -> Pindah ke Tab Standings (Index 2)
                onSeeAll: () => _switchToTab(2), 
                child: _buildStandingsTable(standings),
              ),
              const SizedBox(height: 24),

              // --- MATCH SUMMARY CARD ---
              _buildGlassCard(
                title: "Match Summary",
                icon: Icons.sports_soccer_rounded,
                iconColor: ArenaColor.dragonFruit,
                // Tombol Lihat Semua -> Pindah ke Tab Matches (Index 1)
                onSeeAll: () => _switchToTab(1),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionLabel("Hasil Terkini", Colors.grey),
                    if (recentMatches.isEmpty) 
                      const Padding(padding: EdgeInsets.all(12), child: Text("Belum ada pertandingan selesai.", style: TextStyle(color: Colors.white38, fontSize: 12))),
                    ...recentMatches.map((m) => _buildMatchItem(m, isFinished: true)),

                    const SizedBox(height: 20),
                    
                    _buildSectionLabel("Jadwal Mendatang", ArenaColor.dragonFruit),
                    if (upcomingMatches.isEmpty) 
                       const Padding(padding: EdgeInsets.all(12), child: Text("Belum ada jadwal mendatang.", style: TextStyle(color: Colors.white38, fontSize: 12))),
                    ...upcomingMatches.map((m) => _buildMatchItem(m, isFinished: false)),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // --- WIDGET HELPER UI MEWAH ---

  Widget _buildGradientTitle(String text) {
    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        colors: [Colors.white, ArenaColor.purpleX11, ArenaColor.dragonFruit],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(bounds),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 32, 
          fontWeight: FontWeight.w900, 
          color: Colors.white, 
          letterSpacing: -1.0,
        ),
      ),
    );
  }

  // Update: Menambahkan parameter onSeeAll untuk tombol navigasi
  Widget _buildGlassCard({
    required String title, 
    required IconData icon, 
    required Color iconColor, 
    required Widget child,
    VoidCallback? onSeeAll, // Callback opsional
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF2A1B54).withOpacity(0.6), 
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              )
            ]
          ),
          child: Column(
            children: [
              // Card Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.2),
                  border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.05))),
                ),
                child: Row(
                  children: [
                    Icon(icon, color: iconColor, size: 22),
                    const SizedBox(width: 10),
                    Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    const Spacer(),
                    
                    // TOMBOL LIHAT SEMUA (Kecil & Elegan)
                    if (onSeeAll != null)
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: onSeeAll,
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white.withOpacity(0.1)),
                            ),
                            child: Row(
                              children: const [
                                Text(
                                  "Lihat Semua",
                                  style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                                SizedBox(width: 4),
                                Icon(Icons.arrow_forward_ios_rounded, color: Colors.white70, size: 10),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              // Card Body
              Padding(
                padding: const EdgeInsets.all(16),
                child: child,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStandingsTable(List<dynamic> standings) {
    if (standings.isEmpty) return const Text("No data.", style: TextStyle(color: Colors.white38));

    return Column(
      children: [
        // Table Header
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: const [
              SizedBox(width: 25, child: Text("#", style: TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.bold))),
              Expanded(child: Text("TIM", style: TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.bold))),
              SizedBox(width: 30, child: Center(child: Text("M", style: TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.bold)))),
              SizedBox(width: 30, child: Center(child: Text("GD", style: TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.bold)))),
              SizedBox(width: 35, child: Center(child: Text("PTS", style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)))),
            ],
          ),
        ),
        const Divider(color: Colors.white10, height: 1),
        
        // Table Rows
        ...standings.asMap().entries.map((entry) {
          int idx = entry.key + 1;
          var team = entry.value;
          bool isTop = idx <= 4; 

          return Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.02))),
            ),
            child: Row(
              children: [
                SizedBox(width: 25, child: Text("$idx", style: TextStyle(color: isTop ? ArenaColor.dragonFruit : Colors.white54, fontWeight: FontWeight.bold, fontSize: 13))),
                
                // Nama Tim
                Expanded(
                  child: InkWell(
                    onTap: () {
                      int teamId = team['team_id'] ?? team['id'] ?? 0;
                      if (teamId != 0) {
                        _navigateToTeamDetail(teamId, team['team_name']);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Detail tim tidak tersedia."))
                        );
                      }
                    },
                    child: Text(
                      team['team_name'], 
                      style: const TextStyle(
                        color: ArenaColor.dragonFruit,
                        fontWeight: FontWeight.w600, 
                        fontSize: 13
                      ), 
                      overflow: TextOverflow.ellipsis
                    ),
                  )
                ),

                SizedBox(width: 30, child: Center(child: Text("${team['played']}", style: const TextStyle(color: Colors.white70, fontSize: 12)))),
                SizedBox(width: 30, child: Center(child: Text("${team['gd']}", style: const TextStyle(color: Colors.white70, fontSize: 12)))),
                Container(
                  width: 35,
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  decoration: BoxDecoration(
                    color: ArenaColor.purpleX11.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Center(child: Text("${team['points']}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12))),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildSectionLabel(String label, Color dotColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 4),
      child: Row(
        children: [
          Container(width: 6, height: 6, decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Text(label.toUpperCase(), style: TextStyle(color: dotColor, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        ],
      ),
    );
  }

  Widget _buildMatchItem(dynamic match, {required bool isFinished}) {
    DateTime date = DateTime.parse(match['date']);
    String formattedDate = DateFormat('d MMM').format(date);
    String timeOrStatus = isFinished ? "FT" : DateFormat('HH:mm').format(date);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isFinished ? Colors.black.withOpacity(0.2) : ArenaColor.purpleX11.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isFinished ? Colors.white.withOpacity(0.05) : ArenaColor.purpleX11.withOpacity(0.2)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _navigateToMatchDetail(match),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Text(formattedDate, style: const TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold)),
                      Text(timeOrStatus, style: TextStyle(color: isFinished ? Colors.white : ArenaColor.dragonFruit, fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: Text(match['home_team'], textAlign: TextAlign.right, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13))),
                      
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black26,
                          borderRadius: BorderRadius.circular(4),
                          border: isFinished ? Border.all(color: Colors.white10) : null
                        ),
                        child: Text(
                          isFinished ? "${match['home_score']} - ${match['away_score']}" : "VS",
                          style: TextStyle(color: isFinished ? Colors.white : Colors.white38, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ),

                      Expanded(child: Text(match['away_team'], textAlign: TextAlign.left, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13))),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}