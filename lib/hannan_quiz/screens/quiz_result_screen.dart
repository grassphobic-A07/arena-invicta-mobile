import 'dart:ui';
import 'package:arena_invicta_mobile/global/widgets/app_colors.dart';
import 'package:arena_invicta_mobile/global/widgets/glassy_header.dart';
import 'package:arena_invicta_mobile/main.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class QuizResultScreen extends StatelessWidget {
  final String quizTitle;
  final int score;
  final int total;
  final List<dynamic> leaderboardData;

  const QuizResultScreen({
    super.key, 
    required this.quizTitle, 
    required this.score, 
    required this.total,
    this.leaderboardData = const [],
  });
  
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
    final currentUsername = userProvider.username;
    double percentage = (total > 0) ? (score / total) : 0;
    Color scoreColor = percentage >= 0.7 ? Colors.greenAccent : (percentage >= 0.4 ? Colors.amberAccent : Colors.redAccent);

    return Scaffold(
      backgroundColor: ArenaColor.darkAmethyst,
      body: Stack(
        children: [
          Positioned(top: -50, right: -50, child: _buildGlowCircle(ArenaColor.purpleX11)),
          
          Positioned.fill(
             child: Padding(
               padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 70, bottom: 20),
               child: SingleChildScrollView(
                 child: Column(
                   children: [
                      const SizedBox(height: 20),
                      Icon(Icons.emoji_events_rounded, size: 80, color: scoreColor),
                      const SizedBox(height: 10),
                      Text("Quiz Completed!", style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                      Text(quizTitle, style: const TextStyle(color: Colors.white54, fontSize: 16)),
                      const SizedBox(height: 30),
                      
                      // Score Card
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 40),
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: scoreColor.withOpacity(0.5)),
                        ),
                        child: Column(
                          children: [
                            Text("Your Score", style: GoogleFonts.outfit(color: Colors.white70, fontSize: 14, letterSpacing: 2)),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text("$score", style: GoogleFonts.outfit(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white)),
                                Text("/$total", style: GoogleFonts.outfit(fontSize: 24, color: Colors.white38)),
                              ],
                            )
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 40),
                      
                      // Leaderboard section
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Updated Leaderboard", style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                            const SizedBox(height: 12),
                            Container(
                              decoration: BoxDecoration(
                                color: ArenaColor.darkAmethystLight.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.white10),
                              ),
                              child: leaderboardData.isEmpty 
                                ? const Padding(padding: EdgeInsets.all(16), child: Center(child: Text("No scores available", style: TextStyle(color: Colors.white54))))
                                : ListView.separated(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: leaderboardData.length,
                                    separatorBuilder: (_,__) => Divider(color: Colors.white.withOpacity(0.1), height: 1),
                                    itemBuilder: (context, index) {
                                      final entry = leaderboardData[index];
                                      final isMe = entry['user'] == currentUsername;
                                      return Container(
                                        color: isMe ? ArenaColor.dragonFruit.withOpacity(0.1) : Colors.transparent,
                                        child: ListTile(
                                          leading: Text("#${index + 1}", style: GoogleFonts.outfit(color: isMe ? ArenaColor.dragonFruit : Colors.white, fontWeight: FontWeight.bold)),
                                          title: Text(entry['user'], style: TextStyle(color: isMe ? ArenaColor.dragonFruit : Colors.white, fontWeight: isMe ? FontWeight.bold : FontWeight.normal)),
                                          trailing: Text("${entry['score']} pts", style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
                                        ),
                                      );
                                    },
                                  ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 40),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ArenaColor.dragonFruit,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                        onPressed: () {
                          Navigator.pop(context); // Goes back to List
                        },
                        child: const Text("Back to Arena"),
                      ),
                      const SizedBox(height: 40),
                   ],
                 ),
               ),
             ),
          ),
          
          GlassyHeader(userProvider: userProvider, isHome: false, title: "Arena Invicta", subtitle: "Results"),
        ],
      ),
    );
  }
}