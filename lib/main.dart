import 'package:arena_invicta_mobile/global/providers/connection_provider.dart';
import 'package:arena_invicta_mobile/global/screens/splash_screen.dart';
import 'package:arena_invicta_mobile/global/widgets/offline_overlay.dart';
import 'package:arena_invicta_mobile/neal_auth/screens/login.dart';
import 'package:arena_invicta_mobile/neal_auth/screens/register.dart';
import 'package:arena_invicta_mobile/neal_auth/widgets/arena_invicta_drawer.dart';
import 'package:arena_invicta_mobile/adam_discussions/discussions_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:arena_invicta_mobile/global/widgets/glass_bottom_nav.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'global/widgets/app_colors.dart';
import 'package:arena_invicta_mobile/neal_auth/screens/profile_page.dart';

// Simple enum & session helper
enum UserRole { visitor, registered, staff, admin }

class UserProvider extends ChangeNotifier {
  UserRole _currentRole = UserRole.visitor;
  bool _isLoggedIn = false; // Status login aktif
  String _username = "";
  String? _avatarUrl; // Tambahkan ini

  // Getters
  UserRole get role => _currentRole;
  bool get isLoggedIn => _isLoggedIn;
  String get username => _username;
  String? get avatarUrl => _avatarUrl; // Tambahkan getter

  String get roleLabel {
    switch (role) {
      case UserRole.registered:
        return "Registered User";
      case UserRole.staff:
        return "Content Staff";
      case UserRole.admin:
        return "Administrator";
      default:
        return "Visitor";
    }
  }

  // Fungsi untuk Login (dipanggil dari login.dart nanti)
  void login(UserRole newRole, String username, {String? avatarUrl}) {
    _isLoggedIn = true;
    _currentRole = newRole;    
    _username = username;
    _avatarUrl = avatarUrl;
    notifyListeners(); // <--- PENTING: Memberitahu widget lain untuk rebuild
  }

  // Tambahkan fungsi khusus update profil
  void updateProfileData({String? newAvatarUrl}) {
    if (newAvatarUrl != null) {
      _avatarUrl = newAvatarUrl;
      notifyListeners(); // Memberitahu semua widget (termasuk Drawer) untuk refresh
    }
  }

  void logout() {
    _isLoggedIn = false;
    _currentRole = UserRole.visitor;
    notifyListeners(); // Memberitahu widget lain untuk rebuild
  }
}


void main() {
  runApp(const MyApp());
}

// ========== File Utama Arena Invicta ==========
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  static const String routeName = '/home';

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // Supaya bisa ke semua tempat
    return MultiProvider(
      providers: [
        Provider<CookieRequest>(create: (_) => CookieRequest()),
        ChangeNotifierProvider<UserProvider>(create: (_) => UserProvider()),

        // Provider untuk check koneksi internet di semua halaman aplikasi. Karena basisnya harus konek
        ChangeNotifierProvider<ConnectionProvider>(create: (_) => ConnectionProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Arena Invicta',
        themeMode: ThemeMode.dark,
        darkTheme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.dark(
            primary: ArenaColor.purpleX11,
            secondary: ArenaColor.dragonFruit,
            surface: ArenaColor.darkAmethyst,
            onSurface: Colors.white,
          ),

          appBarTheme: AppBarTheme(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
            titleTextStyle: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.white,
            ),
          ),

          textTheme: GoogleFonts.poppinsTextTheme(
            Theme.of(context).textTheme,
          ).apply(
            bodyColor: Colors.white,
            displayColor: Colors.white,
          ),
        ),

        // Route Management dan Route Utama
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          SplashScreen.routeName: (context) => const SplashScreen(),
          MyApp.routeName: (context) => MyHomePage(),
          LoginPage.routeName: (context) => const LoginPage(),
          RegisterPage.routeName: (context) => const RegisterPage(),
          ProfilePage.routeName: (context) => const ProfilePage(),
          DiscussionsPage.routeName: (context) => const DiscussionsPage(),
        },
        
        // --- BAGIAN PENTING: BUNGKUS SEMUA HALAMAN DI SINI ---
        builder: (context, child) {
          /* Bagaimana Hasilnya?

            1. Splash Screen: Tetap berfungsi sebagai gerbang awal. Dia memastikan internet ada sebelum masuk ke Home pertama kali.

            2. Global Blocker: Setelah masuk ke aplikasi (Home, Login, Register, dll), jika tiba-tiba internet mati:

                - ConnectionProvider akan mendeteksi perubahan status menjadi disconnected.

                - Dia memberi tahu OfflineOverlayWrapper.

                - OfflineOverlayWrapper akan memunculkan layar hitam transparan dengan CircularProgressIndicator di atas halaman yang sedang aktif.

                - Pengguna tidak bisa menekan tombol apa pun di balik layar hitam itu (IgnorePointer).

            3. Auto Reconnect: Begitu internet nyala lagi:

                - Provider mendeteksi status connected.

                - Layar hitam otomatis hilang, dan pengguna bisa lanjut menggunakan aplikasi dari halaman terakhir mereka berada. */
          // 'child' di sini adalah halaman manapun yang sedang dibuka oleh Navigator
          // Kita bungkus dia dengan OfflineOverlayWrapper
          return OfflineOverlayWrapper(child: child!);
        },
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         

