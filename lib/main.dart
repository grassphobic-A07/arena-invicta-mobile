// main.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:arena_invicta_mobile/global/widgets/app_colors.dart';
import 'package:arena_invicta_mobile/global/screens/splash_screen.dart';
import 'package:arena_invicta_mobile/neal_auth/widgets/arena_invicta_drawer.dart';
import 'package:arena_invicta_mobile/neal_auth/screens/login.dart';
import 'package:arena_invicta_mobile/neal_auth/screens/register.dart';
import 'package:arena_invicta_mobile/neal_auth/screens/profile_page.dart';
import 'package:arena_invicta_mobile/rafa_news/screens/news_entry_list.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static const String routeName = '/home';

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // 1. Provider untuk Autentikasi PBP Django
        Provider(
          create: (_) {
            CookieRequest request = CookieRequest();
            return request;
          },
        ),
        // 2. Provider untuk User State Management
        ChangeNotifierProvider(
          create: (_) => UserProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'SportPulse',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.deepPurple,
          scaffoldBackgroundColor: ArenaColor.darkAmethyst,
          useMaterial3: true,
          textTheme: GoogleFonts.poppinsTextTheme(), // Set font default Poppins
        ),
        // Route awal (bisa Splash atau Home)
        initialRoute: SplashScreen.routeName,
        routes: {
          SplashScreen.routeName: (context) => const SplashScreen(),
          MyApp.routeName: (context) => const HomePage(),
          LoginPage.routeName: (context) => const LoginPage(),
          RegisterPage.routeName: (context) => const RegisterPage(),
          ProfilePage.routeName: (context) => const ProfilePage(),
        },
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Key untuk mengontrol Scaffold agar bisa buka drawer manual
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String activeCategory = "All";
  final List<String> categories = ["All", "Basketball", "Tennis", "Football"];

  // Header tinggi (dipakai untuk memberikan ruang pada konten di bawahnya)
  static const double _headerHeight = 76.0;

  @override
  Widget build(BuildContext context) {
    // Ambil data user dari Provider
    final userProvider = context.watch<UserProvider>();

    // Tentukan teks role untuk drawer
    String roleText = "Guest";
    if (userProvider.isLoggedIn) {
      if (userProvider.role == UserRole.admin) {
        roleText = "Admin";
      } else if (userProvider.role == UserRole.staff) {
        roleText = "Content Staff";
      } else {
        roleText = "Registered Member";
      }
    }

    return Scaffold(
      key: _scaffoldKey, // Pasang Key di sini
      backgroundColor: ArenaColor.darkAmethyst,
      drawer: ArenaInvictaDrawer(
        userProvider: userProvider,
        roleText: roleText,
      ),
      body: Stack(
        children: [
          // 1. Background Glow (Efek Cahaya) - tetap ada
          Positioned(
            top: -100,
            left: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: ArenaColor.purpleX11.withOpacity(0.4),
                shape: BoxShape.circle,
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: ArenaColor.dragonFruit.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),

          // 2. MAIN SCROLLABLE CONTENT (LETakkan DI BAWAH HEADER)
          Positioned.fill(
            child: SafeArea(
              bottom: false,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Beri ruang di atas agar konten tidak langsung 'tersembunyi' di bawah header
                    SizedBox(height: _headerHeight + 12),

                    // --- Hero Banner ---
                    Container(
                      height: 180,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        image: const DecorationImage(
                          image: NetworkImage(
                              "https://images.unsplash.com/photo-1682687220742-aba13b6e50ba?q=80&w=1000&auto=format&fit=crop"),
                          fit: BoxFit.cover,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: ArenaColor.purpleX11.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              ArenaColor.darkAmethyst.withOpacity(0.8),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // --- Categories Chips ---
                    SizedBox(
                      height: 45,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: categories.length,
                        itemBuilder: (context, index) {
                          final cat = categories[index];
                          final isActive = activeCategory == cat;
                          return GestureDetector(
                            onTap: () => setState(() => activeCategory = cat),
                            child: Container(
                              margin: const EdgeInsets.only(right: 12),
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: isActive
                                    ? ArenaColor.purpleX11
                                    : ArenaColor.darkAmethystLight.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(100),
                                border: Border.all(
                                  color: isActive
                                      ? ArenaColor.purpleX11
                                      : Colors.white.withOpacity(0.1),
                                ),
                              ),
                              child: Text(
                                cat,
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 24),

                    // --- Big News Cards ---
                    const HomeNewsCard(
                      title: "Bola Basket",
                      subtitle: "Highlights NBA 2025",
                      tag: "Basketball",
                      imageUrl:
                          "https://images.unsplash.com/photo-1546519638-68e109498ffc?q=80&w=800&auto=format&fit=crop",
                    ),
                    const SizedBox(height: 20),
                    const HomeNewsCard(
                      title: "Sepak Bola",
                      subtitle: "Laga Sengit Premier League",
                      tag: "Football",
                      imageUrl:
                          "https://images.unsplash.com/photo-1508098682722-e99c43a406b2?q=80&w=800&auto=format&fit=crop",
                    ),
                    const SizedBox(height: 300),
                  ],
                ),
              ),
            ),
          ),

          // 3. GLASSY HEADER (DI ATAS CONTENT -> BackdropFilter akan efektif)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _buildGlassyHeader(userProvider),
          ),

          // 4. Floating Bottom Navigation - GLASSY (DI ATAS CONTENT)
          Positioned(
            bottom: 30,
            left: 24,
            right: 24,
            child: _buildGlassyBottomNav(),
          ),
        ],
      ),
    );
  }

  // BUILD GLASSY HEADER WIDGET (menggunakan _scaffoldKey untuk buka drawer)
  Widget _buildGlassyHeader(UserProvider userProvider) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(15),
        bottomRight: Radius.circular(15),
      ),
      child: BackdropFilter(
        // blur agar efek glassy terasa saat konten melewatinya
        filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
        child: Container(
          height: _headerHeight,
          padding: const EdgeInsets.fromLTRB(24, 18, 24, 10),
          decoration: BoxDecoration(
            // Tint warna ke #1E123B tapi masih transparan
            color: const Color(0xFF1E123B).withOpacity(0.18),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(15),
              bottomRight: Radius.circular(15),
            ),
            border: Border(
              // garis halus bawah untuk definisi
              bottom: BorderSide(
                color: Colors.white.withOpacity(0.06),
                width: 1,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Tombol Menu
              IconButton(
                onPressed: () {
                  _scaffoldKey.currentState?.openDrawer();
                },
                icon: const Icon(Icons.menu, color: Colors.white),
              ),

              // Title
              Text(
                "Arena Invicta",
                style: GoogleFonts.outfit(
                  color: ArenaColor.dragonFruit,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),

              // Login / Avatar
              Row(
                children: [
                  Text(
                    userProvider.isLoggedIn ? userProvider.username : "Login",
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  userProvider.isLoggedIn
                      ? CircleAvatar(
                          radius: 12,
                          backgroundColor: ArenaColor.purpleX11,
                          backgroundImage: (userProvider.avatarUrl != null && userProvider.avatarUrl!.isNotEmpty)
                              ? NetworkImage(userProvider.avatarUrl!)
                              : null,
                          child: (userProvider.avatarUrl == null || userProvider.avatarUrl!.isEmpty)
                              ? Text(
                                  userProvider.username.isNotEmpty ? userProvider.username[0].toUpperCase() : "",
                                  style: const TextStyle(fontSize: 10, color: Colors.white),
                                )
                              : null,
                        )
                      : const Icon(Icons.login, color: Colors.white, size: 20),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // BUILD GLASSY BOTTOM NAV
  Widget _buildGlassyBottomNav() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          height: 75,
          decoration: BoxDecoration(
            // tint sedikit gelap tapi transparan agar tampak glassy
            color: ArenaColor.evergreen.withOpacity(0.18),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: Colors.white.withOpacity(0.06),
              width: 1,
            ),
            boxShadow: [
              // shadow tipis untuk depth
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.chat_bubble_outline_rounded, color: Colors.white54),
                  ),
                  const SizedBox(width: 60),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.bar_chart_rounded, color: Colors.white54),
                  ),
                ],
              ),
              Positioned(
                top: -15,
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, NewsEntryListPage.routeName);
                  },
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          ArenaColor.dragonFruit,
                          ArenaColor.purpleX11,
                        ],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: ArenaColor.purpleX11.withOpacity(0.5),
                          blurRadius: 15,
                          spreadRadius: 2,
                        ),
                      ],
                      border: Border.all(
                        color: ArenaColor.darkAmethyst,
                        width: 4,
                      ),
                    ),
                    child: const Icon(
                      Icons.grid_view_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- WIDGET KARTU BERITA HOME (LOKAL) ---
class HomeNewsCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String tag;
  final String imageUrl;

  const HomeNewsCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.tag,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        image: DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.cover,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Dark Gradient Overlay
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  ArenaColor.darkAmethyst.withOpacity(0.2),
                  ArenaColor.darkAmethyst.withOpacity(0.9),
                ],
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Tag
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: ArenaColor.dragonFruit.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: ArenaColor.dragonFruit.withOpacity(0.5)),
                    boxShadow: [
                      BoxShadow(
                        color: ArenaColor.dragonFruit.withOpacity(0.2),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Text(
                    tag,
                    style: GoogleFonts.outfit(
                      color: ArenaColor.dragonFruit,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --- USER PROVIDER (JIKA BELUM ADA) ---
enum UserRole { registered, staff, admin }

class UserProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  String _username = "";
  UserRole _role = UserRole.registered;
  String? _avatarUrl;

  bool get isLoggedIn => _isLoggedIn;
  String get username => _username;
  UserRole get role => _role;
  String? get avatarUrl => _avatarUrl;

  void login(UserRole role, String username, {String? avatarUrl}) {
    _isLoggedIn = true;
    _role = role;
    _username = username;
    _avatarUrl = avatarUrl;
    notifyListeners();
  }

  void logout() {
    _isLoggedIn = false;
    _username = "";
    _avatarUrl = null;
    notifyListeners();
  }

  void updateProfileData({String? newAvatarUrl}) {
    if (newAvatarUrl != null) _avatarUrl = newAvatarUrl;
    notifyListeners();
  }
}