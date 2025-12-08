import 'dart:ui';
import 'package:arena_invicta_mobile/neal_auth/screens/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:arena_invicta_mobile/global/widgets/app_colors.dart';
import 'package:arena_invicta_mobile/neal_auth/screens/login.dart';
import 'package:arena_invicta_mobile/main.dart';

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
              left: 10, 
              right: 20,
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
                    
                    // Jika itu icon back, kasih jarak sedikit
                    if (!isHome) const SizedBox(width: 16),
                    // Jika itu icon burger, kasih jarak lebih sedikit
                    if (isHome) const SizedBox(width: 8),
                    
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.poppins(
                            color: ArenaColor.dragonFruit,
                            fontSize: isHome ? 14 : 10,
                            fontWeight: FontWeight.w600,
                            letterSpacing: isHome ? 0.5 : 1.5,
                          ),
                        ),
                        if (subtitle.isNotEmpty)
                          Text(
                            subtitle,
                            style: GoogleFonts.poppins(
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
                          style: GoogleFonts.poppins(
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
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        
                        // --- LOGIC: Tampilkan Teks HANYA jika isHome == true ---
                        if (isHome) ...[
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    "Hi, ",
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    userProvider.username,
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                roleText,
                                style: GoogleFonts.poppins(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 12),
                        ],
                        // -------------------------------------------------------

                        // FOTO PROFIL (SELALU MUNCUL)
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ProfilePage(),
                              ),
                            );
                          },
                          child: CircleAvatar(
                            radius: 18,
                            backgroundColor: ArenaColor.purpleX11,
                            backgroundImage: (userProvider.avatarUrl != null &&
                                    userProvider.avatarUrl!.isNotEmpty)
                                ? NetworkImage(userProvider.avatarUrl!)
                                : null,
                            child: (userProvider.avatarUrl == null ||
                                    userProvider.avatarUrl!.isEmpty)
                                ? Text(
                                    userProvider.username.isNotEmpty
                                        ? userProvider.username[0].toUpperCase()
                                        : "U",
                                    style: GoogleFonts.poppins( // Konsisten fontnya
                                        fontSize: 14,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  )
                                : null,
                          ),
                        )
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}