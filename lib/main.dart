import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

// --- IMPORTS MODUL ---
import 'package:arena_invicta_mobile/global/widgets/app_colors.dart';
import 'package:arena_invicta_mobile/global/screens/splash_screen.dart';
import 'package:arena_invicta_mobile/global/widgets/glassy_header.dart'; 
import 'package:arena_invicta_mobile/global/widgets/glassy_navbar.dart'; 

import 'package:arena_invicta_mobile/neal_auth/widgets/arena_invicta_drawer.dart';
import 'package:arena_invicta_mobile/neal_auth/screens/login.dart';
import 'package:arena_invicta_mobile/neal_auth/screens/register.dart';
import 'package:arena_invicta_mobile/neal_auth/screens/profile_page.dart';

import 'package:arena_invicta_mobile/rafa_news/screens/news_entry_list.dart';
import 'package:arena_invicta_mobile/rafa_news/models/news_entry.dart';
import 'package:arena_invicta_mobile/rafa_news/screens/news_detail_page.dart';
import 'package:arena_invicta_mobile/rafa_news/widgets/news_entry_card.dart'; 
import 'package:arena_invicta_mobile/rafa_news/widgets/hot_news_carousel.dart'; 

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
          '/': (context) => const SplashScreen(),
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

  // --- LOGIKA FETCH & PISAHKAN DATA ---
  Future<Map<String, List<NewsEntry>>> fetchHomeNews(CookieRequest request) async {
    String url = 'http://localhost:8000/show-news-json'; // TODO: GANTI KE URL SERVER KALAU UDAH DEPLOY
    
    if (activeCategory != "All") {
      url += '?filter=${activeCategory.toLowerCase()}';
    }

    try {
      final response = await request.get(url);
      List<NewsEntry> allNews = [];
      for (var d in response) {
        if (d != null) allNews.add(NewsEntry.fromJson(d));
      }

      // 1. CAROUSEL DATA
      List<NewsEntry> carouselList = allNews.where((n) => n.isFeatured).toList();
      if (carouselList.length < 3) {
         allNews.sort((a, b) => b.newsViews.compareTo(a.newsViews)); 
         for (var news in allNews) {
           if (!carouselList.contains(news) && carouselList.length < 5) {
             carouselList.add(news);
           }
         }
      }
      carouselList = carouselList.take(5).toList();

      // 2. LIST DATA
      List<NewsEntry> trendingList = List.from(allNews);
      trendingList.sort((a, b) => b.newsViews.compareTo(a.newsViews));
      trendingList.removeWhere((news) => carouselList.any((c) => c.id == news.id));
      trendingList = trendingList.take(5).toList();

      return {
        'carousel': carouselList,
        'trending': trendingList,
      };
      
    } catch (e) {
      debugPrint("Error fetching news: $e");
      return {'carousel': [], 'trending': []};
    }
  }

  Widget _buildGlowCircle(Color color) {
    return Container(
      width: 300, height: 300,
      decoration: BoxDecoration(color: color.withOpacity(0.2), shape: BoxShape.circle),
      child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80), child: Container(color: Colors.transparent)),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Text(
        title,
        style: GoogleFonts.outfit(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildDiscussionCard({required String title, required String topic, required String count, required String imageUrl}) {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ArenaColor.darkAmethystLight.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              imageUrl,
              width: 60, height: 60, fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(width: 60, height: 60, color: Colors.grey.withOpacity(0.2)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(topic, style: TextStyle(color: Colors.white54, fontSize: 12)),
              ],
            ),
          ),
          Column(
            children: [
              const Icon(Icons.keyboard_arrow_up_rounded, color: ArenaColor.dragonFruit),
              Text(count, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
            ],
          )
        ],
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
      drawer: ArenaInvictaDrawer(userProvider: userProvider, roleText: ""),

      body: Stack(
        children: [
          // 1. BACKGROUND GLOWS
          Positioned(top: -100, left: -50, child: _buildGlowCircle(ArenaColor.purpleX11)),
          Positioned(bottom: -100, right: -50, child: _buildGlowCircle(ArenaColor.dragonFruit)),

          // 2. MAIN CONTENT
          Positioned.fill(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(top: 110, bottom: 120), 
              child: FutureBuilder<Map<String, List<NewsEntry>>>(
                future: fetchHomeNews(request),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: Padding(padding: EdgeInsets.only(top: 100), child: CircularProgressIndicator(color: ArenaColor.dragonFruit)));
                  }
                  
                  if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}", style: const TextStyle(color: Colors.white54)));
                  }

                  final carouselData = snapshot.data?['carousel'] ?? [];
                  final trendingData = snapshot.data?['trending'] ?? [];

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      
                      // --- A. CAROUSEL SECTION ---
                      SizedBox(
                        height: 200, // Tinggi Area Carousel
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                             Positioned(
                               top: -60,
                               left: 0, 
                               right: 0,
                               height: 250,
                               child: carouselData.isNotEmpty
                                  ? HotNewsCarousel(newsList: carouselData)
                                  : Container(
                                      color: const Color(0xFF4A49A0),
                                      child: const Center(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.newspaper_rounded, color: Colors.white54, size: 40),
                                            SizedBox(height: 8),
                                            Text("No highlights", style: TextStyle(color: Colors.white54)),
                                          ],
                                        ),
                                      ),
                                    ),
                             ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 24),

                      // --- B. SPORTS CHIPS ---
                      SizedBox(
                        height: 45,
                        child: Center(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            clipBehavior: Clip.none, 
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const SizedBox(width: 25), 
                                ...categories.map((cat) {
                                  final isAll = cat == "All";
                                  final isActive = activeCategory == cat;
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 12), 
                                    child: GestureDetector(
                                      onTap: () {
                                        if (isAll) {
                                          Navigator.pushNamed(context, NewsEntryListPage.routeName);
                                        } else {
                                          setState(() => activeCategory = cat);
                                        }
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: (isActive && !isAll) 
                                              ? ArenaColor.purpleX11 
                                              : ArenaColor.darkAmethystLight.withOpacity(0.3),
                                          borderRadius: BorderRadius.circular(100),
                                          border: Border.all(
                                            color: (isActive && !isAll) 
                                                ? ArenaColor.purpleX11 
                                                : Colors.white.withOpacity(0.1)
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
                                    ),
                                  );
                                }).toList(),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // --- C. LIST SECTION (TRENDING NEWS) ---
                      _buildSectionTitle("Trending News"),

                      if (trendingData.isNotEmpty) ...[
                        Column(
                          children: trendingData.map((news) {
                            return Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                                  child: NewsEntryCard(
                                    news: news,
                                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => NewsDetailPage(news: news))),
                                  ),
                                ),
                                const SizedBox(height: 24),
                              ],
                            );
                          }).toList(),
                        )
                      ] else ...[
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.symmetric(horizontal: 24),
                          padding: const EdgeInsets.symmetric(vertical: 30),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Center(
                            child: Text("Belum ada berita trending lainnya.", style: TextStyle(color: Colors.white38)),
                          ),
                        )
                      ],

                      // --- D. DISCUSSIONS SECTION ---
                      const SizedBox(height: 16),
                      _buildSectionTitle("Hot Discussions"),

                      _buildDiscussionCard(title: "Kenapa Bumi Bulat?", topic: "Sains", count: "70", imageUrl: "https://i.pinimg.com/736x/8f/c3/97/8fc397664421896796c00329062363b9.jpg"),
                      _buildDiscussionCard(title: "Kenapa MC Kotak?", topic: "Gaming", count: "69", imageUrl: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR_86t8XwZqjQRuuvqW_rbVd8QyqHn8lR2YgA&s"),
                      
                      const SizedBox(height: 80),
                    ],
                  );
                },
              ),
            ),
          ),

          // 3. HEADER & NAVBAR
          GlassyHeader(userProvider: userProvider, scaffoldKey: _scaffoldKey, isHome: true, title: "Arena Invicta"),
          GlassyNavbar(userProvider: userProvider, fabIcon: Icons.grid_view_rounded, onFabTap: () => setState(() => activeCategory = "All")),
        ],
      ),
    );
  }
}

// --- PROVIDER DI DALAM MAIN.DART ---
// Ini agar kamu tidak perlu file provider terpisah
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