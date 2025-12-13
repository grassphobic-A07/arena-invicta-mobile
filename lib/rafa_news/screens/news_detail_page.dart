import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

import 'package:arena_invicta_mobile/global/widgets/app_colors.dart';
import 'package:arena_invicta_mobile/global/environments.dart';
import 'package:arena_invicta_mobile/rafa_news/models/news_entry.dart';
import 'package:arena_invicta_mobile/rafa_news/screens/news_form_page.dart';
import 'package:arena_invicta_mobile/main.dart';

class NewsDetailPage extends StatefulWidget {
  final NewsEntry news;

  const NewsDetailPage({super.key, required this.news});

  @override
  State<NewsDetailPage> createState() => _NewsDetailPageState();
}

class _NewsDetailPageState extends State<NewsDetailPage> {
  late int _dynamicViews;

  @override
  void initState() {
    super.initState();
    
    // 1. OPTIMISTIC UPDATE: Langsung tambah 1 secara visual agar terasa instan
    // Nanti angka ini akan ditimpa oleh data asli dari server jika request selesai
    _dynamicViews = widget.news.newsViews + 1;

    // 2. Panggil fungsi untuk increment views di server
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchDetailAndIncrement();
    });
  }

  Future<void> _fetchDetailAndIncrement() async {
    final request = context.read<CookieRequest>();
    // URL Endpoint JSON
    final String url = '$baseUrl/news/${widget.news.id}/json-data';

    try {
      final response = await request.get(url);
      
      // --- PERBAIKAN UTAMA: CEK MOUNTED ---
      // Jika widget sudah dibuang (user sudah back), hentikan proses di sini.
      // Ini mencegah error "setState() called after dispose()"
      if (!mounted) return;

      if (response != null && response['news_views'] != null) {
        setState(() {
          // Update angka views dengan data valid dari server
          _dynamicViews = response['news_views'];
        });
      }
    } catch (e) {
      debugPrint("Gagal increment views: $e");
    }
  }
  
  // --- FUNGSI HAPUS BERITA ---
  Future<void> _deleteNews(CookieRequest request) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ArenaColor.darkAmethystLight,
        title: const Text("Hapus Berita?", style: TextStyle(color: Colors.white)),
        content: const Text("Aksi ini tidak dapat dibatalkan.", style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false), 
            child: const Text("Batal", style: TextStyle(color: Colors.grey))
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true), 
            child: const Text("Hapus", style: TextStyle(color: Colors.redAccent))
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final response = await request.post(
        '$baseUrl/news/${widget.news.id}/delete-news-ajax', 
        {}
      );

      if (mounted) {
        if (response['ok'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Berita berhasil dihapus", style: TextStyle(color: Colors.black)), backgroundColor: Colors.green)
          );
          Navigator.pop(context, true); 
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response['error'] ?? "Gagal menghapus"), backgroundColor: Colors.red)
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red)
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    final userProvider = context.watch<UserProvider>();
    
    // Logic Permission
    final bool canAction = userProvider.isLoggedIn && 
        (userProvider.role == UserRole.admin || userProvider.username == widget.news.author);

    final String proxyUrl = "$baseUrl/proxy-image/?url=${Uri.encodeComponent(widget.news.thumbnail ?? '')}";

    return Scaffold(
      backgroundColor: ArenaColor.darkAmethyst,
      body: CustomScrollView(
        slivers: [
          // 1. App Bar
          SliverAppBar(
            expandedHeight: 300,
            backgroundColor: ArenaColor.darkAmethyst,
            pinned: true,
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black45,
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            
            // Tombol Opsi (Hanya jika Authorized)
            actions: canAction ? [
              Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black45,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Colors.white),
                  color: ArenaColor.darkAmethyst,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  onSelected: (value) async {
                    if (value == 'edit') {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NewsFormPage(newsToEdit: widget.news),
                        ),
                      );
                      if (result == true && context.mounted) {
                        Navigator.pop(context, true); 
                      }
                    } else if (value == 'delete') {
                      _deleteNews(request);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, color: Colors.white, size: 20), 
                          SizedBox(width: 10), 
                          Text("Edit News", style: TextStyle(color: Colors.white))
                        ]
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.redAccent, size: 20), 
                          SizedBox(width: 10), 
                          Text("Delete News", style: TextStyle(color: Colors.redAccent))
                        ]
                      ),
                    ),
                  ],
                ),
              )
            ] : [],

            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: "news_img_${widget.news.id}",
                    child: Image.network(
                      proxyUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: ArenaColor.darkAmethystLight,
                        child: const Icon(Icons.broken_image, color: Colors.white54),
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, ArenaColor.darkAmethyst.withOpacity(0.9)],
                        stops: const [0.6, 1.0],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. Konten Berita
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: ArenaColor.dragonFruit.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: ArenaColor.dragonFruit),
                        ),
                        child: Text(
                          "${widget.news.sports.toUpperCase()} • ${widget.news.category.toUpperCase()}",
                          style: const TextStyle(color: ArenaColor.dragonFruit, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        widget.news.createdAt.toString().split(' ')[0],
                        style: const TextStyle(color: Colors.white54, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.news.title,
                    style: GoogleFonts.poppins(
                      color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const CircleAvatar(radius: 12, backgroundColor: Colors.white24, child: Icon(Icons.person, size: 14, color: Colors.white)),
                      const SizedBox(width: 8),
                      Expanded(child: Text(widget.news.author, style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
                      const SizedBox(width: 10),
                      const Icon(Icons.visibility, size: 14, color: Colors.white38),
                      const SizedBox(width: 4),
                      Text("$_dynamicViews Views", style: const TextStyle(color: Colors.white38, fontSize: 12)),
                      
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Divider(color: Colors.white10),
                  const SizedBox(height: 24),
                  Text(
                    widget.news.content,
                    style: GoogleFonts.poppins(color: Colors.white70, fontSize: 16, height: 1.8),
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}