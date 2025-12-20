import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:arena_invicta_mobile/global/widgets/app_colors.dart';
import 'package:arena_invicta_mobile/naufal_leagues/models/team.dart'; // Import Model Team
import 'package:arena_invicta_mobile/naufal_leagues/services/league_service.dart';

class TeamFormPage extends StatefulWidget {
  final Team? team; // Tambahkan parameter ini

  const TeamFormPage({super.key, this.team});

  @override
  State<TeamFormPage> createState() => _TeamFormPageState();
}

class _TeamFormPageState extends State<TeamFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _shortNameController;
  late TextEditingController _yearController;

  @override
  void initState() {
    super.initState();
    // Isi data jika mode EDIT
    _nameController = TextEditingController(text: widget.team?.fields.name ?? "");
    _shortNameController = TextEditingController(text: widget.team?.fields.shortName ?? "");
    _yearController = TextEditingController(text: widget.team != null ? widget.team!.fields.foundedYear.toString() : "");
  }

  @override
  void dispose() {
    _nameController.dispose();
    _shortNameController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    final isEdit = widget.team != null;

    return Scaffold(
      backgroundColor: ArenaColor.darkAmethyst,
      appBar: AppBar(
        title: Text(isEdit ? "Edit Tim" : "Tambah Tim Baru", style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildTextField("Nama Tim (Lengkap)", _nameController),
            const SizedBox(height: 16),
            _buildTextField("Nama Singkat (3-5 Huruf)", _shortNameController),
            const SizedBox(height: 16),
            _buildTextField("Tahun Berdiri", _yearController, isNumber: true),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: ArenaColor.dragonFruit,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  final data = {
                    "name": _nameController.text,
                    "short_name": _shortNameController.text,
                    "founded_year": int.tryParse(_yearController.text) ?? 2023,
                  };

                  try {
                    Map<String, dynamic> response;
                    if (isEdit) {
                      response = await LeagueService().editTeam(request, widget.team!.pk, data);
                    } else {
                      response = await LeagueService().createTeam(request, data);
                    }

                    if (context.mounted) {
                      if (response['status'] == 'success') {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Data tim berhasil disimpan!")),
                        );
                        Navigator.pop(context, true);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Gagal: ${response['message']}")),
                        );
                      }
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
                  }
                }
              },
              child: Text(isEdit ? "Update Tim" : "Simpan Tim", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
    
  // ... _buildTextField sama seperti sebelumnya ...
  Widget _buildTextField(String label, TextEditingController controller, {bool isNumber = false}) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: (val) => val == null || val.isEmpty ? "Wajib diisi" : null,
    );
  }
}