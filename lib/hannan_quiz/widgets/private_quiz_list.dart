import 'package:arena_invicta_mobile/global/environments.dart';
import 'package:arena_invicta_mobile/global/widgets/app_colors.dart';
import 'package:arena_invicta_mobile/hannan_quiz/models/private_quiz_list_model.dart'; 
import 'package:arena_invicta_mobile/hannan_quiz/screens/quiz_admin_detail.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class PrivateQuizList extends StatefulWidget {
  final String searchQuery;
  final String category;

  const PrivateQuizList({
    super.key, 
    required this.searchQuery, 
    required this.category
  });

  @override
  PrivateQuizListState createState() => PrivateQuizListState(); // Remove underscore from State class name
}

// Make State class public so GlobalKey can see it
class PrivateQuizListState extends State<PrivateQuizList> {
  int _pullRefreshId = 0; 

  Future<List<PrivateQuizListEntry>> fetchPrivateQuizzes(CookieRequest request) async {
    try {
      final response = await request.get('$baseUrl/quiz/api/admin/');
      
      if (response is Map && response.containsKey("error")) return [];

      List<PrivateQuizListEntry> listQuiz = [];
      if (response is List) {
        for (var d in response) {
          if (d != null) listQuiz.add(PrivateQuizListEntry.fromJson(d));
        }
      }

      // Filtering
      if (widget.searchQuery.isNotEmpty) {
        listQuiz = listQuiz.where((q) => q.title.toLowerCase().contains(widget.searchQuery.toLowerCase())).toList();
      }
      if (widget.category != "All") {
        listQuiz = listQuiz.where((q) => q.category.toLowerCase() == widget.category.toLowerCase()).toList();
      }

      return listQuiz;
    } catch (e) {
      return [];
    }
  }

  // PUBLIC METHOD for GlobalKey access
  Future<void> handleRefresh() async {
    if (!mounted) return;
    setState(() {
      _pullRefreshId++;
    });
    // Visual delay
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return RefreshIndicator(
      onRefresh: handleRefresh,
      color: ArenaColor.dragonFruit,
      backgroundColor: ArenaColor.darkAmethyst,
      child: FutureBuilder(
        key: ValueKey("${widget.searchQuery}-${widget.category}-$_pullRefreshId"),
        future: fetchPrivateQuizzes(request),
        builder: (context, AsyncSnapshot<List<PrivateQuizListEntry>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: ArenaColor.dragonFruit));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Stack(
              children: [
                ListView(physics: const AlwaysScrollableScrollPhysics(), children: const []), 
                Center(child: Text("No quizzes found in your Vault.", style: GoogleFonts.outfit(color: Colors.white54, fontSize: 16))),
              ],
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            physics: const AlwaysScrollableScrollPhysics(), 
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final quiz = snapshot.data![index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: ArenaColor.darkAmethystLight.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  title: Text(quiz.title, style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(color: Colors.grey.withOpacity(0.3), borderRadius: BorderRadius.circular(4)),
                          child: Text(quiz.category.toUpperCase(), style: const TextStyle(fontSize: 10, color: Colors.white70, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: quiz.isPublished ? Colors.green.withOpacity(0.2) : Colors.orange.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: quiz.isPublished ? Colors.green : Colors.orange, width: 0.5)
                          ),
                          child: Text(quiz.isPublished ? "Published" : "Draft", style: TextStyle(fontSize: 10, color: quiz.isPublished ? Colors.greenAccent : Colors.orangeAccent)),
                        ),
                        const Spacer(),
                        Text("${quiz.totalQuestion} Qs", style: const TextStyle(color: Colors.white38, fontSize: 12)),
                      ],
                    ),
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), shape: BoxShape.circle),
                    child: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.white54),
                  ),
                  onTap: () {
                    Navigator.push( 
                      context,
                      MaterialPageRoute(builder: (context) => QuizAdminDetail(quizId: quiz.id)),
                    ).then((result) {
                      // Also refresh if we deleted/edited in detail
                      if (result == true) {
                        handleRefresh();
                      }
                    });
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}