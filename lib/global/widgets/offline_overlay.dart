import 'package:arena_invicta_mobile/global/providers/connection_provider.dart';
import 'package:arena_invicta_mobile/global/widgets/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OfflineOverlayWrapper extends StatelessWidget {
  // Widget ini akan membungkus halaman apapun yang sedang aktif. 
  // Dia menggunakan Stack. Lapisan bawahnya adalah halaman aplikasi, 
  // lapisan atasnya adalah layar hitam transparan dengan loading yang 
  // hanya muncul jika internet mati.
  final Widget child;

  const OfflineOverlayWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    // Dengarkan perubahan status dari ConnectionProvider
    final connectionProvider = context.watch<ConnectionProvider>();
    final bool isOnline = connectionProvider.isConnected;

    // Gunakan Stack untuk menumpuk UI
    return Stack(
      children: [
        // LAPISAN 1 (Bawah): Halaman Aplikasi yang Sebenarnya
        // Jika offline, kita bungkus dengan IgnorePointer agar tidak bisa diklik
        IgnorePointer(
          ignoring: !isOnline, // Kalau gak online, abaikan sentuhan
          child: child, 
        ),

        // LAPISAN 2 (Atas): Tirai Loading (Hanya muncul jika offline)
        if (!isOnline)
          Container(
            // Latar belakang hitam transparan (Glass effect gelap)
            color: ArenaColor.darkAmethyst.withOpacity(0.9),
            width: double.infinity,
            height: double.infinity,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  // Ikon Sinyal Putus
                  Icon(Icons.cloud_off_rounded, size: 60, color: ArenaColor.dragonFruit),
                  SizedBox(height: 20),
                  // Teks Keren
                  Text(
                    "LOST CONNECTION TO THE ARENA",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white, 
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                      fontSize: 20,
                    ),
                  ),
                   SizedBox(height: 10),
                   Text(
                    "Reconnecting...",
                    style: TextStyle(
                      color: Colors.white70,
                      letterSpacing: 1.2,
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(height: 30),
                  // Loading indicator sesuai request
                  CircularProgressIndicator(
                    color: ArenaColor.dragonFruit,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}