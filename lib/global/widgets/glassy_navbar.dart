import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:arena_invicta_mobile/global/widgets/app_colors.dart';
import 'package:arena_invicta_mobile/neal_auth/screens/profile_page.dart';
import 'package:arena_invicta_mobile/main.dart';
import 'package:arena_invicta_mobile/adam_discussions/screens/discussions_page.dart';
import 'package:arena_invicta_mobile/hannan_quiz/screens/quiz_main.dart';
// --- TAMBAHKAN IMPORT INI ---
import 'package:arena_invicta_mobile/rafa_news/screens/news_entry_list.dart';

enum NavbarItem { news, quiz, discussions, league, profile }

class GlassyNavbar extends StatelessWidget {
  final UserProvider userProvider;
  final VoidCallback onFabTap; 
  final IconData fabIcon; 
  final bool isHome;
  final NavbarItem? activeItem;

  const GlassyNavbar({
    super.key,
    required this.userProvider,
    required this.onFabTap,
    this.fabIcon = Icons.home_rounded,
    this.isHome = false, // Default is false (Feature page)
    this.activeItem,
  });

  // Helper to choose Push vs PushReplacement
  void _navigate(BuildContext context, Widget page) {
    if (isHome) {
      // From Home: Stack it
      Navigator.push(context, MaterialPageRoute(builder: (context) => page));
    } else {
      // From Feature: Swap it
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => page));
    }
  }

  @override
  Widget build(BuildContext context) {
    Color _navColor(NavbarItem item) {
      return activeItem == item ? Colors.white : Colors.white54;
    }

    return Positioned(
      bottom: 30,
      left: 24,
      right: 24,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // LAYER 1: GLASS BACKGROUND
          ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
              child: Container(
                height: 75,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E123B).withOpacity(0.70),
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.12),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 30,
                      spreadRadius: -5,
                      offset: const Offset(0, 15),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // LAYER 2: BUTTONS ROW
          SizedBox(
            height: 75,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (userProvider.isLoggedIn)
                  IconButton(
                    tooltip: "Quiz",
                    onPressed: () => _navigate(context, const QuizMainPage()),
                    icon: Icon(Icons.sports_esports_rounded, color: _navColor(NavbarItem.quiz)),
                  )
                else
                  const SizedBox(width: 48, height: 48),

                IconButton(
                  tooltip: "Discussions",
                  onPressed: () => _navigate(context, const DiscussionsPage()),
                  icon: Icon(Icons.forum_rounded, color: _navColor(NavbarItem.discussions)),
                ),

                const SizedBox(width: 60), // Spacer Tengah

                IconButton(
                  tooltip: "League",
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("League Coming Soon!")),
                  ),
                  icon: Icon(Icons.emoji_events_rounded, color: _navColor(NavbarItem.league)),
                ),

                if (userProvider.isLoggedIn)
                  IconButton(
                    tooltip: "Profile",
                    onPressed: () {
                      _navigate(context, const ProfilePage());
                    },
                    icon: Icon(Icons.person_rounded, color: _navColor(NavbarItem.profile)),
                  )
                else
                  const SizedBox(width: 48, height: 48),
              ],
            ),
          ),

          // LAYER 3: FLOATING FAB
          Positioned(
            top: -15,
            child: GestureDetector(
              onTap: () {
                // --- UBAH DI SINI: Navigasi ke NewsEntryListPage ---
                _navigate(context, const NewsEntryListPage());
              },
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [ArenaColor.dragonFruit, ArenaColor.purpleX11],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: ArenaColor.purpleX11.withOpacity(0.5),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ],
                  border: Border.all(color: const Color(0xFF1E123B), width: 4),
                ),
                child: Icon(fabIcon, color: Colors.white, size: 30),
              ),
            ),
          ),
        ],
      ),
    );
  }
}