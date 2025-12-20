import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

// Import Global Widgets & Colors (Sesuaikan path jika berbeda)
import 'package:arena_invicta_mobile/global/widgets/app_colors.dart';

// Import Models & Services
import 'package:arena_invicta_mobile/naufal_leagues/models/standing.dart';
import 'package:arena_invicta_mobile/naufal_leagues/models/team.dart';
import 'package:arena_invicta_mobile/naufal_leagues/services/league_service.dart';

class StandingFormPage extends StatefulWidget {
  final Standing? standing; // Jika null berarti mode CREATE, jika ada berarti EDIT

  const StandingFormPage({super.key, this.standing});

  @override
  State<StandingFormPage> createState() => _StandingFormPageState();
}

class _StandingFormPageState extends State<StandingFormPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers untuk Input Angka
  final TextEditingController _winController = TextEditingController();
  final TextEditingController _drawController = TextEditingController();
  final TextEditingController _lossController = TextEditingController();
  final TextEditingController _gfController = TextEditingController();
  final TextEditingController _gaController = TextEditingController();

  // State untuk Dropdown & Data
  int? _selectedTeamId;
  String _season = "23/24"; // Default season (bisa dikembangkan jadi dropdown juga)
  List<Team> _teams = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTeams(); // Ambil data tim saat halaman dibuka
    
    // Jika mode EDIT, isi form dengan data yang ada
    if (widget.standing != null) {
      final data = widget.standing!.fields;
      _selectedTeamId = data.team; // ID Team dari object Standing
      _season = data.season;
      _winController.text = data.win.toString();
      _drawController.text = data.draw.toString();
      _lossController.text = data.loss.toString();
      _gfController.text = data.gf.toString();
      _gaController.text = data.ga.toString();
    }
  }

  @override
  void dispose() {
    // Bersihkan controller agar tidak memakan memori
    _winController.dispose();
    _drawController.dispose();
    _lossController.dispose();
    _gfController.dispose();
    _gaController.dispose();
    super.dispose();
  }

  // Fungsi Asinkronus mengambil daftar Tim dari Django
  Future<void> _fetchTeams() async {
    final request = context.read<CookieRequest>();
    try {
      final teams = await LeagueService().fetchTeams(request);
      setState(() {
        _teams = teams;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal memuat tim: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    final isEdit = widget.standing != null;

    return Scaffold(
      backgroundColor: ArenaColor.darkAmethyst, // Warna Background Utama
      appBar: AppBar(
        title: Text(
          isEdit ? "Edit Data Klasemen" : "Tambah Data Klasemen",
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: ArenaColor.dragonFruit))
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // --- 1. DROPDOWN TEAM ---
                  const Text("Tim", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<int>(
                    value: _selectedTeamId,
                    dropdownColor: const Color(0xFF2A2045), // Warna dropdown menu
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration("Pilih Tim"),
                    items: _teams.map((Team team) {
                      return DropdownMenuItem<int>(
                        value: team.pk,
                        child: Text(team.fields.name),
                      );
                    }).toList(),
                    onChanged: isEdit 
                        ? null // Jika Edit, tim tidak boleh diganti (opsional logic)
                        : (value) {
                            setState(() {
                              _selectedTeamId = value;
                            });
                          },
                    validator: (value) => value == null ? "Harap pilih tim!" : null,
                  ),
                  const SizedBox(height: 20),

                  // --- 2. INPUT STATISTIK PERTANDINGAN ---
                  Row(
                    children: [
                      Expanded(child: _buildNumberField("Menang (Win)", _winController)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildNumberField("Seri (Draw)", _drawController)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildNumberField("Kalah (Loss)", _lossController)),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // --- 3. INPUT STATISTIK GOL ---
                  Row(
                    children: [
                      Expanded(child: _buildNumberField("Gol Masuk (GF)", _gfController)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildNumberField("Kebobolan (GA)", _gaController)),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // --- 4. TOMBOL SIMPAN ---
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ArenaColor.dragonFruit,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        // Tampilkan loading dialog (opsional) atau langsung proses
                        
                        // Siapkan Data JSON
                        final data = {
                          "team_id": _selectedTeamId,
                          "season": _season,
                          "win": int.parse(_winController.text),
                          "draw": int.parse(_drawController.text),
                          "loss": int.parse(_lossController.text),
                          "gf": int.parse(_gfController.text),
                          "ga": int.parse(_gaController.text),
                          // Poin, Played, GD dihitung otomatis di Backend Django
                        };

                        // Panggil Service
                        final service = LeagueService();
                        Map<String, dynamic> response;

                        try {
                          if (isEdit) {
                            response = await service.editStanding(request, widget.standing!.pk, data);
                          } else {
                            response = await service.createStanding(request, data);
                          }

                          if (context.mounted) {
                            if (response['status'] == 'success') {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Data berhasil disimpan!")),
                              );
                              // Kembali ke halaman sebelumnya dengan membawa sinyal 'true' (refresh)
                              Navigator.pop(context, true); 
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Gagal: ${response['message']}"),
                                  backgroundColor: Colors.redAccent,
                                ),
                              );
                            }
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Terjadi kesalahan: $e")),
                            );
                          }
                        }
                      }
                    },
                    child: Text(
                      isEdit ? "Update Perubahan" : "Simpan Data",
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  // Helper Widget untuk Input Angka yang Rapi
  Widget _buildNumberField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.white),
          decoration: _inputDecoration("0"),
          validator: (value) {
            if (value == null || value.isEmpty) return "Wajib";
            if (int.tryParse(value) == null) return "Angka";
            return null;
          },
        ),
      ],
    );
  }

  // Styling Input Decoration
  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white30),
      filled: true,
      fillColor: Colors.white.withOpacity(0.1),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: ArenaColor.dragonFruit),
      ),
      errorStyle: const TextStyle(color: Colors.redAccent),
    );
  }
}