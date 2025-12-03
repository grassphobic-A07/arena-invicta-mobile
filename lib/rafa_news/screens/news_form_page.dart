import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

import 'package:arena_invicta_mobile/global/widgets/app_colors.dart';
import 'package:arena_invicta_mobile/global/environments.dart'; 
import 'package:arena_invicta_mobile/rafa_news/models/news_entry.dart'; 

class NewsFormPage extends StatefulWidget {
  static const String routeName = '/create-news';
  final NewsEntry? newsToEdit; 

  const NewsFormPage({super.key, this.newsToEdit});

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

  @override
  void initState() {
    super.initState();
    if (widget.newsToEdit != null) {
      _title = widget.newsToEdit!.title;
      _content = widget.newsToEdit!.content;
      _thumbnail = widget.newsToEdit!.thumbnail ?? "";
      _selectedSport = widget.newsToEdit!.sports.toLowerCase(); 
      _selectedCategory = widget.newsToEdit!.category.toLowerCase();
      _isFeatured = widget.newsToEdit!.isFeatured;
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() => _isLoading = true);

      final request = context.read<CookieRequest>();

      try {
        String url;
        if (widget.newsToEdit != null) {
          url = "$baseUrl/news/${widget.newsToEdit!.id}/edit_news_ajax";
        } else {
          url = "$baseUrl/create-news-ajax";
        }

        final response = await request.post(
          url,
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
          
          if (response['ok'] == true || response['id'] != null || response['status'] == true) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(widget.newsToEdit != null ? "Berita berhasil diupdate!" : "Berita berhasil dibuat!"), 
                backgroundColor: Colors.green
              ),
            );
            Navigator.pop(context, true); 
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(response['error'] ?? response['message'] ?? "Gagal menyimpan berita"), backgroundColor: Colors.red),
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
      labelStyle: GoogleFonts.poppins(color: Colors.white70),
      hintStyle: GoogleFonts.poppins(color: Colors.white.withOpacity(0.3)),
      filled: true,
      fillColor: Colors.black.withOpacity(0.2),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.white.withOpacity(0.1))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: ArenaColor.dragonFruit)),
    );
  }

  // --- HELPER BACKGROUND GLOW ---
  Widget _buildGlowCircle(Color color) {
    return Container(
      width: 300, height: 300,
      decoration: BoxDecoration(
        color: color.withOpacity(0.2), 
        shape: BoxShape.circle,
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
        child: Container(color: Colors.transparent),
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
          widget.newsToEdit != null ? "Edit News" : "Create News",
          style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      // --- GUNAKAN STACK UNTUK BACKGROUND ---
      body: Stack(
        children: [
          // 1. Background Glows
          Positioned(top: -100, left: -50, child: _buildGlowCircle(ArenaColor.darkAmethystLight)),
          Positioned(bottom: -100, right: -50, child: _buildGlowCircle(ArenaColor.dragonFruit)),

          // 2. Content Form (Scrollable)
          Positioned.fill(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. TITLE
                    TextFormField(
                      initialValue: _title,
                      style: GoogleFonts.poppins(color: Colors.white),
                      decoration: _inputDecoration("Title", "Judul Berita"),
                      onSaved: (value) => _title = value!,
                      validator: (value) => value!.isEmpty ? "Judul tidak boleh kosong" : null,
                    ),
                    const SizedBox(height: 20),

                    // 2. THUMBNAIL URL
                    TextFormField(
                      initialValue: _thumbnail,
                      style: GoogleFonts.poppins(color: Colors.white),
                      decoration: _inputDecoration("Thumbnail URL", "https://example.com/image.jpg"),
                      onSaved: (value) => _thumbnail = value!,
                      validator: (value) => value!.isEmpty ? "URL Gambar tidak boleh kosong" : null,
                    ),
                    const SizedBox(height: 20),

                    // 3. DROPDOWN SPORTS
                    DropdownButtonFormField<String>(
                      value: _selectedSport,
                      dropdownColor: ArenaColor.darkAmethyst,
                      style: GoogleFonts.poppins(color: Colors.white),
                      decoration: _inputDecoration("Sport", ""),
                      hint: Text("Pilih Cabang Olahraga", style: GoogleFonts.poppins(color: Colors.white70)),
                      items: _sportsOptions.map((item) {
                        return DropdownMenuItem(
                          value: item['value'],
                          child: Text(item['label']!, style: GoogleFonts.poppins()),
                        );
                      }).toList(),
                      onChanged: (val) => setState(() => _selectedSport = val),
                      validator: (value) => value == null ? "Pilih salah satu" : null,
                    ),
                    const SizedBox(height: 20),

                    // 4. DROPDOWN CATEGORY
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      dropdownColor: ArenaColor.darkAmethyst,
                      style: GoogleFonts.poppins(color: Colors.white),
                      decoration: _inputDecoration("Category", ""),
                      hint: Text("Pilih Kategori Berita", style: GoogleFonts.poppins(color: Colors.white70)),
                      items: _categoryOptions.map((item) {
                        return DropdownMenuItem(
                          value: item['value'],
                          child: Text(item['label']!, style: GoogleFonts.poppins()),
                        );
                      }).toList(),
                      onChanged: (val) => setState(() => _selectedCategory = val),
                      validator: (value) => value == null ? "Pilih salah satu" : null,
                    ),
                    const SizedBox(height: 20),

                    // 5. CONTENT
                    TextFormField(
                      initialValue: _content,
                      style: GoogleFonts.poppins(color: Colors.white),
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
                        title: Text("Featured News?", style: GoogleFonts.poppins(color: Colors.white)),
                        subtitle: Text("Tampilkan di Carousel Home", style: GoogleFonts.poppins(color: Colors.white54, fontSize: 12)),
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
                          : Text(
                              widget.newsToEdit != null ? "UPDATE NEWS" : "POST NEWS",
                              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                            ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}