class _MyHomePageState extends State<MyHomePage> {
  void _handleNavTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        // Already on home.
        break;
      case 1:
        Navigator.pushReplacementNamed(context, DiscussionsPage.routeName);
        break;
      case 2:
        // Placeholder for stats.
        break;
      case 3:
        // Placeholder for profile.
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final roleText = userProvider.roleLabel;

    return Stack(
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.topLeft,
                radius: 1.2,
                colors: [
                  Color(0xFF9333EA),
                  Color(0xFF2A1B54),
                ],
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.bottomRight,
                radius: 1.2,
                colors: [
                  Color(0xFF4A49A0),
                  Color(0xFF2A1B54),
                ],
              ),
            ),
          ),
        ),
        Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: AppBarTheme.of(context).backgroundColor,
            foregroundColor: AppBarTheme.of(context).foregroundColor,
            title: const Text("Arena Invicta"),
            actions: [
              if (!userProvider.isLoggedIn) ...[
                TextButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, LoginPage.routeName);
                  },
                  icon: const Icon(Icons.login, color: ArenaColor.textWhite,),
                  label: const Text(
                    "Login",
                    style: TextStyle(color: ArenaColor.textWhite),
                  ),
                ),
              ] else ...[
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () async {
                    // Panggil fungsi logout di provider
                    // Gunakan context.read karena ini di dalam onPressed (tidak butuh watch)
                    final request = context.read<CookieRequest>();

                    final response = await request.logout("https://neal-guarddin-arenainvicta.pbp.cs.ui.ac.id/accounts/api/logout/");
                    if (context.mounted) {
                        context.read<UserProvider>().logout();
                        
                        String message = response['message'] ?? "Berhasil Logout!";
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(message), backgroundColor: Colors.greenAccent),
                        );
                        
                        // Opsional: Redirect ke Login Page agar bersih
                        Navigator.pushReplacementNamed(context, MyApp.routeName);
                    }
                    // Opsional: panggil endpoint logout di Django juga diperlukan
                    // final request = context.read<CookieRequest>();
                    // await request.logout("http://.../accounts/logout()");
        
                  },
                ),
              ],
            ],
          ),
        
          // Drawer App
          drawer: ArenaInvictaDrawer(
            userProvider: userProvider,
            roleText: roleText,
          ),
        
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text('Role aktif: $roleText'),
                const SizedBox(height: 12),
                if (!userProvider.isLoggedIn) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: const Text(
                      'Anda belum login. Silakan login untuk mengakses fitur lebih lengkap.',
                      style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: GlassBottomNavBar(
            activeIndex: 0,
            onItemTap: (index) => _handleNavTap(context, index),
            onCenterTap: () {},
          ),
        ),
      ],
    );
  }
}
