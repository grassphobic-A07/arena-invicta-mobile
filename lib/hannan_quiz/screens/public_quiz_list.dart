import 'package:arena_invicta_mobile/global/widgets/app_colors.dart';
import 'package:arena_invicta_mobile/hannan_quiz/models/public_quiz_list_model.dart'; // Correct Import
import 'package:arena_invicta_mobile/hannan_quiz/screens/quiz_play_screen.dart';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class PublicQuizList extends StatefulWidget {
  const PublicQuizList({super.key});

  @override
  State<PublicQuizList> createState() => _PublicQuizListState();
}

class _PublicQuizListState extends State<PublicQuizList> {
  // Updated type to PublicQuizListEntry
  Future<List<PublicQuizListEntry>> fetchPublicQuizzes(CookieRequest request) async {
    // Replace with your actual Django endpoint
    // final response = await request.get('https://neal-guarddin-arenainvicta.pbp.cs.ui.ac.id/quiz/api/public-list/');
    
    // MOCK DATA using the correct model
    await Future.delayed(const Duration(seconds: 1)); 
    return [
      PublicQuizListEntry(
        id: 1, 
        title: "League of Legends Lore d.sa dsandslajdksandsa", 
        description: "Test your knowledge of Runeterra!", 
        category: "MOBA", 
        isQuizHot: true, 
        totalQuestions: 10, // Note plural 's' in public model
        createdBy: "Admin"
      ),
      PublicQuizListEntry(
        id: 2, 
        title: "Elden Ring Bosses", 
        description: "Can you name them all?", 
        category: "RPG", 
        isQuizHot: false, 
        totalQuestions: 20, 
        createdBy: "Tarnished"
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return FutureBuilder(
      future: fetchPublicQuizzes(request),
      builder: (context, AsyncSnapshot<List<PublicQuizListEntry>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: ArenaColor.dragonFruit));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No active quizzes in the Arena."));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final quiz = snapshot.data![index];
            return _buildQuizCard(context, quiz);
          },
        );
      },
    );
  }
  
  Widget _buildQuizCard(BuildContext context, PublicQuizListEntry quiz) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: ArenaColor.darkAmethystLight.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => QuizPlayScreen(quizId: quiz.id, title: quiz.title),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Chip(
                    label: Text(quiz.category, style: const TextStyle(fontSize: 10)),
                    backgroundColor: ArenaColor.purpleX11,
                    visualDensity: VisualDensity.compact,
                  ),
                  if (quiz.isQuizHot)
                    const Icon(Icons.local_fire_department, color: Colors.orange, size: 20),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                quiz.title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 4),
              Text(
                quiz.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.quiz, size: 14, color: Colors.white54),
                  const SizedBox(width: 4),
                  // Uses totalQuestions from PublicQuizListEntry
                  Text("${quiz.totalQuestions} Questions", style: const TextStyle(color: Colors.white54, fontSize: 12)),
                  const Spacer(),
                  Text("By ${quiz.createdBy}", style: const TextStyle(color: ArenaColor.dragonFruit, fontSize: 12)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}