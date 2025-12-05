import 'dart:async';
import 'package:arena_invicta_mobile/main.dart'; // Import MyApp untuk routeName
import 'package:arena_invicta_mobile/global/widgets/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class SplashScreen extends StatefulWidget {
  static const String routeName = '/splash';

  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // Variabel untuk nyimpen status koneksi
  bool _hasInternet = false;

  // Variabel untuk memastikan kita tidak navigasi 2x
  bool _isNavigating = false;

  late StreamSubscription<InternetStatus> _listener;

  @override
  void initState() {
    super.initState();
    // Logika Timer: Tunggu 3 detik, lalu pindah ke Home
    // Mulai mendengarkan status internet begitu layar dibuka
    _checkInternetConnection();
  }

  @override
  void dispose() {
    // PENTING: Matikan listener saat layar ditutup agar tidak memory leak
    _listener.cancel();
    super.dispose();
  }
// Timer(const Duration(seconds: 3), () {
//       // Menggunakan pushReplacement agar user tidak bisa 'Back' ke splash screen
//       Navigator.of(context).pushReplacement(
//         PageRouteBuilder(
//           pageBuilder: (context, animation, secondaryAnimation) => const MyHomePage(),
//           transitionsBuilder: (context, animation, secondaryAnimation, child) {
//             return FadeTransition(
//               opacity: animation,
//               child: child,
//             );
//           },
//           transitionDuration: const Duration(milliseconds: 1200),
//         ),
//       );
//     });

  void _checkInternetConnection() {
    // 1. Listener ini akan aktif terus menerus.
    // Jika user mematikan/menyalakan data, fungsi di dalamnya akan terpanggil otomatis.
    _listener = InternetConnection().onStatusChange.listen((InternetStatus status) async {

      switch (status) {
        case InternetStatus.connected:
          if (mounted) {
            setState(() {
              _hasInternet = true;
            });
          }

          if (!_isNavigating) {
            _isNavigating = true;

            // Tambahkan sedikit delay (misal 2 detik) biar splash screen sempat terlihat
            // meskipun internetnya kencang.
            await Future.delayed(const Duration(seconds: 2));
            if (mounted) _navigateToHome();
          }
          break;

        case InternetStatus.disconnected:
          if (mounted) {
            setState(() {
              _hasInternet = false;
              _isNavigating = false;
            });
          }
          break;
      }
    });
  }

  void _navigateToHome() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const HomePage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // Menggunakan animasi Zoom Out + Fade yang keren
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 1.2, end: 1.0).animate(
                CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOut,
                ),
              ),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 1000),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: ArenaColor.mainBackgroundGradient,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon(Icons.gamepad_rounded, size: 100, color: ArenaColor.dragonFruit,),
              Container(
                width: MediaQuery.of(context).size.width * 0.4,
                height: MediaQuery.of(context).size.width * 0.4,
                padding: const EdgeInsets.all(20),
                child: ClipOval(
                  child: Image.asset(
                    "assets/images/arena-invicta.png",
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              const SizedBox(height: 20,),

              const Text(
                "ARENA INVICTA",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 2.0,
                ),
              ),

              const SizedBox(height: 10,),

              const Text(
                "Loading World...",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 50,),

              AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child: _hasInternet
                      // KONDISI 1: INTERNET ADA (Tampilkan Loading)
                      ? Column(
                          key: const ValueKey("Online"), // Key penting untuk animasi
                          children: const [
                             Text(
                              "Connecting to the Arena...",
                              style: TextStyle(color: Colors.white70, fontSize: 14),
                            ),
                            SizedBox(height: 20),
                            CircularProgressIndicator(
                              color: ArenaColor.dragonFruit,
                            ),
                          ],
                        )
                      // KONDISI 2: INTERNET MATI (Tampilkan Pesan Error)
                      : Column(
                          key: const ValueKey("Offline"),
                          children: [
                            Icon(Icons.signal_wifi_off_rounded, size: 50, color: Colors.redAccent.withOpacity(0.8)),
                            const SizedBox(height: 16),
                            const Text(
                              "No Internet Connection",
                              style: TextStyle(
                                color: Colors.redAccent,
                                fontSize: 18,
                                fontWeight: FontWeight.bold
                              ),
                            ),
                            const SizedBox(height: 8),
                             const Text(
                              "Please check your Wi-Fi or Mobile Data to continue.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 30),
                            // Tombol manual check (opsional, karena sebenarnya sudah otomatis)
                            ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white24,
                                  foregroundColor: Colors.white
                                ),
                                onPressed: () async {
                                  // Trigger cek manual (listener akan menangkap hasilnya)
                                  await InternetConnection().hasInternetAccess;
                                },
                                icon: const Icon(Icons.refresh),
                                label: const Text("Retry Now")
                            )
                          ],
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}