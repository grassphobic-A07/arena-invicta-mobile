import 'dart:ui'; // PENTING: Untuk ImageFilter
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
      width: 320,
      height: 320,
      decoration: BoxDecoration(
        color: color.withOpacity(0.22),
        shape: BoxShape.circle,
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 90, sigmaY: 90),
        child: const SizedBox.shrink(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final role = userProvider.role;
    final bool isStaff = role == UserRole.staff;
    final String pageTitle = isStaff ? "My Quiz Vault" : "Quiz Arena";

    // Hitung area aman untuk Sticky Header
    final double headerTop = MediaQuery.of(context).padding.top + 70; 
    final double stickyContentHeight = 130; 
    final double listTopPadding = headerTop + stickyContentHeight;

    return Scaffold(
      backgroundColor: ArenaColor.darkAmethyst,
      resizeToAvoidBottomInset: false, 
      body: Stack(
        children: [
          // 0. BACKGROUND GLOWS (repositioned for quiz)
          Positioned(top: -140, right: -80, child: _buildGlowCircle(ArenaColor.dragonFruit)),
          Positioned(bottom: -160, left: -100, child: _buildGlowCircle(ArenaColor.purpleX11)),
          // 1. LAYER KONTEN (LIST)
          Positioned.fill(
            child: isStaff 
              ? PrivateQuizList(
                  key: _privateListKey, 
                  searchQuery: _searchQuery, 
                  category: _selectedCategory,
                  contentPadding: EdgeInsets.only(
                    top: listTopPadding, 
                    bottom: 120, 
                    left: 24, 
                    right: 24
                  ),
                )
              : PublicQuizList(
                  searchQuery: _searchQuery, 
                  category: _selectedCategory,
                  contentPadding: EdgeInsets.only(
                    top: listTopPadding, 
                    bottom: 120, 
                    left: 24, 
                    right: 24
                  ),
                ),
          ),

          // 2. HEADER
          GlassyHeader(
            userProvider: userProvider, 
            isHome: false, 
            title: "Arena Invicta", 
            subtitle: pageTitle
          ),

          // 3. STICKY SEARCH BAR & CHIPS (Fixed Position)
          Positioned(
            top: headerTop, 
            left: 0,
            right: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // --- SEARCH BAR (GLASSY) ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), // Blur Effect
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1), // Semi-transparent BG
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
                  ),
                ),
                const SizedBox(height: 16),
                
                // --- CATEGORY CHIPS (GLASSY PER ITEM) ---
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
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), // Blur Effect
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                decoration: BoxDecoration(
                                  // Background semi-transparent + warna aktif
                                  color: isSelected 
                                      ? ArenaColor.dragonFruit.withOpacity(0.8) 
                                      : Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isSelected 
                                        ? ArenaColor.dragonFruit 
                                        : Colors.white.withOpacity(0.1)
                                  ),
                                ),
                                child: Text(
                                  cat,
                                  style: GoogleFonts.outfit(
                                    color: Colors.white, 
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, 
                                    fontSize: 14
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // 4. NAVBAR
          GlassyNavbar(
            userProvider: userProvider,
            fabIcon: Icons.grid_view_rounded, 
            isHome: false,
            activeItem: NavbarItem.quiz,
            onFabTap: () => Navigator.pop(context),
          ),
        ],
      ),
      
      // Floating Action Button
      floatingActionButton: isStaff ? Padding(
        padding: const EdgeInsets.only(bottom: 100),
        child: FloatingActionButton.extended(
          onPressed: () async {
            final bool? result = await Navigator.push(
              context, 
              MaterialPageRoute(builder: (context) => const CreateQuizScreen())
            );
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