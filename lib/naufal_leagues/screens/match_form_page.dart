import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:intl/intl.dart'; // Pastikan add dependency intl di pubspec.yaml

import 'package:arena_invicta_mobile/global/widgets/app_colors.dart';
import 'package:arena_invicta_mobile/naufal_leagues/models/match.dart';
import 'package:arena_invicta_mobile/naufal_leagues/models/team.dart';
import 'package:arena_invicta_mobile/naufal_leagues/services/league_service.dart';

class MatchFormPage extends StatefulWidget {
  final Match? match; // Jika null = Create, Ada = Edit

  const MatchFormPage({super.key, this.match});

  @override
  State<MatchFormPage> createState() => _MatchFormPageState();
}

class _MatchFormPageState extends State<MatchFormPage> {
  final _formKey = GlobalKey<FormState>();
  
  // Input Controllers
  int? _homeTeamId;
  int? _awayTeamId;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = const TimeOfDay(hour: 15, minute: 30);
  
  final TextEditingController _homeScoreController = TextEditingController(text: "0");
  final TextEditingController _awayScoreController = TextEditingController(text: "0");
  bool _isFinished = false;

  List<Team> _teams = [];
  bool _isLoadingTeams = true;

  @override
  void initState() {
    super.initState();
    _fetchTeams();

    if (widget.match != null) {
      final m = widget.match!.fields;
      _homeTeamId = m.homeTeam;
      _awayTeamId = m.awayTeam;
      _selectedDate = m.date;
      _selectedTime = TimeOfDay.fromDateTime(m.date); // Konversi DateTime ke TimeOfDay
      _homeScoreController.text = m.homeScore.toString();
      _awayScoreController.text = m.awayScore.toString();
      _isFinished = m.status == "FINISHED";
    }
  }

  Future<void> _fetchTeams() async {
    final request = context.read<CookieRequest>();
    try {
      final teams = await LeagueService().fetchTeams(request);
      setState(() {
        _teams = teams;
        _isLoadingTeams = false;
      });
    } catch (e) {
      setState(() => _isLoadingTeams = false);
    }
  }

  // Helper untuk memilih Tanggal
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  // Helper untuk memilih Jam
  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    final isEdit = widget.match != null;

    return Scaffold(
      backgroundColor: ArenaColor.darkAmethyst,
      appBar: AppBar(
        title: Text(isEdit ? "Edit Pertandingan" : "Buat Jadwal Baru"),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
      ),
      body: _isLoadingTeams
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // --- PILIH TIM (HOME & AWAY) ---
                  Row(
                    children: [
                      Expanded(
                        child: _buildDropdown("Home Team", _homeTeamId, (val) => setState(() => _homeTeamId = val)),
                      ),
                      const SizedBox(width: 16),
                      const Text("VS", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildDropdown("Away Team", _awayTeamId, (val) => setState(() => _awayTeamId = val)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // --- PILIH WAKTU ---
                  const Text("Waktu Kick-off", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _pickDate,
                          icon: const Icon(Icons.calendar_today, color: Colors.white70),
                          label: Text(DateFormat('yyyy-MM-dd').format(_selectedDate), style: const TextStyle(color: Colors.white)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _pickTime,
                          icon: const Icon(Icons.access_time, color: Colors.white70),
                          label: Text(_selectedTime.format(context), style: const TextStyle(color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // --- SKOR & STATUS (Hanya relevan jika pertandingan sudah mulai/selesai) ---
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
                    child: Column(
                      children: [
                        SwitchListTile(
                          title: const Text("Pertandingan Selesai?", style: TextStyle(color: Colors.white)),
                          value: _isFinished,
                          activeColor: ArenaColor.dragonFruit,
                          onChanged: (val) => setState(() => _isFinished = val),
                        ),
                        if (_isFinished || isEdit) ...[
                           const Divider(color: Colors.white24),
                           Row(
                             children: [
                               Expanded(child: _buildNumberField("Skor Home", _homeScoreController)),
                               const SizedBox(width: 20),
                               Expanded(child: _buildNumberField("Skor Away", _awayScoreController)),
                             ],
                           ),
                        ]
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // --- SUBMIT BUTTON ---
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ArenaColor.dragonFruit,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        // Validasi tim sama
                        if (_homeTeamId == _awayTeamId) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Tim Home dan Away tidak boleh sama!")));
                          return;
                        }

                        // Gabungkan Date & Time
                        final finalDateTime = DateTime(
                          _selectedDate.year, _selectedDate.month, _selectedDate.day,
                          _selectedTime.hour, _selectedTime.minute
                        );

                        // Siapkan Data
                        // Format tanggal ISO 8601 string agar bisa diparse Django
                        final data = {
                          "home_team_id": _homeTeamId,
                          "away_team_id": _awayTeamId,
                          "date": finalDateTime.toIso8601String(),
                          "home_score": int.parse(_homeScoreController.text),
                          "away_score": int.parse(_awayScoreController.text),
                          "is_finished": _isFinished,
                        };

                        final service = LeagueService();
                        Map<String, dynamic> response;

                        try {
                          if (isEdit) {
                            response = await service.editMatch(request, widget.match!.pk, data);
                          } else {
                            response = await service.createMatch(request, data);
                          }

                          if (context.mounted) {
                            if (response['status'] == 'success') {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Berhasil menyimpan jadwal!")));
                              Navigator.pop(context, true);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal: ${response['message']}")));
                            }
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
                        }
                      }
                    },
                    child: Text(isEdit ? "Update Match" : "Create Match", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildDropdown(String label, int? value, Function(int?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        DropdownButtonFormField<int>(
          value: value,
          dropdownColor: const Color(0xFF2A2045),
          style: const TextStyle(color: Colors.white),
          isExpanded: true, // Agar teks panjang tidak overflow
          items: _teams.map((t) => DropdownMenuItem(value: t.pk, child: Text(t.fields.name, overflow: TextOverflow.ellipsis))).toList(),
          onChanged: onChanged,
          validator: (v) => v == null ? "Wajib" : null,
          decoration: const InputDecoration(enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24))),
        ),
      ],
    );
  }
  
  Widget _buildNumberField(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      textAlign: TextAlign.center,
      style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70, fontSize: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white.withOpacity(0.2))),
      ),
    );
  }
}