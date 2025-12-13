import 'dart:convert';
import 'dart:ui';
import 'package:arena_invicta_mobile/global/environments.dart';
import 'package:arena_invicta_mobile/global/widgets/app_colors.dart';
import 'package:arena_invicta_mobile/global/widgets/glassy_header.dart';
import 'package:arena_invicta_mobile/main.dart'; 
import 'package:arena_invicta_mobile/hannan_quiz/models/public_quiz_detail_model.dart';
import 'package:arena_invicta_mobile/hannan_quiz/screens/quiz_result_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class QuizPlayScreen extends StatefulWidget {
  final int quizId;
  final String title;

  const QuizPlayScreen({super.key, required this.quizId, required this.title});

  @override
  State<QuizPlayScreen> createState() => _QuizPlayScreenState();
}

class _QuizPlayScreenState extends State<QuizPlayScreen> {
  int _currentIndex = 0;
  bool _isLoading = true;
  PublicQuizDetailEntry? _quizData; 
  
  final Map<String, String> _userAnswers = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchQuizDetail();
    });
  }

  Future<void> _fetchQuizDetail() async {
    final request = context.read<CookieRequest>();
    try {
      final response = await request.get('$baseUrl/quiz/api/${widget.quizId}/');
      setState(() {
        _quizData = PublicQuizDetailEntry.fromJson(response);
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error fetching quiz: $e");
      if (mounted) Navigator.pop(context);
    }
  }

  void _answerQuestion(int questionId, String selectedOption) {
    setState(() {
      _userAnswers[questionId.toString()] = selectedOption;

      if (_currentIndex < _quizData!.questions.length - 1) {
        _currentIndex++;
      } else {
        _submitQuiz();
      }
    });
  }

  Future<void> _submitQuiz() async {
    final request = context.read<CookieRequest>();
    
    showDialog(
      context: context, 
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator(color: ArenaColor.dragonFruit))
    );

    try {
      final response = await request.postJson(
        '$baseUrl/quiz/api/${widget.quizId}/submit/',
        jsonEncode(<String, dynamic>{
            'answers': _userAnswers,
        }),
      );

      if (mounted) Navigator.pop(context); 

      if (response != null && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => QuizResultScreen(
            quizTitle: widget.title,
            score: response['score'],
            total: response['total'],
            leaderboardData: response['leaderboard'] ?? [], 
          )),
        );
      }

    } catch (e) {
       if (mounted) Navigator.pop(context);
       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error submitting: $e")));
    }
  }

  Widget _buildGlowCircle(Color color) {
    return Container(
      width: 300, height: 300,
      decoration: BoxDecoration(color: color.withOpacity(0.2), shape: BoxShape.circle),
      child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80), child: Container(color: Colors.transparent)),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 2. Access UserProvider for the header
    final userProvider = context.watch<UserProvider>();

    if (_isLoading) {
      return const Scaffold(
        backgroundColor: ArenaColor.darkAmethyst,
        body: Center(child: CircularProgressIndicator(color: ArenaColor.dragonFruit)),
      );
    }

    final question = _quizData!.questions[_currentIndex]; 

    return Scaffold(
      backgroundColor: ArenaColor.darkAmethyst,
      body: Stack(
        children: [
           Positioned(top: -100, right: -100, child: _buildGlowCircle(ArenaColor.purpleX11)),
           Positioned(bottom: -50, left: -50, child: _buildGlowCircle(ArenaColor.dragonFruit)),
           Positioned.fill(
             child: Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 70, // Space for header
                left: 24, 
                right: 24, 
                bottom: 24
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  LinearProgressIndicator(
                    value: (_currentIndex + 1) / _quizData!.questions.length,
                    backgroundColor: Colors.white10,
                    color: ArenaColor.dragonFruit,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  const SizedBox(height: 12),
                  Text("Question ${_currentIndex + 1}/${_quizData!.questions.length}", 
                    style: TextStyle(color: ArenaColor.dragonFruit.withOpacity(0.8), fontWeight: FontWeight.bold)),
                  
                  const Spacer(flex: 1),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white10)
                    ),
                    child: Text(
                      question.text,
                      style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const Spacer(flex: 2),
                  
                  _buildOptionBtn(question.id, "A", question.options.a),
                  _buildOptionBtn(question.id, "B", question.options.b),
                  _buildOptionBtn(question.id, "C", question.options.c),
                  _buildOptionBtn(question.id, "D", question.options.d),
                  const Spacer(flex: 1),
                ],
              ),
            ),
           ),

           GlassyHeader(
             userProvider: userProvider, 
             isHome: false, 
             title: "Arena Invicta", 
             subtitle: widget.title 
           ),
        ],
      ),
    );
  }

  Widget _buildOptionBtn(int questionId, String label, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: InkWell(
        onTap: () => _answerQuestion(questionId, label),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          decoration: BoxDecoration(
             color: ArenaColor.darkAmethystLight.withOpacity(0.4),
             borderRadius: BorderRadius.circular(16),
             border: Border.all(color: Colors.white.withOpacity(0.1))
          ),
          child: Row(
            children: [
              Container(
                width: 32, height: 32,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: ArenaColor.purpleX11,
                  shape: BoxShape.circle,
                ),
                child: Text(label, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white)),
              ),
              const SizedBox(width: 16),
              Expanded(child: Text(text, style: const TextStyle(fontSize: 16, color: Colors.white))),
            ],
          ),
        ),
      ),
    );
  }
}