import 'dart:convert';

import 'package:arena_invicta_mobile/global/widgets/app_colors.dart';
import 'package:arena_invicta_mobile/main.dart';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class CreateDiscussionPage extends StatefulWidget {
  const CreateDiscussionPage({super.key});

  static const routeName = '/discussions/create';

  @override
  State<CreateDiscussionPage> createState() => _CreateDiscussionPageState();
}

class _CreateDiscussionPageState extends State<CreateDiscussionPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  bool _isSubmitting = false;

  List<NewsOption> _newsOptions = [];
  NewsOption? _selectedNews;
  bool _loadingNews = false;
  String? _newsError;

  @override
  void initState() {
    super.initState();
    _loadNewsOptions();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _loadNewsOptions() async {
    final request = context.read<CookieRequest>();
    if (!request.loggedIn) return;

    setState(() {
      _loadingNews = true;
      _newsError = null;
    });
    try {
      // Fetch the thread create page and parse the news select options (mirrors web UI).
      final html = await request.get(
        'https://neal-guarddin-arenainvicta.pbp.cs.ui.ac.id/discussions/threads/create/',
        headers: const {'Accept': 'text/html'},
      );
      final raw = html is String ? html : html.toString();
      final options = _parseNewsOptions(raw);
      setState(() {
        _newsOptions = options;
        _loadingNews = false;
      });
    } catch (e) {
      setState(() {
        _loadingNews = false;
        _newsError = 'Gagal memuat daftar berita. Pastikan sudah login.';
      });
    }
  }

  List<NewsOption> _parseNewsOptions(String html) {
    final regex = RegExp(
      r'<option[^>]*value="([^"]+)"[^>]*>([^<]+)<\/option>',
      caseSensitive: false,
      multiLine: true,
    );
    final matches = regex.allMatches(html);
    return matches
        .map((m) {
          final value = m.group(1)?.trim() ?? '';
          final label = m.group(2)?.trim() ?? '';
          if (value.isEmpty || value == '---------') return null;
          // Label often contains "(uuid)"; strip if present.
          final cleanedLabel = label.replaceAll(RegExp(r'\s*\([^)]*\)$'), '');
          return NewsOption(id: value, title: cleanedLabel.isNotEmpty ? cleanedLabel : label);
        })
        .whereType<NewsOption>()
        .toList();
  }

  Future<void> _openNewsPicker() async {
    if (_loadingNews) return;
    if (_newsOptions.isEmpty) {
      setState(() => _newsError = 'Daftar berita kosong atau gagal dimuat.');
      return;
    }

    final selected = await showModalBottomSheet<NewsOption>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        final controller = TextEditingController();
        List<NewsOption> filtered = List.of(_newsOptions);
        return StatefulBuilder(
          builder: (context, setModalState) {
            void filter(String query) {
              final q = query.toLowerCase();
              setModalState(() {
                filtered = _newsOptions
                    .where((n) => n.title.toLowerCase().contains(q) || n.id.toLowerCase().contains(q))
                    .toList();
              });
            }

            return DraggableScrollableSheet(
              initialChildSize: 0.65,
              minChildSize: 0.45,
              maxChildSize: 0.9,
              builder: (_, scrollController) {
                return Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E153F),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                    border: Border.all(color: Colors.white.withOpacity(0.08)),
                  ),
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  child: Column(
                    children: [
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: controller,
                        onChanged: filter,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Cari berita...',
                          hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                          filled: true,
                          fillColor: Colors.black.withOpacity(0.25),
                          prefixIcon: const Icon(Icons.search, color: Colors.white70),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: ListView.builder(
                          controller: scrollController,
                          itemCount: filtered.length,
                          itemBuilder: (_, index) {
                            final item = filtered[index];
                            final isSelected = _selectedNews?.id == item.id;
                            return ListTile(
                              title: Text(item.title, style: const TextStyle(color: Colors.white)),
                              subtitle: Text(item.id, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12)),
                              trailing: isSelected ? const Icon(Icons.check, color: Colors.greenAccent) : null,
                              onTap: () => Navigator.pop(context, item),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );

    if (selected != null) {
      setState(() {
        _selectedNews = selected;
        _newsError = null;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedNews == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(bottom: 90, left: 16, right: 16),
          content: Text('Pilih berita terkait terlebih dahulu.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final userProvider = context.read<UserProvider>();
    final request = context.read<CookieRequest>();

    if (!userProvider.isLoggedIn || !request.loggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.only(bottom: 90, left: 16, right: 16),
          content: const Text('Silakan login untuk membuat diskusi.'),
          action: SnackBarAction(
            label: 'Login',
            textColor: Colors.white,
            onPressed: () => Navigator.pushNamed(context, '/login'),
          ),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final newsId = _extractNewsId(_newsIdController.text);
      final payload = jsonEncode({
        'title': _titleController.text.trim(),
        'body': _bodyController.text.trim(),
        'news': _selectedNews!.id,
      });

      final response = await request.postJson(
        'https://neal-guarddin-arenainvicta.pbp.cs.ui.ac.id/discussions/api/threads/create/',
        payload,
      );

      final ok = response['ok'] == true || response['status'] == true;
      if (ok && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.only(bottom: 90, left: 16, right: 16),
            content: Text('Diskusi berhasil dibuat!'),
            backgroundColor: Colors.greenAccent,
          ),
        );
        Navigator.pop(context, true);
      } else if (mounted) {
        final msg = response['message'] ?? response['error'] ?? 'Gagal membuat diskusi.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.only(bottom: 90, left: 16, right: 16),
            content: Text(msg),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } on FormatException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.only(bottom: 90, left: 16, right: 16),
            content: Text('Respon server tidak valid JSON. Pastikan sudah login dan akses diizinkan. Detail: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.only(bottom: 90, left: 16, right: 16),
            content: Text('Error: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.topLeft,
                radius: 1.2,
                colors: [
                  Color(0xFF9333EA),
                  Color(0xFF2A1B54),
                ],
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.bottomRight,
                radius: 1.2,
                colors: [
                  Color(0xFF4A49A0),
                  Color(0xFF2A1B54),
                ],
              ),
            ),
          ),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: const Text('Tulis Diskusi'),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.04),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.08)),
              ),
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: _inputDecoration('Judul diskusi'),
                      style: const TextStyle(color: Colors.white),
                      validator: (val) => (val == null || val.trim().isEmpty) ? 'Judul wajib diisi' : null,
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: _openNewsPicker,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: (_newsError != null)
                                ? Colors.redAccent.withOpacity(0.6)
                                : Colors.white.withOpacity(0.15),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.article_outlined, color: Colors.white70),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _selectedNews?.title ?? 'Pilih berita terkait...',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    _selectedNews?.id ?? (_loadingNews ? 'Memuat daftar berita...' : 'Tap untuk memilih'),
                                    style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.keyboard_arrow_down, color: Colors.white70),
                          ],
                        ),
                      ),
                    ),
                    if (_newsError != null) ...[
                      const SizedBox(height: 6),
                      Text(_newsError!, style: const TextStyle(color: Colors.redAccent, fontSize: 12)),
                    ],
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _bodyController,
                      decoration: _inputDecoration('Tulis opini, pertanyaan, atau analisis...'),
                      style: const TextStyle(color: Colors.white),
                      maxLines: 8,
                      minLines: 4,
                      validator: (val) => (val == null || val.trim().isEmpty) ? 'Konten wajib diisi' : null,
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ArenaColor.dragonFruit,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 8,
                          shadowColor: ArenaColor.dragonFruit.withOpacity(0.4),
                        ),
                        onPressed: _isSubmitting ? null : _submit,
                        child: _isSubmitting
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Posting Diskusi',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
      filled: true,
      fillColor: Colors.black.withOpacity(0.2),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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
        borderSide: const BorderSide(color: ArenaColor.dragonFruit, width: 2),
      ),
    );
  }
}
