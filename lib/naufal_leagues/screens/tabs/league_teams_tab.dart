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
  List<Team> _allTeams = [];
  List<Team> _filteredTeams = [];
  bool _isLoading = true;
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    final request = context.read<CookieRequest>();
    try {
      final teams = await LeagueService().fetchTeams(request);
      if (mounted) {
        setState(() {
          _allTeams = teams;
          _updateFilteredList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

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
        // --- SEARCH BAR (Tetap dipertahankan karena fungsional) ---
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: TextField(
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: "Cari tim...",
              hintStyle: const TextStyle(color: Colors.white54),
              prefixIcon: const Icon(Icons.search, color: Colors.white54),
              filled: true,
              fillColor: const Color(0xFF2A2045),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (value) {
              _searchQuery = value;
              _updateFilteredList();
            },
          ),
        ),

        // --- LIST TIM ---
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: ArenaColor.dragonFruit))
              : _filteredTeams.isEmpty
                  ? Center(
                      child: Text(
                        _allTeams.isEmpty ? "Belum ada data tim." : "Tim tidak ditemukan.",
                        style: const TextStyle(color: Colors.white54),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _fetchData,
                      color: ArenaColor.dragonFruit,
                      backgroundColor: const Color(0xFF2A2045),
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: _filteredTeams.length,
                        separatorBuilder: (ctx, index) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final team = _filteredTeams[index];
                          
                          return Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context, 
                                  MaterialPageRoute(builder: (context) => TeamDetailPage(team: team)),
                                );
                              },
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.white10),
                                ),
                                child: Row(
                                  children: [
                                    // Nama Tim (Fokus Utama)
                                    Expanded(
                                      child: Text(
                                        team.fields.name, 
                                        style: const TextStyle(
                                          color: Colors.white, 
                                          fontWeight: FontWeight.w600, 
                                          fontSize: 15
                                        ),
                                      ),
                                    ),
                                    
                                    // Icon Arrow atau Edit (Admin)
                                    if (isAdmin) 
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.edit, size: 20, color: Colors.white54),
                                            onPressed: () async {
                                              final res = await Navigator.push(
                                                context, 
                                                MaterialPageRoute(builder: (_) => TeamFormPage(team: team))
                                              );
                                              if (res == true) _fetchData();
                                            },
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                          ),
                                          const SizedBox(width: 16),
                                          IconButton(
                                            icon: const Icon(Icons.delete, size: 20, color: Colors.redAccent),
                                            onPressed: () => _showDeleteDialog(context, team),
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                          ),
                                        ],
                                      )
                                    else
                                      const Icon(Icons.chevron_right, color: Colors.white24),
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
              _fetchData(); 
            },
          ),
        ],
      )
    );
  }
}