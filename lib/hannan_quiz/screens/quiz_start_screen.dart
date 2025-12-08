import 'dart:ui';
import 'package:arena_invicta_mobile/global/environments.dart';
import 'package:arena_invicta_mobile/global/widgets/app_colors.dart';
import 'package:arena_invicta_mobile/global/widgets/glassy_header.dart';
import 'package:arena_invicta_mobile/hannan_quiz/models/public_quiz_list_model.dart';
import 'package:arena_invicta_mobile/hannan_quiz/screens/quiz_play_screen.dart';
import 'package:arena_invicta_mobile/main.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class QuizStartScreen extends StatefulWidget {
  final PublicQuizListEntry quiz;

  const QuizStartScreen({super.key, required this.quiz});

  @override
  State<QuizStartScreen> createState() => _QuizStartScreenState();
}

class _QuizStartScreenState extends State<QuizStartScreen> {
  
  Future<List<dynamic>> _fetchLeaderboard(CookieRequest request) async {
    try {
      // Use the get_quiz_detail API which now returns leaderboard
      final response = await request.get('$baseUrl/quiz/api/${widget.quiz.id}/');
      return response['leaderboard'] ?? [];
    } catch (e) {
      return [];
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
    final userProvider = context.watch<UserProvider>();
    final request = context.watch<CookieRequest>();

    return Scaffold(
      backgroundColor: ArenaColor.darkAmethyst,
      body: Stack(
        children: [
          Positioned(top: -100, right: -100, child: _buildGlowCircle(ArenaColor.purpleX11)),
          Positioned(bottom: -50, left: -50, child: _buildGlowCircle(ArenaColor.dragonFruit)),

          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 70, bottom: 20),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // --- INFO CARD ---
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: ArenaColor.darkAmethystLight.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Column(
                        children: [
                           Icon(Icons.sports_esports, size: 60, color: ArenaColor.purpleX11),
                           const SizedBox(height: 16),
                           Text(widget.quiz.title, textAlign: TextAlign.center, style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                           const SizedBox(height: 8),
                           Chip(
                             label: Text(widget.quiz.category, style: const TextStyle(color: Colors.white)),
                             backgroundColor: ArenaColor.dragonFruit.withOpacity(0.8),
                           ),
                           const SizedBox(height: 24),
                           const Align(alignment: Alignment.centerLeft, child: Text("Description", style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold))),
                           const SizedBox(height: 8),
                           Text(widget.quiz.description.isNotEmpty ? widget.quiz.description : "No description provided.", style: const TextStyle(color: Colors.white, fontSize: 16, height: 1.5)),
                           const SizedBox(height: 24),
                           Row(
                             mainAxisAlignment: MainAxisAlignment.spaceAround,
                             children: [
                               _infoCol(Icons.help_outline, "${widget.quiz.totalQuestions} Qs"),
                               _infoCol(Icons.person_outline, widget.quiz.createdBy),
                             ],
                           )
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // --- LEADERBOARD SECTION ---
                    Text("Top Challengers", style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 12),
                    
                    FutureBuilder(
                      future: _fetchLeaderboard(request),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator(color: ArenaColor.dragonFruit));
                        }
                        
                        final leaderboard = snapshot.data as List<dynamic>? ?? [];
                        if (leaderboard.isEmpty) {
                          return Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(16)),
                            child: const Center(child: Text("Be the first to conquer this quiz!", style: TextStyle(color: Colors.white54))),
                          );
                        }

                        return Container(
                          decoration: BoxDecoration(
                            color: ArenaColor.darkAmethystLight.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white10),
                          ),
                          child: ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: leaderboard.length,
                            separatorBuilder: (_,__) => Divider(color: Colors.white.withOpacity(0.1), height: 1),
                            itemBuilder: (context, index) {
                              final entry = leaderboard[index];
                              return ListTile(
                                leading: Text("#${index + 1}", style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
                                title: Text(entry['user'], style: const TextStyle(color: Colors.white)),
                                trailing: Text("${entry['score']} pts", style: const TextStyle(color: ArenaColor.dragonFruit, fontWeight: FontWeight.bold)),
                              );
                            },
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 40),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ArenaColor.dragonFruit,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 5,
                      ),
                      onPressed: () {
                        Navigator.pushReplacement( // Use Replacement so they can't back into start screen
                          context, 
                          MaterialPageRoute(builder: (context) => QuizPlayScreen(quizId: widget.quiz.id, title: widget.quiz.title))
                        );
                      },
                      child: Text("START QUIZ", style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                    ),
                  ],
                ),
              ),
            ),
          ),
          GlassyHeader(userProvider: userProvider, isHome: false, title: "Arena Invicta", subtitle: "Quiz Info"),
        ],
      ),
    );
  }

  Widget _infoCol(IconData icon, String text) {
    return Column(
      children: [
        Icon(icon, color: Colors.white54),
        const SizedBox(height: 4),
        Text(text, style: const TextStyle(color: Colors.white70)),
      ],
    );
  }
}