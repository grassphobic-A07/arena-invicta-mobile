import 'package:arena_invicta_mobile/global/widgets/app_colors.dart';
import 'package:arena_invicta_mobile/hannan_quiz/models/private_quiz_detail_model.dart'; // Correct Import
import 'package:flutter/material.dart';

class QuizAdminDetail extends StatefulWidget {
  final int quizId;
  const QuizAdminDetail({super.key, required this.quizId});

  @override
  State<QuizAdminDetail> createState() => _QuizAdminDetailState();
}

class _QuizAdminDetailState extends State<QuizAdminDetail> {
  // Uses PrivateQuizDetailEntry instead of QuizEntry
  Future<PrivateQuizDetailEntry> fetchAdminDetails() async {
    await Future.delayed(const Duration(seconds: 1));
    return PrivateQuizDetailEntry(
      id: widget.quizId,
      title: "Admin View: Detail",
      correctAnswers: [
        CorrectAnswer(questionId: 1, correctAnswer: "A"), //
        CorrectAnswer(questionId: 2, correctAnswer: "C"),
      ],
      scores: [
        Score(user: "ProGamer", score: 100), //
        Score(user: "NoobMaster", score: 50),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ArenaColor.darkAmethyst,
      appBar: AppBar(title: const Text("Quiz Analytics")),
      body: FutureBuilder(
        future: fetchAdminDetails(),
        builder: (context, AsyncSnapshot<PrivateQuizDetailEntry> snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          
          final data = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildSectionTitle("Leaderboard"),
              // Mapping 'scores' from PrivateQuizDetailEntry
              if (data.scores.isEmpty) 
                const Text("No scores recorded yet.", style: TextStyle(color: Colors.white54)),
              ...data.scores.map((s) => ListTile(
                leading: const Icon(Icons.emoji_events, color: Colors.amber),
                title: Text(s.user, style: const TextStyle(color: Colors.white)),
                trailing: Text("${s.score} pts", style: const TextStyle(color: ArenaColor.dragonFruit, fontWeight: FontWeight.bold)),
              )),
              
              const Divider(color: Colors.white24, height: 40),
              
              _buildSectionTitle("Answer Key"),
              // Mapping 'correctAnswers' from PrivateQuizDetailEntry
              ...data.correctAnswers.map((a) => ListTile(
                title: Text("Question ID: ${a.questionId}", style: const TextStyle(color: Colors.white70)),
                trailing: Chip(
                  label: Text("Answer: ${a.correctAnswer}"),
                  backgroundColor: Colors.green.withOpacity(0.2),
                ),
              )),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
    );
  }
}