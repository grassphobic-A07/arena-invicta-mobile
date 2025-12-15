import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:arena_invicta_mobile/naufal_leagues/models/standing.dart';
import 'package:arena_invicta_mobile/naufal_leagues/models/team.dart';
import 'package:arena_invicta_mobile/naufal_leagues/services/league_service.dart';
import 'package:arena_invicta_mobile/naufal_leagues/screens/standing_form_page.dart';
import 'package:arena_invicta_mobile/global/widgets/app_colors.dart';

class LeagueStandingsTab extends StatefulWidget {
  const LeagueStandingsTab({super.key});

  @override
  State<LeagueStandingsTab> createState() => _LeagueStandingsTabState();
}

class _LeagueStandingsTabState extends State<LeagueStandingsTab> {
  // Kita butuh dua data: Standings (untuk angka) dan Teams (untuk nama tim)
  Future<Map<String, dynamic>>? _dataFuture;
  
  // State untuk filter musim
  String? _selectedSeason;
  List<String> _availableSeasons = [];

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() {
    final request = context.read<CookieRequest>();
    setState(() {
      _dataFuture = _fetchAllData(request);
    });
  }

  Future<Map<String, dynamic>> _fetchAllData(CookieRequest request) async {
    final service = LeagueService();
    final responses = await Future.wait([
      service.fetchStandings(request), // Index 0
      service.fetchTeams(request),     // Index 1
    ]);

    return {
      "standings": responses[0] as List<Standing>,
      "teams": responses[1] as List<Team>,
    };
  }

  // Helper untuk mendapatkan nama tim berdasarkan ID
  String _getTeamName(int teamId, List<Team> teams) {
    try {
      return teams.firstWhere((t) => t.pk == teamId).fields.name;
    } catch (e) {
      return "Team $teamId"; // Fallback jika tim terhapus
    }
  }

  @override
  Widget build(BuildContext context) {
    // Cek apakah user admin (untuk menampilkan tombol edit)
    // Asumsi: Logic role ada di UserProvider, tapi untuk simplifikasi kita tampilkan tombol edit
    // Nanti tombol edit akan divalidasi backend.
    
    return Scaffold(
      backgroundColor: Colors.transparent, // Agar background dashboard terlihat
      floatingActionButton: FloatingActionButton(
        backgroundColor: ArenaColor.dragonFruit,
        onPressed: () async {
          // Navigasi ke Form Tambah (Create)
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const StandingFormPage()),
          );
          if (result == true) _refreshData(); // Refresh jika ada data baru
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _dataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData) {
            return const Center(child: Text("Belum ada data."));
          }

          final allStandings = snapshot.data!['standings'] as List<Standing>;
          final allTeams = snapshot.data!['teams'] as List<Team>;

          if (allStandings.isEmpty) {
            return const Center(child: Text("Belum ada data klasemen."));
          }

          // 1. Ekstrak Season Unik
          if (_availableSeasons.isEmpty) {
            final seasons = allStandings.map((s) => s.fields.season).toSet().toList();
            seasons.sort(); // Urutkan string
            _availableSeasons = seasons;
            // Default pilih season terakhir (terbaru)
            if (_selectedSeason == null && seasons.isNotEmpty) {
              _selectedSeason = seasons.last;
            }
          }

          // 2. Filter data berdasarkan Season terpilih
          final filteredStandings = allStandings
              .where((s) => s.fields.season == _selectedSeason)
              .toList();

          // 3. Sorting (Poin > GD > GF)
          filteredStandings.sort((a, b) {
            int cmp = b.fields.points.compareTo(a.fields.points);
            if (cmp != 0) return cmp;
            int cmpGd = b.fields.gd.compareTo(a.fields.gd);
            if (cmpGd != 0) return cmpGd;
            return b.fields.gf.compareTo(a.fields.gf);
          });

          return Column(
            children: [
              // --- DROPDOWN SEASON ---
              Container(
                padding: const EdgeInsets.all(12),
                color: Colors.black12,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Pilih Musim:",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    DropdownButton<String>(
                      value: _selectedSeason,
                      dropdownColor: ArenaColor.darkAmethyst,
                      style: const TextStyle(color: Colors.white),
                      items: _availableSeasons.map((String season) {
                        return DropdownMenuItem<String>(
                          value: season,
                          child: Text(season),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedSeason = newValue;
                        });
                      },
                    ),
                  ],
                ),
              ),

              // --- TABEL KLASEMEN ---
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columnSpacing: 18,
                      headingRowColor: MaterialStateProperty.all(Colors.white.withOpacity(0.1)),
                      columns: const [
                        DataColumn(label: Text("Pos", style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text("Team", style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text("P"), tooltip: "Played"),
                        DataColumn(label: Text("W"), tooltip: "Won"),
                        DataColumn(label: Text("D"), tooltip: "Draw"),
                        DataColumn(label: Text("L"), tooltip: "Loss"),
                        DataColumn(label: Text("GF"), tooltip: "Goals For"),
                        DataColumn(label: Text("GA"), tooltip: "Goals Against"),
                        DataColumn(label: Text("GD"), tooltip: "Goal Difference"),
                        DataColumn(label: Text("Pts", style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text("Aksi")), // Kolom Edit
                      ],
                      rows: List<DataRow>.generate(filteredStandings.length, (index) {
                        final s = filteredStandings[index];
                        return DataRow(cells: [
                          DataCell(Text("${index + 1}")), // Posisi
                          DataCell(Text(
                            _getTeamName(s.fields.team, allTeams),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          )),
                          DataCell(Text("${s.fields.played}")),
                          DataCell(Text("${s.fields.win}")),
                          DataCell(Text("${s.fields.draw}")),
                          DataCell(Text("${s.fields.loss}")),
                          DataCell(Text("${s.fields.gf}")),
                          DataCell(Text("${s.fields.ga}")),
                          DataCell(Text("${s.fields.gd}")),
                          DataCell(Text(
                            "${s.fields.points}",
                            style: const TextStyle(fontWeight: FontWeight.bold, color: ArenaColor.dragonFruit),
                          )),
                          DataCell(
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.orange, size: 20),
                              onPressed: () async {
                                // Navigasi ke Form Edit (bawa data objek standing)
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => StandingFormPage(standing: s),
                                  ),
                                );
                                if (result == true) _refreshData(); // Refresh list jika berhasil edit
                              },
                            ),
                          ),
                        ]);
                      }),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}