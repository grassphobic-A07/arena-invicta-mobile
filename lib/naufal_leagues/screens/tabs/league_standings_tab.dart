import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

import 'package:arena_invicta_mobile/main.dart'; // UserProvider
import 'package:arena_invicta_mobile/global/widgets/app_colors.dart';
import 'package:arena_invicta_mobile/naufal_leagues/services/league_service.dart';
import 'package:arena_invicta_mobile/naufal_leagues/models/standing.dart';
// Import Model Team
import 'package:arena_invicta_mobile/naufal_leagues/models/team.dart' as team_model; 
import 'package:arena_invicta_mobile/naufal_leagues/screens/team_detail_page.dart';
import 'package:arena_invicta_mobile/naufal_leagues/screens/standing_form_page.dart';

class LeagueStandingsTab extends StatefulWidget {
  const LeagueStandingsTab({super.key});

  @override
  State<LeagueStandingsTab> createState() => _LeagueStandingsTabState();
}

class _LeagueStandingsTabState extends State<LeagueStandingsTab> {
  final LeagueService _service = LeagueService();
  
  // State variables
  bool _isLoading = true;
  List<String> _seasons = [];
  String? _selectedSeason;
  List<dynamic> _standingsData = []; 
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData();
    });
  }

  Future<void> _fetchData({String? season}) async {
    setState(() { _isLoading = true; _errorMessage = null; });

    final request = context.read<CookieRequest>();
    final response = await _service.fetchStandingsPage(request, season: season);

    if (!mounted) return;

    if (response['status'] == 'success') {
      setState(() {
        List<String> rawSeasons = List<String>.from(response['seasons']);
        _seasons = rawSeasons.toSet().toList();
        
        String? backendSeason = response['selected_season'];

        if (season == null) {
          if (backendSeason != null && _seasons.contains(backendSeason)) {
            _selectedSeason = backendSeason;
          } else if (_seasons.isNotEmpty) {
            _selectedSeason = _seasons.last;
          } else {
            _selectedSeason = null;
          }
        } else {
          if (_seasons.contains(season)) {
            _selectedSeason = season;
          } else if (_seasons.isNotEmpty) {
             _selectedSeason = _seasons.last;
          }
        }
        
        _standingsData = response['standings'];
        _isLoading = false;
      });
    } else {
      setState(() {
        _errorMessage = response['message'] ?? "Gagal mengambil data.";
        _isLoading = false;
      });
    }
  }

  void _onSeasonChanged(String? newValue) {
    if (newValue != null && newValue != _selectedSeason) {
      _fetchData(season: newValue);
    }
  }

  Standing _createStandingObject(Map<String, dynamic> json) {
    return Standing(
      model: "leagues.standing",
      pk: json['id'],
      fields: Fields(
        team: json['team_id'] ?? 0,    
        league: json['league_id'] ?? 0,
        season: _selectedSeason ?? "",
        played: json['played'],
        win: json['win'],
        draw: json['draw'],
        loss: json['loss'],
        gf: json['gf'],
        ga: json['ga'],
        gd: json['gd'],
        points: json['points'],
      ),
    );
  }

  // --- NAVIGASI SESUAI MODEL TEAM.DART ANDA ---
  void _navigateToTeamDetail(int teamId, String teamName, int leagueId) {
    final tempTeam = team_model.Team(
      model: "leagues.team",
      pk: teamId,
      fields: team_model.Fields(
        name: teamName,
        league: leagueId,
        shortName: "",            // Dummy String kosong (Wajib)
        foundedYear: null,        // Boleh null (Optional)
      ),
    );

    Navigator.push(
      context, 
      MaterialPageRoute(builder: (context) => TeamDetailPage(team: tempTeam)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final isAdmin = userProvider.isLoggedIn && 
        (userProvider.role == UserRole.admin || userProvider.role == UserRole.staff);

    return Column(
      children: [
        // Filter Season
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: Colors.black.withOpacity(0.2), 
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Pilih Musim:", style: TextStyle(color: Colors.white70, fontSize: 14)),
              _buildSeasonDropdown(),
            ],
          ),
        ),

        // Tabel Klasemen
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: ArenaColor.dragonFruit))
              : _errorMessage != null
                  ? Center(child: Text(_errorMessage!, style: const TextStyle(color: Colors.white)))
                  : _standingsData.isEmpty
                      ? const Center(child: Text("Tidak ada data klasemen.", style: TextStyle(color: Colors.white60)))
                      : _buildDataTable(isAdmin),
        ),
      ],
    );
  }

  Widget _buildSeasonDropdown() {
    if (_seasons.isEmpty) return const Text("-", style: TextStyle(color: Colors.white));
    String? validValue;
    if (_selectedSeason != null && _seasons.contains(_selectedSeason)) {
      validValue = _selectedSeason;
    } else if (_seasons.isNotEmpty) {
      validValue = _seasons.last;
    } else {
      validValue = null;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: ArenaColor.darkAmethyst.withOpacity(0.8),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white24),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: validValue,
          dropdownColor: const Color(0xFF2A2045), 
          icon: const Icon(Icons.arrow_drop_down, color: ArenaColor.dragonFruit),
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          onChanged: _onSeasonChanged,
          items: _seasons.map((val) => DropdownMenuItem(value: val, child: Text(val))).toList(),
        ),
      ),
    );
  }

  Widget _buildDataTable(bool isAdmin) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      padding: const EdgeInsets.only(bottom: 100), 
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Theme(
          data: Theme.of(context).copyWith(
            dataTableTheme: DataTableThemeData(
              headingRowColor: MaterialStateProperty.all(Colors.white.withOpacity(0.1)),
              dataRowColor: MaterialStateProperty.all(Colors.transparent),
              headingTextStyle: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),
              dataTextStyle: const TextStyle(color: Colors.white),
            ),
          ),
          child: DataTable(
            columnSpacing: 20,
            horizontalMargin: 16,
            headingRowHeight: 40,
            columns: const [
              DataColumn(label: Text("#", textAlign: TextAlign.center), numeric: true),
              DataColumn(label: Text("Tim")), 
              DataColumn(label: Text("Main"), numeric: true),
              DataColumn(label: Text("M"), numeric: true),
              DataColumn(label: Text("S"), numeric: true),
              DataColumn(label: Text("K"), numeric: true),
              DataColumn(label: Text("GD"), numeric: true),
              DataColumn(label: Text("Poin"), numeric: true),
            ],
            rows: _standingsData.map<DataRow>((data) {
              final int rank = data['rank'];
              final bool isTop = rank == 1; 
              final bool isUCL = rank <= 4; 
              final bool isBottom = rank >= _standingsData.length - 3 && _standingsData.length > 5;

              Color rankColor = Colors.white;
              if (isTop) rankColor = Colors.amber;
              else if (isUCL) rankColor = Colors.greenAccent;
              else if (isBottom) rankColor = Colors.redAccent;

              return DataRow(
                onSelectChanged: isAdmin ? (selected) {
                  if (selected == true) {
                    final standingObj = _createStandingObject(data);
                    _showOptions(context, standingObj, data['team_name']);
                  }
                } : null,
                cells: [
                  DataCell(Text("$rank", style: TextStyle(color: rankColor, fontWeight: FontWeight.bold))),
                  
                  // Kolom Tim (Klik untuk Detail)
                  DataCell(
                    InkWell(
                      onTap: () {
                         int teamId = data['team_id'] ?? 0;
                         int leagueId = data['league_id'] ?? 0; 
                         if (teamId != 0) {
                           _navigateToTeamDetail(teamId, data['team_name'], leagueId);
                         }
                      },
                      child: SizedBox(
                        width: 140,
                        child: Text(
                          data['team_name'], 
                          overflow: TextOverflow.ellipsis, 
                          // --- STYLE DIUBAH: TIDAK ADA GARIS BAWAH ---
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: ArenaColor.dragonFruit, // Tetap berwarna agar user tahu bisa diklik
                            // decoration: TextDecoration.underline, // <--- Baris ini dihapus
                          )
                        ),
                      ),
                    ),
                  ),

                  DataCell(Text("${data['played']}")),
                  DataCell(Text("${data['win']}")),
                  DataCell(Text("${data['draw']}")),
                  DataCell(Text("${data['loss']}")),
                  DataCell(Text("${data['gd']}", style: TextStyle(color: data['gd'] > 0 ? Colors.greenAccent : (data['gd'] < 0 ? Colors.redAccent : Colors.white70)))),
                  DataCell(Text("${data['points']}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  void _showOptions(BuildContext context, Standing standing, String teamName) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF2A2045),
        title: Text("Kelola $teamName", style: const TextStyle(color: Colors.white)),
        content: const Text("Apa yang ingin Anda lakukan?", style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            child: const Text("Edit", style: TextStyle(color: Colors.blueAccent)),
            onPressed: () async {
              Navigator.pop(ctx);
              final res = await Navigator.push(context, MaterialPageRoute(builder: (_) => StandingFormPage(standing: standing)));
              if (res == true) _fetchData(season: _selectedSeason);
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
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Data berhasil dihapus")));
       _fetchData(season: _selectedSeason);
     }).catchError((err) {
       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal menghapus: $err")));
     });
  }
}