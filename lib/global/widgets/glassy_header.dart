import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:arena_invicta_mobile/global/widgets/app_colors.dart';
import 'package:arena_invicta_mobile/neal_auth/screens/login.dart';
import 'package:arena_invicta_mobile/main.dart'; // Untuk akses UserProvider & UserRole

class GlassyHeader extends StatelessWidget {
  final UserProvider userProvider;
  final GlobalKey<ScaffoldState>? scaffoldKey; // Hanya perlu jika isHome = true
  final bool isHome;
  final String title;
  final String subtitle;

  const GlassyHeader({
    super.key,
    required this.userProvider,
    this.scaffoldKey,
    this.isHome = true, // Defaultnya Home
    this.title = "Arena Invicta",
    this.subtitle = "", 
  });

  @override
  Widget build(BuildContext context) {
    // Tentukan Role Text
    String roleText = "Guest";
    if (userProvider.isLoggedIn) {
      if (userProvider.role == UserRole.admin) roleText = "Admin";
      else if (userProvider.role == UserRole.staff) roleText = "Writer"; 
      else roleText = "Member";
    }

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(5.0)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            color: ArenaColor.darkAmethyst.withOpacity(0.3),
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 10,
              bottom: 20,
              left: 24,
              right: 24,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // --- KIRI: ICON & JUDUL ---
                Row(
                  children: [
                    // Jika Home -> Burger Menu, Jika Tidak -> Back Button
                    if (isHome)
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () => scaffoldKey?.currentState?.openDrawer(),
                        icon: const Icon(Icons.menu, color: Colors.white70),
                      )
                    else
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
                        ),
                      ),
                    
                    const SizedBox(width: 16),
                    
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.outfit(
                            color: ArenaColor.dragonFruit,
                            fontSize: isHome ? 18 : 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: isHome ? 0.5 : 1.5,
                          ),
                        ),
                        if (subtitle.isNotEmpty)
                          Text(
                            subtitle,
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),

                // --- KANAN: LOGIN / PROFILE ---
                if (!userProvider.isLoggedIn)
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, LoginPage.routeName),
                    child: Row(
                      children: [
                        Text(
                          "Login",
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.login_rounded, color: Colors.white, size: 20),
                      ],
                    ),
                  )
                else
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          RichText(
                            text: TextSpan(
                              style: GoogleFonts.outfit(fontSize: 14, color: Colors.white),
                              children: [
                                const TextSpan(text: "Hi, ", style: TextStyle(fontWeight: FontWeight.w300)),
                                TextSpan(
                                  text: userProvider.username,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            roleText,
                            style: GoogleFonts.outfit(fontSize: 10, color: Colors.white70),
                          ),
                        ],
                      ),
                      const SizedBox(width: 12),
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: ArenaColor.purpleX11,
                        backgroundImage: (userProvider.avatarUrl != null && userProvider.avatarUrl!.isNotEmpty)
                            ? NetworkImage(userProvider.avatarUrl!)
                            : null,
                        child: (userProvider.avatarUrl == null || userProvider.avatarUrl!.isEmpty)
                            ? Text(
                                userProvider.username.isNotEmpty
                                    ? userProvider.username[0].toUpperCase()
                                    : "U",
                                style: const TextStyle(
                                    fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold),
                              )
                            : null,
                      )
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