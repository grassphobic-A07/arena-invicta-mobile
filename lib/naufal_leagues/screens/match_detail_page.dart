import 'dart:ui'; // Wajib untuk ImageFilter
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:arena_invicta_mobile/global/widgets/app_colors.dart';
import 'package:arena_invicta_mobile/naufal_leagues/services/league_service.dart';

class MatchDetailPage extends StatefulWidget {
  final int matchId;

  const MatchDetailPage({super.key, required this.matchId});

  @override
  State<MatchDetailPage> createState() => _MatchDetailPageState();
}

class _MatchDetailPageState extends State<MatchDetailPage> {
  late Future<Map<String, dynamic>> _matchDetailFuture;
  final LeagueService _service = LeagueService();

  @override
  void initState() {
    super.initState();
    final request = context.read<CookieRequest>();
    _matchDetailFuture = _service.fetchMatchDetail(request, widget.matchId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E123B), // Background Gelap
      appBar: AppBar(
        title: const Text("Match Center", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _matchDetailFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: ArenaColor.dragonFruit));
          }

          // Error Handling
          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.containsKey('status') && snapshot.data!['status'] == 'error') {
             return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  "Gagal memuat data.\n${snapshot.data?['message'] ?? snapshot.error ?? 'Data tidak ditemukan'}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70),
                ),
              ),
            );
          }

          final data = snapshot.data!;
          
          // Parsing Tanggal
          DateTime date;
          try {
            date = DateTime.parse(data['date']);
          } catch (e) {
            date = DateTime.now();
          }
          final String dateStr = DateFormat('EEEE, d MMMM yyyy').format(date);
          final String timeStr = DateFormat('HH:mm').format(date);

          return Stack(
            children: [
               // Background Glow Effect
              Positioned(
                top: -100, right: -100,
                child: Container(
                  width: 300, height: 300,
                  decoration: BoxDecoration(color: ArenaColor.dragonFruit.withOpacity(0.2), shape: BoxShape.circle),
                  child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80), child: const SizedBox()),
                ),
              ),
              
              SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: Column(
                  children: [
                    // 1. HEADER PERTANDINGAN
                    Text("$dateStr • $timeStr", style: const TextStyle(color: Colors.white54, fontSize: 12)),
                    const SizedBox(height: 24),
                    
                    // Skor & Nama Tim
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Home Team
                        Expanded(
                          child: Text(
                            data['home_team'],
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                            maxLines: 2,
                          ),
                        ),
                        
                        // Score Box
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 12),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: ArenaColor.dragonFruit.withOpacity(0.5)),
                          ),
                          child: Text(
                            "${data['home_score']} : ${data['away_score']}",
                            style: const TextStyle(color: ArenaColor.dragonFruit, fontSize: 28, fontWeight: FontWeight.w900),
                          ),
                        ),

                        // Away Team
                        Expanded(
                          child: Text(
                            data['away_team'],
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                            maxLines: 2,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // 2. KARTU STATISTIK (GLASSY DARK STYLE)
                    LayoutBuilder(
                      builder: (context, constraints) {
                        if (constraints.maxWidth > 600) {
                          // Tablet/Landscape: Side by Side
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: _buildStatCard("Statistik Tim Kandang", data, "home")),
                              const SizedBox(width: 16),
                              Expanded(child: _buildStatCard("Statistik Tim Tamu", data, "away")),
                            ],
                          );
                        } else {
                          // Mobile: Atas Bawah
                          return Column(
                            children: [
                              _buildStatCard("Statistik Tim Kandang", data, "home"),
                              const SizedBox(height: 16),
                              _buildStatCard("Statistik Tim Tamu", data, "away"),
                            ],
                          );
                        }
                      },
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // --- WIDGET HELPER YANG DIUBAH ---

  // Helper Widget: Kartu Statistik (SEKARANG GLASSY DARK)
  Widget _buildStatCard(String title, Map<String, dynamic> data, String prefix) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12), // Efek Blur Kaca
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            // Background Gelap Transparan
            color: const Color(0xFF2A1B54).withOpacity(0.4), 
            borderRadius: BorderRadius.circular(24),
            // Border Tipis Terang
            border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Judul (Sekarang Putih)
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white, // Diubah jadi putih agar kontras
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 12),
              // Divider (Sekarang Terang)
              Divider(color: Colors.white.withOpacity(0.1), height: 1),
              const SizedBox(height: 16),

              // List Statistik (Teks didalamnya juga disesuaikan)
              _buildStatRow("Tembakan", data['${prefix}_shots']),
              _buildStatRow("Tepat Sasaran", data['${prefix}_shots_on_target']),
              _buildStatRow("Penguasaan Bola (%)", data['${prefix}_possession']),
              _buildStatRow("Umpan", data['${prefix}_passes']),
              _buildStatRow("Corner", data['${prefix}_corners']),
              _buildStatRow("Offside", data['${prefix}_offsides']),
              _buildStatRow("Pelanggaran", data['${prefix}_fouls']),
              _buildStatRow("Kartu Kuning", data['${prefix}_yellow_cards']),
              _buildStatRow("Kartu Merah", data['${prefix}_red_cards']),
            ],
          ),
        ),
      ),
    );
  }

  // Helper Widget: Baris Statistik (Teks Disesuaikan untuk Dark Mode)
  Widget _buildStatRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Label (Warna Putih Transparan)
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
          ),
          // Nilai (Warna Putih Tebal)
          Text(
            "${value ?? 0}",
            style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}