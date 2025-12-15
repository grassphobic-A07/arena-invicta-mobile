import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

// --- IMPORT GLOBAL & ENVIRONMENT ---
import 'package:arena_invicta_mobile/main.dart'; // Untuk UserProvider
import 'package:arena_invicta_mobile/global/environments.dart'; // Untuk baseUrl
import 'package:arena_invicta_mobile/global/widgets/app_colors.dart';
import 'package:arena_invicta_mobile/global/widgets/glassy_header.dart';
import 'package:arena_invicta_mobile/global/widgets/glassy_navbar.dart';
import 'package:arena_invicta_mobile/neal_auth/widgets/arena_invicta_drawer.dart';

// --- IMPORT MODUL LEAGUES ---
import 'package:arena_invicta_mobile/naufal_leagues/services/league_service.dart';
import 'package:arena_invicta_mobile/naufal_leagues/models/standing.dart';
import 'package:arena_invicta_mobile/naufal_leagues/screens/team_form_page.dart';
import 'package:arena_invicta_mobile/naufal_leagues/screens/standing_form_page.dart';

class LeaguesPage extends StatefulWidget {
  const LeaguesPage({super.key});

  @override
  State<LeaguesPage> createState() => _LeaguesPageState();
}

class _LeaguesPageState extends State<LeaguesPage> {
  late Future<List<Standing>> _futureStandings;
  
  // "Kamus" untuk mengubah ID Team menjadi Nama Team
  final Map<int, String> _teamNameMap = {};

  @override
  void initState() {
    super.initState();
    final request = context.read<CookieRequest>();
    _futureStandings = _fetchAllData(request);
  }

  // --- LOGIC 1: FETCH DATA (Tim + Klasemen) ---
  Future<List<Standing>> _fetchAllData(CookieRequest request) async {
    try {
      // 1. Ambil semua tim untuk mapping nama
      final teams = await LeagueService().fetchTeams(request);
      
      // 2. Isi kamus (Map ID -> Name)
      _teamNameMap.clear();
      for (var team in teams) {
        _teamNameMap[team.pk] = team.fields.name;
      }

      // 3. Ambil data klasemen
      final standings = await LeagueService().fetchStandings(request);
      return standings;

    } catch (e) {
      throw Exception("Gagal mengambil data: $e");
    }
  }

