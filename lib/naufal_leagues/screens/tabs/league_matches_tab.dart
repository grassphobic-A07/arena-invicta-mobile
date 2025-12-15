import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:arena_invicta_mobile/naufal_leagues/models/match.dart';
import 'package:arena_invicta_mobile/naufal_leagues/services/league_service.dart';
import 'package:arena_invicta_mobile/global/widgets/app_colors.dart';

class LeagueMatchesTab extends StatefulWidget {
  const LeagueMatchesTab({super.key});

  @override
  State<LeagueMatchesTab> createState() => _LeagueMatchesTabState();
}

class _LeagueMatchesTabState extends State<LeagueMatchesTab> {
  Future<List<Match>>? _matchesFuture;
  String _currentFilter = "all"; // Pilihan: 'all', 'upcoming', 'finished'

  @override
  void initState() {
    super.initState();
    final request = context.read<CookieRequest>();
    _matchesFuture = LeagueService().fetchMatches(request);
  }

  // Fungsi helper untuk memfilter list berdasarkan tombol yang dipilih
  List<Match> _filterMatches(List<Match> allMatches) {
    final now = DateTime.now();
    
    // Sort default: Paling baru di atas
    allMatches.sort((a, b) => b.fields.date.compareTo(a.fields.date));

    if (_currentFilter == "upcoming") {
      // Ambil yang tanggalnya masa depan, urutkan dari yang terdekat
      final upcoming = allMatches.where((m) => m.fields.date.isAfter(now)).toList();
      upcoming.sort((a, b) => a.fields.date.compareTo(b.fields.date));
      return upcoming;
    } else if (_currentFilter == "finished") {
      // Ambil yang statusnya FINISHED atau tanggalnya sudah lewat
      return allMatches.where((m) {
        return m.fields.status.toString() == "FINISHED" || m.fields.date.isBefore(now);
      }).toList();
    }
    
    // Default 'all': Tampilkan semua
    return allMatches;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // --- 1. FILTER BUTTONS ---
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          color: Colors.black12, // Sedikit gelap untuk pemisah
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildFilterButton("Semua", "all"),
              const SizedBox(width: 8),
              _buildFilterButton("Jadwal", "upcoming"),
              const SizedBox(width: 8),
              _buildFilterButton("Hasil", "finished"),
            ],
          ),
        ),

        // --- 2. LIST MATCHES ---
        Expanded(
          child: FutureBuilder<List<Match>>(
            future: _matchesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text("Error: ${snapshot.error}"));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text("Belum ada data pertandingan."));
              }

              final filteredList = _filterMatches(snapshot.data!);

              if (filteredList.isEmpty) {
                return const Center(child: Text("Tidak ada pertandingan di kategori ini."));
              }

              return ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: filteredList.length,
                itemBuilder: (context, index) {
                  final match = filteredList[index];
                  return _buildMatchCard(match);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // Widget Tombol Filter Kecil
  Widget _buildFilterButton(String label, String value) {
    final bool isActive = _currentFilter == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentFilter = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? ArenaColor.dragonFruit : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isActive ? Colors.transparent : Colors.white54),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.white70,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // Widget Kartu Pertandingan
  Widget _buildMatchCard(Match match) {
    final date = match.fields.date;
    // Format simpel: DD/MM HH:MM
    final dateStr = "${date.day}/${date.month} ${date.hour}:${date.minute.toString().padLeft(2, '0')}";
    final isFinished = match.fields.status.toString() == "FINISHED" || date.isBefore(DateTime.now());

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      color: Colors.white.withOpacity(0.9), // Agak terang biar kontras
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Home Team
            Expanded(
              child: Text(
                match.fields.homeTeam.toString(), // TODO: Ganti nama tim nanti
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
              ),
            ),
            
            // Score / VS
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                children: [
                  if (isFinished)
                    Text(
                      "${match.fields.homeScore} - ${match.fields.awayScore}",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black),
                    )
                  else
                    const Text(
                      "VS",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.grey),
                    ),
                  const SizedBox(height: 4),
                  Text(dateStr, style: const TextStyle(fontSize: 10, color: Colors.black54)),
                ],
              ),
            ),

            // Away Team
            Expanded(
              child: Text(
                match.fields.awayTeam.toString(), // TODO: Ganti nama tim nanti
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
              ),
            ),
          ],
        ),
      ),
    );
  }
}