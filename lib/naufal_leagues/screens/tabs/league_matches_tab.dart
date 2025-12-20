import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import 'package:arena_invicta_mobile/main.dart'; // UserProvider
import 'package:arena_invicta_mobile/global/widgets/app_colors.dart';
import 'package:arena_invicta_mobile/naufal_leagues/models/match.dart';
import 'package:arena_invicta_mobile/naufal_leagues/services/league_service.dart';
import 'package:arena_invicta_mobile/naufal_leagues/screens/match_form_page.dart';

class LeagueMatchesTab extends StatefulWidget {
  const LeagueMatchesTab({super.key});

  @override
  State<LeagueMatchesTab> createState() => _LeagueMatchesTabState();
}

class _LeagueMatchesTabState extends State<LeagueMatchesTab> {
  // State Data
  List<Match> _allMatches = [];
  List<Match> _filteredMatches = [];
  bool _isLoading = true;
  
  // State Filter & Search
  int _filterIndex = 0; // 0=Semua, 1=Terjadwal, 2=Selesai
  String _searchQuery = "";
  final Map<int, String> _teamNameMap = {}; 

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    final request = context.read<CookieRequest>();
    try {
      // 1. Ambil Data Tim (mapping nama)
      final teams = await LeagueService().fetchTeams(request);
      _teamNameMap.clear();
      for (var t in teams) {
        _teamNameMap[t.pk] = t.fields.name;
      }

      // 2. Ambil Data Matches
      final matches = await LeagueService().fetchMatches(request);
      
      if (mounted) {
        setState(() {
          _allMatches = matches;
          _applyFilter(); // Filter data yang baru masuk
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- LOGIKA FILTER GABUNGAN (STATUS + SEARCH) ---
  void _applyFilter() {
    setState(() {
      _filteredMatches = _allMatches.where((match) {
        // 1. Cek Status
        bool statusPass = true;
        if (_filterIndex == 1) { // Terjadwal
          statusPass = match.fields.status != "FINISHED";
        } else if (_filterIndex == 2) { // Selesai
          statusPass = match.fields.status == "FINISHED";
        }

        // 2. Cek Search Query (Nama Home ATAU Away)
        bool searchPass = true;
        if (_searchQuery.isNotEmpty) {
          final homeName = _teamNameMap[match.fields.homeTeam] ?? "";
          final awayName = _teamNameMap[match.fields.awayTeam] ?? "";
          final query = _searchQuery.toLowerCase();
          
          searchPass = homeName.toLowerCase().contains(query) || 
                       awayName.toLowerCase().contains(query);
        }

        return statusPass && searchPass;
      }).toList();
    });
  }

  void _onFilterChanged(int index) {
    setState(() {
      _filterIndex = index;
      _applyFilter();
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final isAdmin = userProvider.isLoggedIn && 
        (userProvider.role == UserRole.admin || userProvider.role == UserRole.staff);

    return Column(
      children: [
        // --- 1. SEARCH BAR ---
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
          child: TextField(
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: "Cari klub ...",
              hintStyle: const TextStyle(color: Colors.white54),
              prefixIcon: const Icon(Icons.search, color: Colors.white54),
              filled: true,
              fillColor: Colors.white.withOpacity(0.1),
              contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (value) {
              _searchQuery = value;
              _applyFilter();
            },
          ),
        ),

        // --- 2. FILTER CHIPS ---
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildFilterChip("Semua", 0),
              const SizedBox(width: 8),
              _buildFilterChip("Terjadwal", 1),
              const SizedBox(width: 8),
              _buildFilterChip("Selesai", 2),
            ],
          ),
        ),

        // --- 3. LIST MATCHES ---
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: ArenaColor.dragonFruit))
              : _filteredMatches.isEmpty
                  ? RefreshIndicator(
                      onRefresh: _fetchData,
                      child: ListView(
                        children: [
                          const SizedBox(height: 80),
                          Center(
                            child: Column(
                              children: [
                                const Icon(Icons.search_off, size: 50, color: Colors.white24),
                                const SizedBox(height: 10),
                                Text(
                                  _allMatches.isEmpty ? "Belum ada data." : "Pertandingan tidak ditemukan.", 
                                  style: const TextStyle(color: Colors.white54)
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _fetchData,
                      color: ArenaColor.dragonFruit,
                      backgroundColor: const Color(0xFF2A2045),
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                        itemCount: _filteredMatches.length,
                        itemBuilder: (context, index) {
                          final match = _filteredMatches[index];
                          final homeName = _teamNameMap[match.fields.homeTeam] ?? "Team ${match.fields.homeTeam}";
                          final awayName = _teamNameMap[match.fields.awayTeam] ?? "Team ${match.fields.awayTeam}";
                          final dateStr = DateFormat('dd MMM, HH:mm').format(match.fields.date);
                          final isFinished = match.fields.status == "FINISHED";

                          return Card(
                            color: Colors.white.withOpacity(0.05),
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: isAdmin ? () => _showAdminOptions(context, match) : null,
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  children: [
                                    // Header: Tanggal & Label Status
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          dateStr,
                                          style: const TextStyle(color: Colors.white54, fontSize: 12),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: isFinished ? Colors.green.withOpacity(0.2) : Colors.orange.withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(4)
                                          ),
                                          child: Text(
                                            isFinished ? "FT" : "Upcoming",
                                            style: TextStyle(
                                              color: isFinished ? Colors.greenAccent : Colors.orangeAccent, 
                                              fontSize: 10, 
                                              fontWeight: FontWeight.bold
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    
                                    // Body: Home vs Away
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            homeName, 
                                            textAlign: TextAlign.right, 
                                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)
                                          ),
                                        ),
                                        Container(
                                          margin: const EdgeInsets.symmetric(horizontal: 16),
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF2A2045), 
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(color: Colors.white10)
                                          ),
                                          child: Text(
                                            isFinished ? "${match.fields.homeScore} - ${match.fields.awayScore}" : "VS",
                                            style: TextStyle(
                                              color: isFinished ? ArenaColor.dragonFruit : Colors.white70, 
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            awayName, 
                                            textAlign: TextAlign.left, 
                                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
        ),
      ],
    );
  }

  // Widget Helper Filter Chip
  Widget _buildFilterChip(String label, int index) {
    final bool isSelected = _filterIndex == index;
    return GestureDetector(
      onTap: () => _onFilterChanged(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? ArenaColor.dragonFruit : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? ArenaColor.dragonFruit : Colors.transparent
          )
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white70,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 12
          ),
        ),
      ),
    );
  }

  // Admin Options
  void _showAdminOptions(BuildContext context, Match match) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF2A2045),
        title: const Text("Opsi Admin", style: TextStyle(color: Colors.white)),
        actions: [
          TextButton(
            child: const Text("Update Skor / Edit", style: TextStyle(color: Colors.blueAccent)),
            onPressed: () async {
              Navigator.pop(ctx);
              final res = await Navigator.push(
                context, 
                MaterialPageRoute(builder: (_) => MatchFormPage(match: match))
              );
              if (res == true) _fetchData();
            },
          ),
          TextButton(
            child: const Text("Hapus Jadwal", style: TextStyle(color: Colors.redAccent)),
            onPressed: () async {
              Navigator.pop(ctx);
              _confirmDelete(context, match);
            },
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, Match match) {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        backgroundColor: const Color(0xFF2A2045),
        title: const Text("Hapus Jadwal?", style: TextStyle(color: Colors.white)),
        content: const Text("Data ini akan dihapus permanen.", style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: ()=>Navigator.pop(c), child: const Text("Batal")),
          TextButton(
            child: const Text("Hapus", style: TextStyle(color: Colors.red)),
            onPressed: () async {
              Navigator.pop(c);
              final req = context.read<CookieRequest>();
              await LeagueService().deleteMatch(req, match.pk);
              _fetchData();
            },
          ),
        ],
      )
    );
  }
}