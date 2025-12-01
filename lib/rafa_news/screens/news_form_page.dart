import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:arena_invicta_mobile/global/widgets/app_colors.dart';

class NewsFormPage extends StatefulWidget {
  static const String routeName = '/create-news';

  const NewsFormPage({super.key});

  @override
  State<NewsFormPage> createState() => _NewsFormPageState();
}

class _NewsFormPageState extends State<NewsFormPage> {
  final _formKey = GlobalKey<FormState>();

  // --- Form Fields Variables ---
  String _title = "";
  String _content = "";
  String _thumbnail = "";
  String? _selectedSport;
  String? _selectedCategory;
  bool _isFeatured = false;
  bool _isLoading = false;

  // --- Dropdown Options ---
  final List<Map<String, String>> _sportsOptions = [
    {'value': 'football', 'label': 'Football'},
    {'value': 'basketball', 'label': 'Basketball'},
    {'value': 'tennis', 'label': 'Tennis'},
    {'value': 'volleyball', 'label': 'Volleyball'},
    {'value': 'motogp', 'label': 'MotoGP'},
  ];

  final List<Map<String, String>> _categoryOptions = [
    {'value': 'update', 'label': 'Update'},
    {'value': 'analysis', 'label': 'Analysis'},
    {'value': 'exclusive', 'label': 'Exclusive'},
    {'value': 'rumor', 'label': 'Rumor'},
    {'value': 'match', 'label': 'Match'},
  ];

  // --- Fungsi Submit ---
  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() => _isLoading = true);

      final request = context.read<CookieRequest>();

      try {
        // Endpoint Django
        final response = await request.post(
          "https://neal-guarddin-arenainvicta.pbp.cs.ui.ac.id/create-news-ajax",
          {
            'title': _title,
            'content': _content,
            'category': _selectedCategory,
            'sports': _selectedSport,
            'thumbnail': _thumbnail,
            'is_featured': _isFeatured ? 'on' : '', 
          },
        );

        if (context.mounted) {
          setState(() => _isLoading = false);
          
          // Cek response dari JsonResponse Django
          if (response['id'] != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Berita berhasil dibuat!"), backgroundColor: Colors.green),
            );
            Navigator.pop(context); // Kembali ke halaman sebelumnya
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(response['error'] ?? "Gagal membuat berita"), backgroundColor: Colors.red),
            );
          }
        }
      } catch (e) {
        if (context.mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  InputDecoration _inputDecoration(String label, String hint) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: const TextStyle(color: Colors.white70),
      hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
      filled: true,
      fillColor: Colors.black.withOpacity(0.2),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ArenaColor.darkAmethyst,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Create News",
          style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. TITLE
              TextFormField(
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration("Title", "Judul Berita"),
                onSaved: (value) => _title = value!,
                validator: (value) => value!.isEmpty ? "Judul tidak boleh kosong" : null,
              ),
              const SizedBox(height: 20),

              // 2. THUMBNAIL URL
              TextFormField(
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration("Thumbnail URL", "https://example.com/image.jpg"),
                onSaved: (value) => _thumbnail = value!,
                validator: (value) => value!.isEmpty ? "URL Gambar tidak boleh kosong" : null,
              ),
              const SizedBox(height: 20),

              // 3. DROPDOWN SPORTS
              DropdownButtonFormField<String>(
                dropdownColor: ArenaColor.darkAmethyst,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration("Sport", "Pilih Cabang Olahraga"),
                items: _sportsOptions.map((item) {
                  return DropdownMenuItem(
                    value: item['value'],
                    child: Text(item['label']!),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _selectedSport = val),
                validator: (value) => value == null ? "Pilih salah satu" : null,
              ),
              const SizedBox(height: 20),

              // 4. DROPDOWN CATEGORY
              DropdownButtonFormField<String>(
                dropdownColor: ArenaColor.darkAmethyst,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration("Category", "Pilih Kategori Berita"),
                items: _categoryOptions.map((item) {
                  return DropdownMenuItem(
                    value: item['value'],
                    child: Text(item['label']!),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _selectedCategory = val),
                validator: (value) => value == null ? "Pilih salah satu" : null,
              ),
              const SizedBox(height: 20),

              // 5. CONTENT
              TextFormField(
                style: const TextStyle(color: Colors.white),
                maxLines: 10,
                decoration: _inputDecoration("Content", "Isi berita..."),
                onSaved: (value) => _content = value!,
                validator: (value) => value!.isEmpty ? "Konten tidak boleh kosong" : null,
              ),
              const SizedBox(height: 20),

              // 6. IS FEATURED SWITCH
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: SwitchListTile(
                  title: const Text("Featured News?", style: TextStyle(color: Colors.white)),
                  subtitle: const Text("Tampilkan di Carousel Home", style: TextStyle(color: Colors.white54, fontSize: 12)),
                  value: _isFeatured,
                  activeColor: ArenaColor.dragonFruit,
                  onChanged: (val) => setState(() => _isFeatured = val),
                ),
              ),
              const SizedBox(height: 30),

              // 7. SUBMIT BUTTON
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ArenaColor.dragonFruit,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 10,
                    shadowColor: ArenaColor.dragonFruit.withOpacity(0.5),
                  ),
                  onPressed: _isLoading ? null : _submitForm,
                  child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("POST NEWS", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}