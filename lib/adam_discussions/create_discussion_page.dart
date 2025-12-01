import 'dart:convert';

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
  final _newsIdController = TextEditingController();
  String? _newsPreview;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    _newsIdController.dispose();
    super.dispose();
  }

  String? _extractNewsId(String raw) {
    final text = raw.trim();
    if (text.isEmpty) return null;
    try {
      final uri = Uri.parse(text);
      final segment = uri.pathSegments.contains('news')
          ? uri.pathSegments[uri.pathSegments.indexOf('news') + 1]
          : (uri.pathSegments.isNotEmpty ? uri.pathSegments.last : text);
      return segment.replaceAll('/', '');
    } catch (_) {
      return text;
    }
  }

  Future<void> _validateNews() async {
    final id = _extractNewsId(_newsIdController.text);
    if (id == null || id.isEmpty) {
      setState(() => _newsPreview = null);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(bottom: 90, left: 16, right: 16),
          content: Text('Masukkan ID/URL berita dulu.'),
        ),
      );
      return;
    }

    try {
      final res = await context.read<CookieRequest>().get(
            'https://neal-guarddin-arenainvicta.pbp.cs.ui.ac.id/news/$id/json-data',
          );
      final title = res['title'] as String? ?? '';
      setState(() => _newsPreview = title.isNotEmpty ? title : null);
    } catch (_) {
      setState(() => _newsPreview = null);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(bottom: 90, left: 16, right: 16),
          content: Text('Berita tidak ditemukan. Coba periksa ID/URL.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final newsId = _extractNewsId(_newsIdController.text);
    if (newsId == null || newsId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(bottom: 90, left: 16, right: 16),
          content: Text('Masukkan ID/URL berita terkait.'),
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
      final payload = jsonEncode({
        'title': _titleController.text.trim(),
        'body': _bodyController.text.trim(),
        'news': newsId,
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
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _newsIdController,
                            decoration: _inputDecoration('ID / URL Berita'),
                            style: const TextStyle(color: Colors.white),
                            validator: (val) => (val == null || val.trim().isEmpty) ? 'ID berita wajib diisi' : null,
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.12),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: _validateNews,
                          child: const Text('Validasi'),
                        ),
                      ],
                    ),
                    if (_newsPreview != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white.withOpacity(0.08)),
                        ),
                        child: Text(
                          'Berita: $_newsPreview',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                        ),
                      ),
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
