import 'package:arena_invicta_mobile/hannan_quiz/models/private_quiz_list_model.dart'; // Correct Import
import 'package:arena_invicta_mobile/hannan_quiz/screens/quiz_admin_detail.dart';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class PrivateQuizList extends StatefulWidget {
  const PrivateQuizList({super.key});

  @override
  State<PrivateQuizList> createState() => _PrivateQuizListState();
}

class _PrivateQuizListState extends State<PrivateQuizList> {
  // Updated type to PrivateQuizListEntry
  Future<List<PrivateQuizListEntry>> fetchPrivateQuizzes(CookieRequest request) async {
    // MOCK DATA
    await Future.delayed(const Duration(seconds: 1));
    return [
      PrivateQuizListEntry(
        id: 101, 
        title: "My Draft Quiz", 
        description: "WIP", 
        category: "FPS", 
        isQuizHot: false, 
        totalQuestion: 5, // Singular field name in private model
        isPublished: false
      ),
      PrivateQuizListEntry(
        id: 102, 
        title: "Published Valorant Quiz", 
        description: "Hard mode", 
        category: "FPS", 
        isQuizHot: true, 
        totalQuestion: 15, 
        isPublished: true
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return FutureBuilder(
      future: fetchPrivateQuizzes(request),
      builder: (context, AsyncSnapshot<List<PrivateQuizListEntry>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("You haven't created any quizzes yet."));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final quiz = snapshot.data![index];
            return Card(
              color: Colors.white.withOpacity(0.05),
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                title: Text(quiz.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                subtitle: Text(quiz.isPublished ? "Published" : "Draft", 
                  style: TextStyle(color: quiz.isPublished ? Colors.greenAccent : Colors.orangeAccent)
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white54),
                onTap: () {
                  Navigator.push( 
                    context,
                    MaterialPageRoute(
                      builder: (context) => QuizAdminDetail(quizId: quiz.id),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}