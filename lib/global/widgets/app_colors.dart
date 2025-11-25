import 'package:flutter/material.dart';

// ========== Warna Tema Arena Invicta ==========
class ArenaColor {
  static const Color darkAmethyst = Color(0xFF1A103C);
  static const Color darkAmethystLight = Color(0xFF2A1B54);
  static const Color purpleX11 = Color(0xFF9333EA);     // Warna Utama (Primary)
  static const Color dragonFruit = Color(0xFFEC4899);   // Warna Aksen (Secondary)
  static const Color evergreen = Color(0xFF062726);

  // Warna Tambahan untuk Desain Figma
  static const Color textWhite = Colors.white;
  static const Color textPinkAccent = dragonFruit;
  static const Color navBarBackground = Color(0xFF2A1B54); // Agak transparan nanti

  // Gradasi Background Utama (Seperti di desain)
  static const BoxDecoration mainBackgroundGradient = BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        darkAmethyst,
        purpleX11,
        darkAmethyst,
      ],
      // Mengatur titik tengah agar ungu teranngya agak di atas
      stops: [0.0, 0.4, 1.0], 
    ),
  );
}
