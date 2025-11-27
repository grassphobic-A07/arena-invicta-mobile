import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

// --- IMPORTS MODUL ---
import 'package:arena_invicta_mobile/global/widgets/app_colors.dart';
import 'package:arena_invicta_mobile/global/screens/splash_screen.dart';
import 'package:arena_invicta_mobile/global/widgets/glassy_header.dart'; // WIDGET HEADER
import 'package:arena_invicta_mobile/global/widgets/glassy_navbar.dart'; // WIDGET NAVBAR

import 'package:arena_invicta_mobile/neal_auth/widgets/arena_invicta_drawer.dart';
import 'package:arena_invicta_mobile/neal_auth/screens/login.dart';
import 'package:arena_invicta_mobile/neal_auth/screens/register.dart';
import 'package:arena_invicta_mobile/neal_auth/screens/profile_page.dart';

import 'package:arena_invicta_mobile/rafa_news/screens/news_entry_list.dart';
import 'package:arena_invicta_mobile/rafa_news/models/news_entry.dart';
import 'package:arena_invicta_mobile/rafa_news/screens/news_detail_page.dart';

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
        Provider(
          create: (_) {
            CookieRequest request = CookieRequest();
            return request;
          },
        ),
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
          textTheme: GoogleFonts.poppinsTextTheme(),
        ),
        initialRoute: SplashScreen.routeName,
        routes: {
          SplashScreen.routeName: (context) => const SplashScreen(),
          MyApp.routeName: (context) => const HomePage(),
          LoginPage.routeName: (context) => const LoginPage(),
          RegisterPage.routeName: (context) => const RegisterPage(),
          ProfilePage.routeName: (context) => const ProfilePage(),
          NewsEntryListPage.routeName: (context) => const NewsEntryListPage(),
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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String activeCategory = "All";
  final List<String> categories = ["All", "Football", "Basketball", "Tennis", "Volleyball", "Motogp"];

  // --- FUNGSI FETCH NEWS DARI DJANGO ---
  Future<List<NewsEntry>> fetchHomeNews(CookieRequest request) async {
    String url = 'https://neal-guarddin-arenainvicta.pbp.cs.ui.ac.id/show-news-json';
    
    if (activeCategory != "All") {
      url += '?filter=${activeCategory.toLowerCase()}';
    }

    try {
      final response = await request.get(url);
      List<NewsEntry> listNews = [];
      for (var d in response) {
        if (d != null) {
          listNews.add(NewsEntry.fromJson(d));
        }
      }

      // Sort by Views Tertinggi -> Ambil 5 Teratas
      listNews.sort((a, b) => b.newsViews.compareTo(a.newsViews));
      return listNews.take(5).toList(); 
      
    } catch (e) {
      debugPrint("Error fetching news: $e");
      return [];
    }
  }

  Widget _buildGlowCircle(Color color) {
    return Container(
      width: 300,
      height: 300,
      decoration: BoxDecoration(
        color: color.withOpacity(0.2), 
        shape: BoxShape.circle,
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
        child: Container(color: Colors.transparent),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final request = context.watch<CookieRequest>();
    
    return Scaffold(
      key: _scaffoldKey, 
      backgroundColor: ArenaColor.darkAmethyst,
      resizeToAvoidBottomInset: false,
      
      drawer: ArenaInvictaDrawer(
        userProvider: userProvider,
        roleText: "", 
      ),

      body: Stack(
        children: [
          // 1. BACKGROUND GLOWS
          Positioned(top: -100, left: -50, child: _buildGlowCircle(ArenaColor.purpleX11)),
          Positioned(bottom: -100, right: -50, child: _buildGlowCircle(ArenaColor.dragonFruit)),

          // 2. MAIN CONTENT
          Positioned.fill(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 110, 24, 120), 
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- CATEGORIES CHIPS (FIXED: MATCHING NEWS LIST STYLE) ---
                  SizedBox(
                    height: 45,
                    child: Center(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: categories.map((cat) {
                            final isAll = cat == "All";
                            
                            // Di Home, tombol tidak aktif secara visual (selalu style default)
                            // karena fungsinya navigasi.
                            
                            return GestureDetector(
                              onTap: () {
                                if (isAll) {
                                  Navigator.pushNamed(context, NewsEntryListPage.routeName);
                                } else {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => NewsEntryListPage(
                                        initialCategory: cat.toLowerCase(),
                                      ),
                                    ),
                                  );
                                }
                              },
                              child: Container(
                                // GUNAKAN MARGIN SIMETRIS (Kiri 6, Kanan 6)
                                // Ini menghapus jarak lebar 25px di awal yang bikin terpotong
                                margin: const EdgeInsets.symmetric(horizontal: 6), 
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: ArenaColor.darkAmethystLight.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(100),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.1),
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
                          }).toList(),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // --- 3. DYNAMIC BIG NEWS CARDS ---
                  FutureBuilder<List<NewsEntry>>(
                    future: fetchHomeNews(request),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.only(top: 50.0),
                            child: CircularProgressIndicator(color: ArenaColor.dragonFruit),
                          ),
                        );
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            "Failed to load news.\nError: ${snapshot.error}", 
                            style: const TextStyle(color: Colors.white54),
                            textAlign: TextAlign.center,
                          )
                        );
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.only(top: 50.0),
                            child: Text(
                              "Belum ada berita populer saat ini.", 
                              style: TextStyle(color: Colors.white54)
                            ),
                          ),
                        );
                      } else {
                        // DATA SUKSES
                        return Column(
                          children: snapshot.data!.map((news) {
                            return Column(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => NewsDetailPage(news: news),
                                      ),
                                    );
                                  },
                                  child: HomeNewsCard(
                                    title: news.title,
                                    subtitle: "${news.newsViews} Views • ${news.author}", 
                                    tag: news.sports,
                                    imageUrl: "https://neal-guarddin-arenainvicta.pbp.cs.ui.ac.id/proxy-image/?url=${Uri.encodeComponent(news.thumbnail ?? '')}",
                                  ),
                                ),
                                const SizedBox(height: 32),
                              ],
                            );
                          }).toList(),
                        );
                      }
                    },
                  ),
                  
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),

          // 3. HEADER (Glassy)
          GlassyHeader(
            userProvider: userProvider,
            scaffoldKey: _scaffoldKey,
            isHome: true, // Burger Menu
            title: "Arena Invicta",
          ),

          // 4. NAVBAR (Glassy)
          GlassyNavbar(
            userProvider: userProvider,
            fabIcon: Icons.grid_view_rounded, // Icon 4 Kotak
            onFabTap: () {
              // Reset Filter
              setState(() {
                activeCategory = "All";
              });
            },
          ),
        ],
      ),
    );
  }
}

// --- WIDGET HOME NEWS CARD (FINAL FIXED VERSION) ---
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
      // 1. CONTAINER LUAR: HANYA UNTUK SHADOW
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        color: ArenaColor.darkAmethyst,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      // 2. CLIPRRRECT: MEMOTONG GAMBAR
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Stack(
          children: [
            // A. GAMBAR BACKGROUND
            Positioned.fill(
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                filterQuality: FilterQuality.high,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: ArenaColor.darkAmethystLight,
                    child: const Center(
                      child: Icon(
                        Icons.broken_image_rounded, 
                        color: Colors.white24, 
                        size: 50,
                      ),
                    ),
                  );
                },
              ),
            ),

            // B. GRADIENT OVERLAY
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      ArenaColor.darkAmethyst.withOpacity(0.9),
                    ],
                    stops: const [0.4, 1.0],
                  ),
                ),
              ),
            ),

            // C. KONTEN TEKS & TAG
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: ArenaColor.dragonFruit.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: ArenaColor.dragonFruit.withOpacity(0.8)),
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
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- PROVIDER ---
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