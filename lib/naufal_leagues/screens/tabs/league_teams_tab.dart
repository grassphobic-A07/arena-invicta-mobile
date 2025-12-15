import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:arena_invicta_mobile/global/environments.dart';
import 'package:arena_invicta_mobile/global/widgets/app_colors.dart';
import 'package:arena_invicta_mobile/naufal_leagues/models/team.dart';
import 'package:arena_invicta_mobile/naufal_leagues/services/league_service.dart';

class LeagueTeamsTab extends StatefulWidget {
  const LeagueTeamsTab({super.key});

  @override
  State<LeagueTeamsTab> createState() => _LeagueTeamsTabState();
}

class _LeagueTeamsTabState extends State<LeagueTeamsTab> {
  Future<List<Team>>? _teamsFuture;
  List<Team> _allTeams = []; // Simpan semua data untuk keperluan search
  List<Team> _filteredTeams = []; // Data yang ditampilkan setelah difilter
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() {
    final request = context.read<CookieRequest>();
    setState(() {
      _teamsFuture = LeagueService().fetchTeams(request).then((data) {
        _allTeams = data;
        _filteredTeams = data;
        return data;
      });
    });
  }

  void _runFilter(String keyword) {
    List<Team> results = [];
    if (keyword.isEmpty) {
      results = _allTeams;
    } else {
      results = _allTeams
          .where((team) =>
              team.fields.name.toLowerCase().contains(keyword.toLowerCase()))
          .toList();
    }
    setState(() {
      _filteredTeams = results;
    });
  }

  // Fungsi untuk menampilkan Pop-up Tambah Tim
  void _showAddTeamDialog(BuildContext context) {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    String name = "";
    String shortName = "";
    String year = "2023";

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: ArenaColor.darkAmethyst,
          title: const Text("Tambah Tim Baru", style: TextStyle(color: Colors.white)),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: _inputDecoration("Nama Tim (mis. Liverpool)"),
                  style: const TextStyle(color: Colors.white),
                  onSaved: (val) => name = val!,
                  validator: (val) => val == null || val.isEmpty ? "Wajib diisi" : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  decoration: _inputDecoration("Singkatan (mis. LIV)"),
                  style: const TextStyle(color: Colors.white),
                  onSaved: (val) => shortName = val!,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  decoration: _inputDecoration("Tahun Berdiri"),
                  style: const TextStyle(color: Colors.white),
                  keyboardType: TextInputType.number,
                  initialValue: "2023",
                  onSaved: (val) => year = val!,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal", style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: ArenaColor.dragonFruit),
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  formKey.currentState!.save();
                  final request = context.read<CookieRequest>();
                  
                  // Kirim data ke Django
                  // Endpoint create_team_flutter
                  final response = await request.postJson(
                    "$baseUrl/leagues/api/teams/create/",
                    jsonEncode({
                      "name": name,
                      "short_name": shortName,
                      "founded_year": year,
                    }),
                  );

                  if (context.mounted) {
                    if (response['status'] == 'success') {
                      Navigator.pop(context); // Tutup dialog
                      _refreshData(); // Refresh list tim
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Tim berhasil dibuat!")));
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Gagal: ${response['message']}")));
                    }
                  }
                }
              },
              child: const Text("Simpan", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white54)),
      focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: ArenaColor.dragonFruit)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(
        backgroundColor: ArenaColor.dragonFruit,
        onPressed: () => _showAddTeamDialog(context),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          // --- SEARCH BAR ---
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              onChanged: _runFilter,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Cari tim...",
                hintStyle: const TextStyle(color: Colors.white54),
                prefixIcon: const Icon(Icons.search, color: Colors.white54),
                filled: true,
                fillColor: Colors.black12,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // --- GRID LIST TEAMS ---
          Expanded(
            child: FutureBuilder<List<Team>>(
              future: _teamsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                } else if (!snapshot.hasData || _filteredTeams.isEmpty) {
                  return const Center(child: Text("Tidak ada tim ditemukan."));
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // 2 Kolom
                    childAspectRatio: 1.3, // Rasio lebar:tinggi kartu
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: _filteredTeams.length,
                  itemBuilder: (context, index) {
                    final team = _filteredTeams[index];
                    return Card(
                      color: Colors.white.withOpacity(0.1),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                           // Nanti bisa diarahkan ke Detail Tim jika sudah dibuat
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Placeholder Icon Klub (Bola)
                            const Icon(Icons.shield, size: 40, color: Colors.white70),
                            const SizedBox(height: 12),
                            Text(
                              team.fields.name,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Est. ${team.fields.foundedYear}",
                              style: const TextStyle(color: Colors.white54, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}