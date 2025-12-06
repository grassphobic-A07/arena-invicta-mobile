import 'dart:ui';
import 'package:arena_invicta_mobile/global/environments.dart';
import 'package:arena_invicta_mobile/global/widgets/app_colors.dart';
import 'package:arena_invicta_mobile/global/widgets/glassy_header.dart';
import 'package:arena_invicta_mobile/hannan_quiz/models/private_quiz_detail_model.dart';
import 'package:arena_invicta_mobile/hannan_quiz/screens/create_quiz_screen.dart'; 
import 'package:arena_invicta_mobile/main.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class QuizAdminDetail extends StatefulWidget {
  final int quizId;
  const QuizAdminDetail({super.key, required this.quizId});

  @override
  State<QuizAdminDetail> createState() => _QuizAdminDetailState();
}

class _QuizAdminDetailState extends State<QuizAdminDetail> {
  Future<PrivateQuizDetailEntry?> fetchAdminDetails(CookieRequest request) async {
    try {
      final response = await request.get('$baseUrl/quiz/api/${widget.quizId}/admin/');
      return PrivateQuizDetailEntry.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  Future<void> _deleteQuiz(CookieRequest request) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ArenaColor.darkAmethyst,
        title: const Text("Delete Quiz?", style: TextStyle(color: Colors.white)),
        content: const Text("This action cannot be undone.", style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Delete", style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      final response = await request.post('$baseUrl/quiz/api/delete-flutter/${widget.quizId}/', {});
      if (response['status'] == 'success') {
        if(mounted) {
           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Quiz Deleted.")));
           Navigator.pop(context, true); // Back to list
        }
      } else {
         if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Delete failed.")));
      }
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
    final request = context.watch<CookieRequest>();
    final userProvider = context.watch<UserProvider>();
    final currentUsername = userProvider.username; // To highlight user

    return Scaffold(
      backgroundColor: ArenaColor.darkAmethyst,
      body: Stack(
        children: [
          Positioned(top: -100, left: -50, child: _buildGlowCircle(ArenaColor.purpleX11)),
          
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 70, bottom: 20),
              child: FutureBuilder(
                future: fetchAdminDetails(request),
                builder: (context, AsyncSnapshot<PrivateQuizDetailEntry?> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: ArenaColor.dragonFruit));
                  }
                  if (!snapshot.hasData) return const Center(child: Text("Details not found.", style: TextStyle(color: Colors.white54)));

                  final data = snapshot.data!;

                  return Column(
                    children: [
                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          children: [
                            // 1. INFO CARD
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: ArenaColor.darkAmethystLight.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.white10),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                   Text(data.title, style: GoogleFonts.outfit(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white)),
                                   const SizedBox(height: 8),
                                   const Text("Created by You", style: TextStyle(color: ArenaColor.dragonFruit, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                        
                            // 2. LEADERBOARD
                            Text("Leaderboard", style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                            const SizedBox(height: 12),
                            Container(
                              decoration: BoxDecoration(
                                color: ArenaColor.darkAmethystLight.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.white10),
                              ),
                              child: data.scores.isEmpty 
                                ? const Padding(padding: EdgeInsets.all(16), child: Text("No scores yet.", style: TextStyle(color: Colors.white54)))
                                : ListView.separated(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: data.scores.length,
                                    separatorBuilder: (context, index) => Divider(color: Colors.white.withOpacity(0.1), height: 1),
                                    itemBuilder: (context, index) {
                                      final score = data.scores[index];
                                      final isMe = score.user == currentUsername;
                                      
                                      return Container(
                                        color: isMe ? ArenaColor.dragonFruit.withOpacity(0.1) : Colors.transparent, // Highlight background
                                        child: ListTile(
                                          leading: Text("#${index+1}", style: GoogleFonts.outfit(color: isMe ? ArenaColor.dragonFruit : Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                                          title: Text(
                                            isMe ? "${score.user} (You)" : score.user, 
                                            style: TextStyle(
                                              color: isMe ? ArenaColor.dragonFruit : Colors.white, 
                                              fontWeight: isMe ? FontWeight.bold : FontWeight.normal
                                            )
                                          ),
                                          trailing: Text("${score.score} pts", style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
                                        ),
                                      );
                                    },
                                  ),
                            ),

                            const SizedBox(height: 24),

                            // 3. ANSWER KEY
                            Text("Answer Key", style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                            const SizedBox(height: 12),
                             Container(
                              decoration: BoxDecoration(
                                color: ArenaColor.darkAmethystLight.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.white10),
                              ),
                              child: ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: data.correctAnswers.length,
                                separatorBuilder: (context, index) => Divider(color: Colors.white.withOpacity(0.1), height: 1),
                                itemBuilder: (context, index) {
                                  final ans = data.correctAnswers[index];
                                  return ListTile(
                                    title: Text("Q: ${index + 1}", style: const TextStyle(color: Colors.white70, fontSize: 14)),
                                    trailing: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(color: Colors.green.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                                      child: Text(ans.correctAnswer, style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold)),
                                    ),
                                  );
                                }
                              ),
                            ),
                            const SizedBox(height: 100), // Space for buttons
                          ],
                        ),
                      ),
                      
                      // 4. ACTION BUTTONS
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                           color: ArenaColor.darkAmethyst,
                           boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0,-5))]
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => _deleteQuiz(request),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Colors.redAccent),
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                                ),
                                child: const Text("DELETE", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  // Navigating to Edit Mode (Only passing ID now)
                                  Navigator.push(
                                    context, 
                                    MaterialPageRoute(builder: (context) => CreateQuizScreen(
                                      quizId: widget.quizId,
                                      // Removed initialData
                                    ))
                                  ).then((_) => setState((){})); // Refresh on back
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: ArenaColor.purpleX11,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                                ),
                                child: const Text("EDIT", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  );
                },
              ),
            ),
          ),
          GlassyHeader(userProvider: userProvider, isHome: false, title: "Arena Invicta", subtitle: "Admin Panel"),
        ],
      ),
    );
  }
}