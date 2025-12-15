import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:arena_invicta_mobile/global/environments.dart';
import 'package:arena_invicta_mobile/global/widgets/app_colors.dart';

class TeamFormPage extends StatefulWidget {
  const TeamFormPage({super.key});

  @override
  State<TeamFormPage> createState() => _TeamFormPageState();
}

class _TeamFormPageState extends State<TeamFormPage> {
  final _formKey = GlobalKey<FormState>();
  
  // Variabel untuk menyimpan inputan kamu
  String _name = "";
  String _shortName = "";
  int _foundedYear = 2023;

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      backgroundColor: ArenaColor.darkAmethyst,
      appBar: AppBar(
        title: const Text("Add New Team", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Input Nama Tim ---
              const Text("Team Name", style: TextStyle(color: Colors.white)),
              const SizedBox(height: 8),
              TextFormField(
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Contoh: Manchester United",
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return "Nama tidak boleh kosong!";
                  return null;
                },
                onChanged: (value) => _name = value,
              ),
              
              const SizedBox(height: 20),

              // --- Input Singkatan ---
              const Text("Short Name (3 Huruf)", style: TextStyle(color: Colors.white)),
              const SizedBox(height: 8),
              TextFormField(
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Contoh: MUN",
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onChanged: (value) => _shortName = value,
              ),

              const SizedBox(height: 20),

              // --- Input Tahun ---
              const Text("Founded Year", style: TextStyle(color: Colors.white)),
              const SizedBox(height: 8),
              TextFormField(
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: "Contoh: 1878",
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onChanged: (value) => _foundedYear = int.tryParse(value) ?? 2023,
              ),

              const SizedBox(height: 40),

              // --- Tombol Simpan ---
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ArenaColor.dragonFruit,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      // Kirim data ke Django
                      final response = await request.postJson(
                        "$baseUrl/leagues/api/teams/create/", // Sesuaikan dengan urls.py
                        jsonEncode(<String, String>{
                          'name': _name,
                          'short_name': _shortName,
                          'founded_year': _foundedYear.toString(),
                        }),
                      );

                      if (context.mounted) {
                        if (response['status'] == 'success') {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Tim berhasil disimpan!")),
                          );
                          Navigator.pop(context); // Tutup halaman form
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Gagal: ${response['message']}")),
                          );
                        }
                      }
                    }
                  },
                  child: const Text("Save Team", style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}