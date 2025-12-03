import 'package:arena_invicta_mobile/global/widgets/app_colors.dart';
import 'package:arena_invicta_mobile/hannan_quiz/models/public_quiz_detail_model.dart'; // Correct Import
import 'package:flutter/material.dart';

class QuizPlayScreen extends StatefulWidget {
  final int quizId;
  final String title;

  const QuizPlayScreen({super.key, required this.quizId, required this.title});

  @override
  State<QuizPlayScreen> createState() => _QuizPlayScreenState();
}

class _QuizPlayScreenState extends State<QuizPlayScreen> {
  int _currentIndex = 0;
  int _score = 0;
  bool _isLoading = true;
  PublicQuizDetailEntry? _quizData; // Updated type

  @override
  void initState() {
    super.initState();
    _fetchQuizDetail();
  }

  Future<void> _fetchQuizDetail() async {
    // Simulate API Call
    await Future.delayed(const Duration(seconds: 1));
    // Mocking response based on PublicQuizDetailEntry
    setState(() {
      _quizData = PublicQuizDetailEntry(
        id: widget.quizId,
        title: widget.title,
        description: "Good luck!",
        questions: [
          Question(
            id: 1, 
            text: "What is the capital of Demacia?", 
            options: Options(a: "Noxus", b: "Demacia City", c: "Ionia", d: "Freljord") //
          ),
          Question(
            id: 2, 
            text: "Who is the blade of the ruined king?", 
            options: Options(a: "Viego", b: "Thresh", c: "Kalista", d: "Hecarim")
          ),
        ],
      );
      _isLoading = false;
    });
  }

  void _answerQuestion(String selectedOption) {
    // Logic to calculate score would go here
    setState(() {
      _score += 10; 
      if (_currentIndex < _quizData!.questions.length - 1) {
        _currentIndex++;
      } else {
        _showResultDialog();
      }
    });
  }

  void _showResultDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: ArenaColor.darkAmethystLight,
        title: const Text("Quiz Completed!", style: TextStyle(color: Colors.white)),
        content: Text("Your score: $_score", style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Back to list
            },
            child: const Text("Finish", style: TextStyle(color: ArenaColor.dragonFruit)),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: ArenaColor.darkAmethyst,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final question = _quizData!.questions[_currentIndex]; 

    return Scaffold(
      backgroundColor: ArenaColor.darkAmethyst,
      appBar: AppBar(title: Text(widget.title)),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text("Question ${_currentIndex + 1}/${_quizData!.questions.length}", 
              style: const TextStyle(color: ArenaColor.dragonFruit, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Text(
              question.text,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 40),
            _buildOptionBtn("A", question.options.a), // Accessing props a, b, c, d
            _buildOptionBtn("B", question.options.b),
            _buildOptionBtn("C", question.options.c),
            _buildOptionBtn("D", question.options.d),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionBtn(String label, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white.withOpacity(0.1),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          alignment: Alignment.centerLeft,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: () => _answerQuestion(label),
        child: Row(
          children: [
            CircleAvatar(
              radius: 12,
              backgroundColor: ArenaColor.purpleX11,
              child: Text(label, style: const TextStyle(fontSize: 12, color: Colors.white)),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(text, style: const TextStyle(fontSize: 16, color: Colors.white))),
          ],
        ),
      ),
    );
  }
}