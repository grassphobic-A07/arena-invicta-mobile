import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:arena_invicta_mobile/naufal_leagues/models/match.dart';
import 'package:arena_invicta_mobile/naufal_leagues/models/standing.dart';
import 'package:arena_invicta_mobile/naufal_leagues/services/league_service.dart';

class LeagueSummaryTab extends StatefulWidget {
  const LeagueSummaryTab({super.key});

  @override
  State<LeagueSummaryTab> createState() => _LeagueSummaryTabState();
}

class _LeagueSummaryTabState extends State<LeagueSummaryTab> {
  // Kita butuh mengambil dua jenis data sekaligus
  late Future<Map<String, dynamic>> _dataFuture;

  @override
  void initState() {
    super.initState();
    final request = context.read<CookieRequest>();
    _dataFuture = _fetchAllData(request);
  }

  // Fungsi helper untuk mengambil Matches dan Standings secara paralel
  Future<Map<String, dynamic>> _fetchAllData(CookieRequest request) async {
    final service = LeagueService();
    
    // Jalan berbarengan (Parallel Fetching) biar cepat
    final responses = await Future.wait([
      service.fetchStandings(request),
      service.fetchMatches(request),
    ]);

    return {
      "standings": responses[0] as List<Standing>,
      "matches": responses[1] as List<Match>,
    };
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _dataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        } else if (!snapshot.hasData) {
          return const Center(child: Text("Tidak ada data."));
        }

        // --- 1. PROSES DATA (LOGIC SAMA DENGAN VIEWS.PY) ---
        
        final allStandings = snapshot.data!['standings'] as List<Standing>;
        final allMatches = snapshot.data!['matches'] as List<Match>;

        // A. Cari Latest Season (Musim Terbaru)
        // Logic: Ambil semua season unik, urutkan, ambil yang terakhir
        String? latestSeason;
        if (allMatches.isNotEmpty) {
           final seasons = allMatches.map((m) => m.fields.season).toSet().toList();
           seasons.sort(); // Urutkan string (misal "23/24", "24/25")
           if (seasons.isNotEmpty) latestSeason = seasons.last;
        }

        // B. Filter Standing berdasarkan Latest Season
        final currentStandings = latestSeason == null 
            ? <Standing>[] 
            : allStandings.where((s) => s.fields.season == latestSeason).toList();
        
        // Urutkan klasemen berdasarkan Poin tertinggi -> GD -> GF (Standar bola)
        currentStandings.sort((a, b) {
          int cmp = b.fields.points.compareTo(a.fields.points); // Poin Descending
          if (cmp != 0) return cmp;
          return b.fields.gd.compareTo(a.fields.gd); // GD Descending
        });

        // C. Filter Matches (Finished vs Upcoming)
        final now = DateTime.now();
        
        // Upcoming: Tanggal > Sekarang, Urutkan tanggal menaik (terdekat dulu), Ambil 5
        final upcomingMatches = allMatches.where((m) {
          return m.fields.date.isAfter(now); 
        }).toList();
        upcomingMatches.sort((a, b) => a.fields.date.compareTo(b.fields.date));
        final limitedUpcoming = upcomingMatches.take(5).toList();

        // Finished: Status Finished atau Tanggal < Sekarang, Urutkan tanggal menurun (terbaru dulu), Ambil 5
        final finishedMatches = allMatches.where((m) {
          // Cek status enum atau cek tanggal (fallback logic)
          return m.fields.status.toString() == "FINISHED" || m.fields.date.isBefore(now);
        }).toList();
        finishedMatches.sort((a, b) => b.fields.date.compareTo(a.fields.date));
        final limitedFinished = finishedMatches.take(5).toList();


        // --- 2. TAMPILAN UI (WIDGETS) ---
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // === BAGIAN KLASEMEN (MINI TABLE) ===
              _buildSectionTitle("Klasemen ($latestSeason)"),
              const SizedBox(height: 8),
              if (currentStandings.isEmpty)
                const Text("Belum ada data klasemen.")
              else
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columnSpacing: 20,
                    headingRowColor: MaterialStateProperty.all(Colors.grey[200]),
                    columns: const [
                      DataColumn(label: Text("Pos", style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text("Tim", style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(
                        label: Text("P"),
                        tooltip: "Played", // Pindahkan ke sini
                      ),
                      DataColumn(label: Text("W")),
                      DataColumn(label: Text("D")),
                      DataColumn(label: Text("L")),
                      DataColumn(label: Text("Pts", style: TextStyle(fontWeight: FontWeight.bold))),
                    ],
                    rows: List<DataRow>.generate(currentStandings.length, (index) {
                      final s = currentStandings[index];
                      return DataRow(cells: [
                        DataCell(Text("${index + 1}")), // Posisi
                        DataCell(Text(s.fields.team.toString())), // TODO: Ganti nama Tim jika model sudah di-fetch namanya
                        DataCell(Text("${s.fields.played}")),
                        DataCell(Text("${s.fields.win}")),
                        DataCell(Text("${s.fields.draw}")),
                        DataCell(Text("${s.fields.loss}")),
                        DataCell(Text("${s.fields.points}", style: const TextStyle(fontWeight: FontWeight.bold))),
                      ]);
                    }),
                  ),
                ),
              
              const SizedBox(height: 24),

              // === BAGIAN PERTANDINGAN TERAKHIR ===
              _buildSectionTitle("Pertandingan Terakhir"),
              const SizedBox(height: 8),
              if (limitedFinished.isEmpty) const Text("Belum ada pertandingan selesai."),
              ...limitedFinished.map((m) => _buildMatchCard(m, isFinished: true)).toList(),

              const SizedBox(height: 24),

              // === BAGIAN JADWAL MENDATANG ===
              _buildSectionTitle("Jadwal Mendatang"),
              const SizedBox(height: 8),
              if (limitedUpcoming.isEmpty) const Text("Belum ada jadwal mendatang."),
              ...limitedUpcoming.map((m) => _buildMatchCard(m, isFinished: false)).toList(),
            ],
          ),
        );
      },
    );
  }

  // --- Helper Widgets ---

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20, 
        fontWeight: FontWeight.bold,
        color: Colors.deepPurple, // Ganti dengan ArenaColor jika mau
      ),
    );
  }

  Widget _buildMatchCard(Match match, {required bool isFinished}) {
    // Format tanggal sederhana
    final dateStr = "${match.fields.date.day}/${match.fields.date.month} ${match.fields.date.hour}:${match.fields.date.minute.toString().padLeft(2, '0')}";

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            // Home Team
            Expanded(
              child: Text(
                match.fields.homeTeam.toString(), // TODO: Nama Tim
                textAlign: TextAlign.right,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            
            // Skor atau VS
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: isFinished
                  ? Text(
                      "${match.fields.homeScore} - ${match.fields.awayScore}",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    )
                  : const Text("VS", style: TextStyle(color: Colors.grey)),
            ),

            // Away Team
            Expanded(
              child: Text(
                match.fields.awayTeam.toString(), // TODO: Nama Tim
                textAlign: TextAlign.left,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),

            // Tanggal (Kecil di pojok)
            Text(dateStr, style: const TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}