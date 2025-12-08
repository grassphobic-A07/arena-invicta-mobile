import 'dart:ui';
import 'package:arena_invicta_mobile/global/widgets/app_colors.dart';
import 'package:arena_invicta_mobile/global/widgets/glassy_header.dart'; 
import 'package:arena_invicta_mobile/global/widgets/glassy_navbar.dart'; 
import 'package:arena_invicta_mobile/hannan_quiz/screens/create_quiz_screen.dart';
import 'package:arena_invicta_mobile/hannan_quiz/widgets/private_quiz_list.dart';
import 'package:arena_invicta_mobile/hannan_quiz/widgets/public_quiz_list.dart';
import 'package:arena_invicta_mobile/main.dart'; 
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class QuizMainPage extends StatefulWidget {
  const QuizMainPage({super.key});
  static const routeName = '/quiz';

  @override
  State<QuizMainPage> createState() => _QuizMainPageState();
}

class _QuizMainPageState extends State<QuizMainPage> {
  String _searchQuery = "";
  String _selectedCategory = "All";

  // GlobalKey allows us to access the state of PrivateQuizList to trigger refresh
  final GlobalKey<PrivateQuizListState> _privateListKey = GlobalKey<PrivateQuizListState>();

  final List<String> _categories = [
    "All", "Football", "Basketball", "Tennis", "Volleyball", "Motogp"
  ];

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
    final role = userProvider.role;
    final bool isStaff = role == UserRole.staff;
    final String pageTitle = isStaff ? "My Quiz Vault" : "Quiz Arena";

    return Scaffold(
      backgroundColor: ArenaColor.darkAmethyst,
      resizeToAvoidBottomInset: false, 
      body: Stack(
        children: [
          Positioned(top: -100, left: -50, child: _buildGlowCircle(ArenaColor.purpleX11)),
          Positioned(bottom: -100, right: -50, child: _buildGlowCircle(ArenaColor.dragonFruit)),

          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 70, 
                bottom: 120 
              ),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  // Search Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withOpacity(0.1)),
                      ),
                      child: TextField(
                        style: const TextStyle(color: Colors.white),
                        onChanged: (value) => setState(() => _searchQuery = value),
                        decoration: InputDecoration(
                          hintText: isStaff ? "Search my quizzes..." : "Find a quiz...",
                          hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                          prefixIcon: const Icon(Icons.search, color: Colors.white54),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Category Chips
                  SizedBox(
                    height: 40,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: _categories.length,
                      itemBuilder: (context, index) {
                        final cat = _categories[index];
                        final isSelected = _selectedCategory == cat;
                        return Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedCategory = cat),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected ? ArenaColor.dragonFruit : ArenaColor.darkAmethystLight.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: isSelected ? ArenaColor.dragonFruit : Colors.white.withOpacity(0.1)),
                              ),
                              child: Text(
                                cat,
                                style: GoogleFonts.outfit(color: Colors.white, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, fontSize: 14),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Content List
                  Expanded(
                    child: isStaff 
                      ? PrivateQuizList(
                          key: _privateListKey, // Assign GlobalKey
                          searchQuery: _searchQuery, 
                          category: _selectedCategory
                        )
                      : PublicQuizList(searchQuery: _searchQuery, category: _selectedCategory),
                  ),
                ],
              ),
            ),
          ),

          GlassyHeader(userProvider: userProvider, isHome: false, title: "Arena Invicta", subtitle: pageTitle),
          
          GlassyNavbar(
            userProvider: userProvider,
            isHome: false,
            fabIcon: Icons.grid_view_rounded, 
            onFabTap: () => Navigator.pop(context),
          ),
        ],
      ),
      // Floating Action Button
      floatingActionButton: isStaff ? Padding(
        padding: const EdgeInsets.only(bottom: 100),
        child: FloatingActionButton.extended(
          onPressed: () async {
            // Wait for navigation result
            final bool? result = await Navigator.push(
              context, 
              MaterialPageRoute(builder: (context) => const CreateQuizScreen())
            );
            
            // If result is true (Created), refresh the list via Key
            if (result == true) {
              _privateListKey.currentState?.handleRefresh();
            }
          },
          backgroundColor: ArenaColor.dragonFruit,
          icon: const Icon(Icons.add, color: Colors.white),
          label: Text("Create Quiz", style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white)),
        ),
      ) : null,
    );
  }
}