  // --- LOGIC 2: DELETE DATA ---
  void _showDeleteConfirmation(BuildContext context, int standingId, String teamName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2045),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("Confirm Delete", style: TextStyle(color: Colors.white)),
        content: Text(
          "Are you sure you want to delete standing data for $teamName?", 
          style: const TextStyle(color: Colors.white70)
        ),
        actions: [
          TextButton(
            child: const Text("Cancel", style: TextStyle(color: Colors.white70)),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text("Delete", style: TextStyle(color: Colors.redAccent)),
            onPressed: () async {
              Navigator.pop(context); // Tutup dialog konfirmasi
              
              final request = context.read<CookieRequest>();
              try {
                // Panggil API Delete
                final response = await request.postJson(
                  "$baseUrl/leagues/api/standings/delete/$standingId/",
                  jsonEncode({}),
                );
                
                if (context.mounted) {
                  if (response['status'] == 'success') {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Data deleted successfully"))
                    );
                    // Refresh Halaman
                    setState(() {
                      _futureStandings = _fetchAllData(request);
                    });
                  } else {
                     ScaffoldMessenger.of(context).showSnackBar(
                       SnackBar(content: Text("Failed: ${response['message']}"))
                     );
                  }
                }
              } catch (e) {
                 ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
    final userProvider = context.watch<UserProvider>();

    // Cek Role Admin/Staff
    final bool isAdmin = userProvider.isLoggedIn && 
        (userProvider.role == UserRole.admin || userProvider.role == UserRole.staff);

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: ArenaColor.darkAmethyst,
      drawer: ArenaInvictaDrawer(
        userProvider: userProvider,
        roleText: isAdmin ? "Admin" : "Member",
      ),
      
      body: Stack(
        children: [
          // --- LAYER 1: LIST KLASEMEN (KONTEN UTAMA) ---
          Padding(
            padding: const EdgeInsets.only(top: 100, bottom: 80),
            child: FutureBuilder<List<Standing>>(
              future: _futureStandings,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: ArenaColor.dragonFruit));
                }
                
                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}", style: const TextStyle(color: Colors.white70)));
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.leaderboard_outlined, size: 60, color: Colors.white24),
                        SizedBox(height: 16),
                        Text("Belum ada data klasemen.", style: TextStyle(color: Colors.white70)),
                      ],
                    ),
                  );
                }

                final data = snapshot.data!;
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    final standing = data[index];
                    final teamName = _teamNameMap[standing.fields.team] ?? "Unknown Team";

                    // WRAPPER INKWELL UNTUK KLIK ITEM (EDIT/DELETE)
                    return InkWell(
                      // Hanya bisa diklik jika Admin
                      onTap: isAdmin ? () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            backgroundColor: const Color(0xFF2A2045),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            title: Text("Manage $teamName", style: const TextStyle(color: Colors.white)),
                            content: const Text("What do you want to do?", style: TextStyle(color: Colors.white70)),
                            actions: [
                              // Tombol Edit
                              TextButton(
                                child: const Text("Edit", style: TextStyle(color: Colors.blueAccent)),
                                onPressed: () async {
                                  Navigator.pop(context); // Tutup dialog pilihan
                                  // Navigasi ke Form (Mode Edit)
                                  final result = await Navigator.push(
                                    context, 
                                    MaterialPageRoute(builder: (context) => StandingFormPage(standing: standing))
                                  );
                                  // Refresh jika ada perubahan
                                  if (result == true) {
                                    setState(() {
                                      final request = context.read<CookieRequest>();
                                      _futureStandings = _fetchAllData(request);
                                    });
                                  }
                                },
                              ),
                              // Tombol Delete
                              TextButton(
                                child: const Text("Delete", style: TextStyle(color: Colors.redAccent)),
                                onPressed: () async {
                                  Navigator.pop(context); // Tutup dialog pilihan
                                  // Panggil konfirmasi delete
                                  _showDeleteConfirmation(context, standing.pk, teamName);
                                },
                              ),
                            ],
                          ),
                        );
                      } : null, // Jika user biasa, disable tap
                      
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          // Beri sedikit highlight jika bisa diklik admin
                          color: isAdmin ? Colors.white.withOpacity(0.1) : Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white.withOpacity(0.1)),
                        ),
                        child: Row(
                          children: [
                            // 1. Posisi
                            SizedBox(
                              width: 30,
                              child: Text(
                                "${index + 1}",
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                            ),
                            
                            // 2. Info Tim & Poin
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    teamName, 
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Main: ${standing.fields.played} | Poin: ${standing.fields.points}",
                                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            
                            // 3. Selisih Gol (GD)
                            Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: ArenaColor.dragonFruit.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    "GD ${standing.fields.gd}",
                                    style: const TextStyle(color: ArenaColor.dragonFruit, fontWeight: FontWeight.bold, fontSize: 12),
                                  ),
                                ),
                              ],
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

          // --- LAYER 2: HEADER ---
          GlassyHeader(
            userProvider: userProvider,
            scaffoldKey: scaffoldKey,
            title: "LEAGUES",
            subtitle: "Standings",
            isHome: false,
          ),

          // --- LAYER 3: NAVBAR ---
          GlassyNavbar(
            userProvider: userProvider,
            onFabTap: () => Navigator.pop(context),
            activeItem: NavbarItem.league,
          ),

          // --- LAYER 4: TOMBOL MENU ADMIN (FAB) ---
          if (isAdmin)
            Positioned(
              bottom: 120, // Di atas Navbar
              right: 20,
              child: FloatingActionButton(
                heroTag: "adminMenuBtn",
                backgroundColor: ArenaColor.dragonFruit,
                child: const Icon(Icons.edit, color: Colors.white),
                onPressed: () {
                  // Munculkan Menu Pilihan (Create Team / Create Standing)
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: const Color(0xFF2A2045), // Ungu gelap
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    builder: (BuildContext context) {
                      return Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Admin Menu", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
                            const SizedBox(height: 20),
                            
                            // Tombol 1: Tambah Tim
                            ListTile(
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                                child: const Icon(Icons.flag, color: ArenaColor.dragonFruit),
                              ),
                              title: const Text("Add New Team", style: TextStyle(color: Colors.white)),
                              onTap: () async {
                                Navigator.pop(context); 
                                final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => const TeamFormPage()));
                                if (result == true) setState(() {
                                    final request = context.read<CookieRequest>();
                                    _futureStandings = _fetchAllData(request);
                                });
                              },
                            ),
                            
                            const SizedBox(height: 10),

                            // Tombol 2: Tambah Klasemen
                            ListTile(
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                                child: const Icon(Icons.leaderboard, color: ArenaColor.dragonFruit),
                              ),
                              title: const Text("Add Standing Data", style: TextStyle(color: Colors.white)),
                              onTap: () async {
                                Navigator.pop(context); 
                                final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => const StandingFormPage()));
                                if (result == true) setState(() {
                                    final request = context.read<CookieRequest>();
                                    _futureStandings = _fetchAllData(request);
                                });
                              },
                            ),
                          ],
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