import 'dart:convert';
import 'dart:ui';
import 'package:arena_invicta_mobile/global/environments.dart';
import 'package:arena_invicta_mobile/global/widgets/app_colors.dart';
import 'package:arena_invicta_mobile/global/widgets/glassy_header.dart';
import 'package:arena_invicta_mobile/main.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class CreateQuizScreen extends StatefulWidget {
  // If provided, we are in EDIT mode
  final int? quizId;

  const CreateQuizScreen({super.key, this.quizId});

  @override
  State<CreateQuizScreen> createState() => _CreateQuizScreenState();
}

class _CreateQuizScreenState extends State<CreateQuizScreen> {
  final _formKey = GlobalKey<FormState>();
  
  bool get _isEditMode => widget.quizId != null;
  bool _isLoading = false;

  // Quiz Fields
  String _title = "";
  String _description = "";
  String _category = "football";
  bool _isPublished = false;

  // Questions
  List<Map<String, dynamic>> _questions = [];

  final List<String> _categories = ['football', 'basketball', 'tennis', 'volleyball', 'motogp'];

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      // Fetch existing data
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _fetchQuizData();
      });
    } else {
      // Create mode: Start with 1 empty question
      _addQuestion(); 
    }
  }

  Future<void> _fetchQuizData() async {
    setState(() => _isLoading = true);
    final request = context.read<CookieRequest>();
    try {
      final response = await request.get('$baseUrl/quiz/api/quiz-data/${widget.quizId}/');
      
      if (response['status'] == 'success') {
        final data = response['data'];
        setState(() {
          _title = data['title'];
          _description = data['description'] ?? "";
          _category = data['category'] ?? "football";
          _isPublished = data['is_published'] ?? false;
          
          _questions = List<Map<String, dynamic>>.from(data['questions']);
          // Ensure at least one question exists to prevent UI errors
          if (_questions.isEmpty) _addQuestion();
        });
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error loading data: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _addQuestion() {
    setState(() {
      _questions.add({
        'text': '',
        'option_a': '',
        'option_b': '',
        'option_c': '',
        'option_d': '',
        'correct_answer': 'A',
      });
    });
  }

  void _removeQuestion(int index) {
    setState(() {
      _questions.removeAt(index);
    });
  }

  Future<void> _submitQuiz(CookieRequest request) async {
    if (!_formKey.currentState!.validate()) return;
    if (_questions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Add at least one question.")));
      return;
    }
    _formKey.currentState!.save();

    // Prepare JSON payload
    final Map<String, dynamic> data = {
      'title': _title,
      'description': _description,
      'category': _category,
      'is_published': _isPublished,
      'questions': _questions,
    };

    try {
      final String url = _isEditMode 
          ? '$baseUrl/quiz/api/edit-flutter/${widget.quizId}/'
          : '$baseUrl/quiz/api/create-flutter/';

      final response = await request.postJson(url, jsonEncode(data));

      if (response['status'] == 'success') {
        if(mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(content: Text(_isEditMode ? "Quiz Updated!" : "Quiz Created!"))
           );
           Navigator.pop(context, true); // Return true to trigger refresh
        }
      } else {
        if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed: ${response['message']}")));
      }
    } catch (e) {
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    final userProvider = context.watch<UserProvider>();

    return Scaffold(
      backgroundColor: ArenaColor.darkAmethyst,
      body: Stack(
        children: [
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 70, bottom: 20),
              child: _isLoading 
                ? const Center(child: CircularProgressIndicator(color: ArenaColor.dragonFruit))
                : SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // QUIZ INFO CARD
                      _buildSectionTitle(_isEditMode ? "Edit Quiz" : "Quiz Details"),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white10)),
                        child: Column(
                          children: [
                            TextFormField(
                              initialValue: _title,
                              style: const TextStyle(color: Colors.white),
                              decoration: _inputDeco("Title"),
                              onSaved: (v) => _title = v!,
                              validator: (v) => v!.isEmpty ? "Required" : null,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              initialValue: _description,
                              style: const TextStyle(color: Colors.white),
                              decoration: _inputDeco("Description"),
                              maxLines: 3,
                              onSaved: (v) => _description = v!,
                            ),
                            const SizedBox(height: 12),
                            DropdownButtonFormField<String>(
                              value: _categories.contains(_category) ? _category : _categories[0],
                              dropdownColor: ArenaColor.darkAmethyst,
                              style: const TextStyle(color: Colors.white),
                              decoration: _inputDeco("Category"),
                              items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c.toUpperCase()))).toList(),
                              onChanged: (v) => setState(() => _category = v!),
                            ),
                            const SizedBox(height: 12),
                            SwitchListTile(
                              title: const Text("Publish Immediately?", style: TextStyle(color: Colors.white)),
                              value: _isPublished,
                              activeColor: ArenaColor.dragonFruit,
                              onChanged: (v) => setState(() => _isPublished = v),
                            )
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      _buildSectionTitle("Questions"),
                      if(_isEditMode) 
                        const Padding(
                          padding: EdgeInsets.only(bottom: 10),
                          child: Text("Note: Editing replaces all questions.", style: TextStyle(color: Colors.orange, fontSize: 12)),
                        ),
                      
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _questions.length,
                        separatorBuilder: (_,__) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          return _buildQuestionCard(index);
                        },
                      ),

                      const SizedBox(height: 16),
                      Center(
                        child: OutlinedButton.icon(
                          onPressed: _addQuestion,
                          icon: const Icon(Icons.add),
                          label: const Text("Add Question"),
                          style: OutlinedButton.styleFrom(foregroundColor: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => _submitQuiz(request),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ArenaColor.dragonFruit,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text(_isEditMode ? "UPDATE QUIZ" : "CREATE QUIZ", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ),
          GlassyHeader(userProvider: userProvider, isHome: false, title: "Arena Invicta", subtitle: _isEditMode ? "Edit Quiz" : "Create Quiz"),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(int index) {
    // Key ensures Flutter redraws correctly when items are removed/added
    return Container(
      key: ValueKey(index), 
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: ArenaColor.darkAmethystLight.withOpacity(0.4), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Question ${index + 1}", style: const TextStyle(color: ArenaColor.dragonFruit, fontWeight: FontWeight.bold)),
              if (_questions.length > 1)
                IconButton(icon: const Icon(Icons.delete, color: Colors.redAccent, size: 20), onPressed: () => _removeQuestion(index))
            ],
          ),
          TextFormField(
            initialValue: _questions[index]['text'],
            style: const TextStyle(color: Colors.white),
            decoration: _inputDeco("Question Text"),
            onChanged: (v) => _questions[index]['text'] = v,
            validator: (v) => v!.isEmpty ? "Required" : null,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _optionInput(index, 'option_a', 'Option A')),
              const SizedBox(width: 8),
              Expanded(child: _optionInput(index, 'option_b', 'Option B')),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _optionInput(index, 'option_c', 'Option C')),
              const SizedBox(width: 8),
              Expanded(child: _optionInput(index, 'option_d', 'Option D')),
            ],
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _questions[index]['correct_answer'],
             dropdownColor: ArenaColor.darkAmethyst,
            style: const TextStyle(color: Colors.white),
            decoration: _inputDeco("Correct Answer"),
            items: ['A', 'B', 'C', 'D'].map((c) => DropdownMenuItem(value: c, child: Text("Option $c"))).toList(),
            onChanged: (v) => setState(() => _questions[index]['correct_answer'] = v),
          ),
        ],
      ),
    );
  }

  Widget _optionInput(int index, String key, String label) {
    return TextFormField(
      initialValue: _questions[index][key],
      style: const TextStyle(color: Colors.white),
      decoration: _inputDeco(label),
      onChanged: (v) => _questions[index][key] = v,
      validator: (v) => v!.isEmpty ? "Required" : null,
    );
  }

  InputDecoration _inputDeco(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white54),
      enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.white10), borderRadius: BorderRadius.circular(8)),
      focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: ArenaColor.purpleX11), borderRadius: BorderRadius.circular(8)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      filled: true,
      fillColor: Colors.black12,
    );
  }
  
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
    );
  }
}