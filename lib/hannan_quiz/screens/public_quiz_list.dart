import 'package:arena_invicta_mobile/global/environments.dart';
import 'package:arena_invicta_mobile/global/widgets/app_colors.dart';
import 'package:arena_invicta_mobile/hannan_quiz/models/public_quiz_list_model.dart';
import 'package:arena_invicta_mobile/hannan_quiz/screens/quiz_play_screen.dart';
import 'package:arena_invicta_mobile/hannan_quiz/screens/quiz_start_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class PublicQuizList extends StatefulWidget {
  final String searchQuery;
  final String category;

  const PublicQuizList({
    super.key, 
    required this.searchQuery, 
    required this.category
  });

  @override
  State<PublicQuizList> createState() => _PublicQuizListState();
}

class _PublicQuizListState extends State<PublicQuizList> {
  
  Future<List<PublicQuizListEntry>> fetchPublicQuizzes(CookieRequest request) async {
    // Construct URL with Query Params for Server-Side Filtering
    String url = '$baseUrl/quiz/api/?format=json';
    
    if (widget.searchQuery.isNotEmpty) {
      url += '&search=${widget.searchQuery}';
    }
    // "All" is a frontend-only state, don't send it to backend
    if (widget.category != "All") {
      url += '&category=${widget.category}';
    }

    final response = await request.get(url);
    
    List<PublicQuizListEntry> listQuiz = [];
    for (var d in response) {
      if (d != null) {
        listQuiz.add(PublicQuizListEntry.fromJson(d));
      }
    }
    return listQuiz;
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return FutureBuilder(
      key: ValueKey("${widget.searchQuery}-${widget.category}"),
      future: fetchPublicQuizzes(request),
      builder: (context, AsyncSnapshot<List<PublicQuizListEntry>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: ArenaColor.dragonFruit));
        } else if (snapshot.hasError) {
           return Center(child: Text("Error: ${snapshot.error}", style: const TextStyle(color: Colors.white54)));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.search_off, size: 50, color: Colors.white24),
                const SizedBox(height: 10),
                Text(
                  "No quizzes found.", 
                  style: GoogleFonts.outfit(color: Colors.white54, fontSize: 16)
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
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
        color: ArenaColor.darkAmethystLight.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => QuizStartScreen(quiz: quiz),
              ),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: ArenaColor.purpleX11.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      // Capitalize category for display
                      child: Text(
                        quiz.category.toUpperCase(), 
                        style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)
                      ),
                    ),
                    if (quiz.isQuizHot)
                      Row(
                        children: [
                          const Icon(Icons.local_fire_department, color: Colors.orange, size: 18),
                          const SizedBox(width: 4),
                          Text("HOT", style: GoogleFonts.outfit(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 12))
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  quiz.title,
                  style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 6),
                Text(
                  quiz.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 16),
                Divider(color: Colors.white.withOpacity(0.1)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.quiz_outlined, size: 16, color: ArenaColor.dragonFruit),
                    const SizedBox(width: 6),
                    Text("${quiz.totalQuestions} Questions", style: const TextStyle(color: Colors.white70, fontSize: 12)),
                    const Spacer(),
                    const Icon(Icons.person_outline, size: 16, color: Colors.white54),
                    const SizedBox(width: 4),
                    Text(quiz.createdBy, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}