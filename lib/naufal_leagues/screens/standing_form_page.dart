import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:arena_invicta_mobile/global/environments.dart';
import 'package:arena_invicta_mobile/global/widgets/app_colors.dart';
import 'package:arena_invicta_mobile/naufal_leagues/models/team.dart';
import 'package:arena_invicta_mobile/naufal_leagues/models/standing.dart'; // Import Standing
import 'package:arena_invicta_mobile/naufal_leagues/services/league_service.dart';

class StandingFormPage extends StatefulWidget {
  // Tambahkan parameter opsional ini
  final Standing? standing; 
  
  const StandingFormPage({super.key, this.standing});

  @override
  State<StandingFormPage> createState() => _StandingFormPageState();
}

class _StandingFormPageState extends State<StandingFormPage> {
  final _formKey = GlobalKey<FormState>();

  String _season = "2023/2024";
  Team? _selectedTeam;
  int _played = 0;
  int _win = 0;
  int _draw = 0;
  int _loss = 0;
  int _points = 0;
  int _gf = 0;
  int _ga = 0;

  List<Team> _teamList = [];

  @override
  void initState() {
    super.initState();
    final request = context.read<CookieRequest>();
    
    // 1. Ambil Data Teams
    LeagueService().fetchTeams(request).then((teams) {
      setState(() {
        _teamList = teams;
        
        // 2. JIKA MODE EDIT (widget.standing tidak null)
        if (widget.standing != null) {
          // Isi form dengan data lama
          _season = widget.standing!.fields.season;
          _played = widget.standing!.fields.played;
          _win = widget.standing!.fields.win;
          _draw = widget.standing!.fields.draw;
          _loss = widget.standing!.fields.loss;
          _points = widget.standing!.fields.points;
          _gf = widget.standing!.fields.gf;
          _ga = widget.standing!.fields.ga;
          
          // Cari team yang sesuai di dropdown
          // Kita cari tim yang ID-nya sama dengan standing.fields.team
          try {
            _selectedTeam = teams.firstWhere((t) => t.pk == widget.standing!.fields.team);
          } catch (e) {
            // Team mungkin terhapus atau tidak ditemukan
          }
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    // Cek apakah mode edit
    final bool isEditing = widget.standing != null; 

    return Scaffold(
      backgroundColor: ArenaColor.darkAmethyst,
      appBar: AppBar(
        // Judul Dinamis
        title: Text(isEditing ? "Edit Standing" : "Add Standing Data", style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // Dropdown Team (Disable jika Edit, biar ga ganti tim sembarangan)
              DropdownButtonFormField<Team>(
                decoration: _inputDecoration("Select Team"),
                value: _selectedTeam,
                items: _teamList.map((Team team) {
                  return DropdownMenuItem<Team>(
                    value: team,
                    child: Text(team.fields.name, style: const TextStyle(color: Colors.black87)),
                  );
                }).toList(),
                onChanged: isEditing ? null : (Team? newValue) { // Disable if editing
                  setState(() {
                    _selectedTeam = newValue;
                  });
                },
                validator: (value) => value == null ? "Pilih tim terlebih dahulu" : null,
                dropdownColor: Colors.white,
              ),
              const SizedBox(height: 16),

              TextFormField(
                initialValue: _season,
                decoration: _inputDecoration("Season"),
                style: const TextStyle(color: Colors.white),
                onChanged: (val) => _season = val,
              ),
              const SizedBox(height: 16),

              // Statistik
              Row(
                children: [
                  Expanded(child: _buildNumberField("Played", _played, (val) => _played = val)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildNumberField("Points", _points, (val) => _points = val)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildNumberField("Win", _win, (val) => _win = val)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildNumberField("Draw", _draw, (val) => _draw = val)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildNumberField("Loss", _loss, (val) => _loss = val)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildNumberField("GF", _gf, (val) => _gf = val)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildNumberField("GA", _ga, (val) => _ga = val)),
                ],
              ),

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ArenaColor.dragonFruit,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      int gd = _gf - _ga;

                      // Tentukan URL dan Payload
                      String url;
                      if (isEditing) {
                        url = "$baseUrl/leagues/api/standings/edit/${widget.standing!.pk}/";
                      } else {
                        url = "$baseUrl/leagues/api/standings/create/";
                      }

                      final response = await request.postJson(
                        url,
                        jsonEncode({
                          'team_id': _selectedTeam!.pk.toString(),
                          'season': _season,
                          'played': _played.toString(),
                          'win': _win.toString(),
                          'draw': _draw.toString(),
                          'loss': _loss.toString(),
                          'points': _points.toString(),
                          'gf': _gf.toString(),
                          'ga': _ga.toString(),
                          'gd': gd.toString(),
                        }),
                      );

                      if (context.mounted) {
                        if (response['status'] == 'success') {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(response['message'])));
                          Navigator.pop(context, true);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal: ${response['message']}")));
                        }
                      }
                    }
                  },
                  child: Text(isEditing ? "Update Data" : "Save Data", style: const TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      filled: true,
      fillColor: Colors.white.withOpacity(0.1),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    );
  }

  // Helper updated untuk menerima initial value
  Widget _buildNumberField(String label, int initialVal, Function(int) onChanged) {
    return TextFormField(
      initialValue: initialVal.toString(), // PREFILL DATA
      decoration: _inputDecoration(label),
      style: const TextStyle(color: Colors.white),
      keyboardType: TextInputType.number,
      onChanged: (val) => onChanged(int.tryParse(val) ?? 0),
    );
  }
}