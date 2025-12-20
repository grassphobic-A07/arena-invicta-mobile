import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

import 'package:arena_invicta_mobile/main.dart'; // UserProvider
import 'package:arena_invicta_mobile/global/widgets/app_colors.dart';
import 'package:arena_invicta_mobile/naufal_leagues/models/team.dart';
import 'package:arena_invicta_mobile/naufal_leagues/services/league_service.dart';
import 'package:arena_invicta_mobile/naufal_leagues/screens/team_form_page.dart';
import 'package:arena_invicta_mobile/naufal_leagues/screens/team_detail_page.dart';

class LeagueTeamsTab extends StatefulWidget {
  const LeagueTeamsTab({super.key});

  @override
  State<LeagueTeamsTab> createState() => _LeagueTeamsTabState();
}

class _LeagueTeamsTabState extends State<LeagueTeamsTab> {
  // Variabel untuk menyimpan data
  List<Team> _allTeams = [];      // Data asli dari Server
  List<Team> _filteredTeams = []; // Data hasil filter pencarian
  bool _isLoading = true;
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  // Fungsi Fetch Data
  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    final request = context.read<CookieRequest>();
    try {
      final teams = await LeagueService().fetchTeams(request);
      if (mounted) {
        setState(() {
          _allTeams = teams;
          _updateFilteredList(); // Filter ulang saat data baru masuk
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Fungsi Filter Lokal
  void _updateFilteredList() {
    setState(() {
      if (_searchQuery.isEmpty) {
        _filteredTeams = List.from(_allTeams);
      } else {
        _filteredTeams = _allTeams.where((team) {
          return team.fields.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                 team.fields.shortName.toLowerCase().contains(_searchQuery.toLowerCase());
        }).toList();
      }
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
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
          child: TextField(
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: "Cari tim...",
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
              _updateFilteredList();
            },
          ),
        ),

        // --- 2. LIST DATA ---
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: ArenaColor.dragonFruit))
              : _filteredTeams.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.search_off, size: 48, color: Colors.white24),
                          const SizedBox(height: 12),
                          Text(
                            _allTeams.isEmpty ? "Belum ada data tim." : "Tim tidak ditemukan.",
                            style: const TextStyle(color: Colors.white54),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _fetchData, // Fitur Pull-to-Refresh
                      color: ArenaColor.dragonFruit,
                      backgroundColor: const Color(0xFF2A2045),
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        itemCount: _filteredTeams.length,
                        itemBuilder: (context, index) {
                          final team = _filteredTeams[index];
                          
                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white.withOpacity(0.1)),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                              
                              // Index Angka
                              leading: Container(
                                width: 30,
                                alignment: Alignment.center,
                                child: Text(
                                  "${index + 1}", 
                                  style: const TextStyle(color: Colors.white54, fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                              ),

                              // Nama Tim
                              title: Text(
                                team.fields.name, 
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)
                              ),
                              
                              // Navigasi ke Detail
                              onTap: () {
                                Navigator.push(
                                  context, 
                                  MaterialPageRoute(builder: (context) => TeamDetailPage(team: team)),
                                );
                              },

                              // Admin Edit
                              trailing: isAdmin ? IconButton(
                                icon: const Icon(Icons.edit, color: ArenaColor.dragonFruit),
                                onPressed: () async {
                                   final res = await Navigator.push(
                                     context, 
                                     MaterialPageRoute(builder: (_) => TeamFormPage(team: team))
                                   );
                                   if (res == true) _fetchData();
                                },
                              ) : null,
                              
                              // Admin Delete
                              onLongPress: isAdmin ? () => _showDeleteDialog(context, team) : null,
                            ),
                          );
                        },
                      ),
                    ),
        ),
      ],
    );
  }

  void _showDeleteDialog(BuildContext context, Team team) {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        backgroundColor: const Color(0xFF2A2045),
        title: const Text("Hapus Tim?", style: TextStyle(color: Colors.white)),
        content: Text(
          "Yakin ingin menghapus ${team.fields.name}?",
          style: const TextStyle(color: Colors.white70)
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: const Text("Batal", style: TextStyle(color: Colors.white54))),
          TextButton(
            child: const Text("Hapus", style: TextStyle(color: Colors.redAccent)),
            onPressed: () async {
              Navigator.pop(c);
              final req = context.read<CookieRequest>();
              await LeagueService().deleteTeam(req, team.pk);
              _fetchData(); // Refresh list
            },
          ),
        ],
      )
    );
  }
}