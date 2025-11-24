import 'package:arena_invicta_mobile/neal_auth/screens/login.dart';
import 'package:arena_invicta_mobile/neal_auth/screens/register.dart';
import 'package:arena_invicta_mobile/neal_auth/widgets/arena_invicta_drawer.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

// Simple enum & session helper
enum UserRole { visitor, registered, staff, admin }

class UserProvider extends ChangeNotifier {
  UserRole _currentRole = UserRole.visitor;
  bool _isLoggedIn = false; // Status login aktif
  String _username = "";

  // Getters
  UserRole get role => _currentRole;
  bool get isLoggedIn => _isLoggedIn;
  String get username => _username;

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
  void login(UserRole newRole, String username) {
    _isLoggedIn = true;
    _currentRole = newRole;
    _username = username;
    notifyListeners(); // <--- PENTING: Memberitahu widget lain untuk rebuild
  }

  void logout() {
    _isLoggedIn = false;
    _currentRole = UserRole.visitor;
    notifyListeners(); // Memberitahu widget lain untuk rebuild
  }
}

// ========== Warna Tema Arena Invicta ==========
class ArenaColor {
  static const Color darkAmethyst = Color(0xFF1A103C);
  static const Color darkAmethystLight = Color(0xFF2A1B54);
  static const Color purpleX11 = Color(0xFF9333EA);     // Warna Utama (Primary)
  static const Color dragonFruit = Color(0xFFEC4899);   // Warna Aksen (Secondary)
  static const Color evergreen = Color(0xFF062726);
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
    return MultiProvider(
      providers: [
        Provider<CookieRequest>(create: (_) => CookieRequest()),

        ChangeNotifierProvider<UserProvider>(create: (_) => UserProvider()),
      ],
      child: MaterialApp(
        title: 'Arena Invicta',
        themeMode: ThemeMode.dark,
        darkTheme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.dark(
            primary: ArenaColor.purpleX11,
            secondary: ArenaColor.dragonFruit,
            surface: ArenaColor.darkAmethyst,
            onSurface: Colors.white,
            background: ArenaColor.evergreen,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: ArenaColor.darkAmethystLight,
            foregroundColor: Colors.white,
          ),
          textTheme: GoogleFonts.poppinsTextTheme(
            Theme.of(context).textTheme,
          ).copyWith(
            displayLarge: GoogleFonts.orbitron(
              textStyle: Theme.of(context).textTheme.displayLarge,
              color: Colors.white,
            ),
            displayMedium: GoogleFonts.orbitron(
              textStyle: Theme.of(context).textTheme.displayMedium,
              color: Colors.white,
            ),
            headlineLarge: GoogleFonts.orbitron(
              textStyle: Theme.of(context).textTheme.headlineLarge,
              color: Colors.white,
            ),
            headlineMedium: GoogleFonts.orbitron(
              textStyle: Theme.of(context).textTheme.headlineMedium,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            bodyLarge: GoogleFonts.poppins(color: Colors.white),
            bodyMedium: GoogleFonts.poppins(color: Colors.white70),
          ),
        ),

        // Route Management dan Route Utama
        initialRoute: MyApp.routeName,
        routes: {
          MyApp.routeName: (context) => MyHomePage(),
          LoginPage.routeName: (context) => const LoginPage(),
          RegisterPage.routeName: (context) => const RegisterPage(),
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
  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final roleText = userProvider.roleLabel;

    return Scaffold(
      // App Bar
      appBar: AppBar(
        backgroundColor: AppBarTheme.of(context).backgroundColor,
        foregroundColor: AppBarTheme.of(context).foregroundColor,
        title: const Text("Arena Invicta"),
        actions: [
          if (!userProvider.isLoggedIn) ...[
            IconButton(
              icon: const Icon(Icons.login),
              onPressed: () {
                Navigator.pushNamed(context, LoginPage.routeName);
              },
            ),
            IconButton(
              icon: const Icon(Icons.app_registration),
              onPressed: () {
                Navigator.pushNamed(context, RegisterPage.routeName);
              },
            ),
          ] else ...[
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                // Panggil fungsi logout di provider
                // Gunakan context.read karena ini di dalam onPressed (tidak butuh watch)
                context.read<UserProvider>().logout();

                // Opsional: panggil endpoint logout di Django juga diperlukan
                // final request = context.read<CookieRequest>();
                // await request.logout("http://.../accounts/logout/");

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Berhasil Logout!")),
                );
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
              const Text(
                'Anda belum login. Silakan login untuk mengakses fitur lebih lengkap.',
                style: TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
