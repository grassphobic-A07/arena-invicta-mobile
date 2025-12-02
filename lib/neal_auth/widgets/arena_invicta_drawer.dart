// ignore_for_file: deprecated_member_use

import 'package:arena_invicta_mobile/global/environments.dart';
import 'package:arena_invicta_mobile/global/widgets/app_colors.dart';
import 'package:arena_invicta_mobile/main.dart';
import 'package:arena_invicta_mobile/neal_auth/screens/admin_dashboard.dart';
import 'package:arena_invicta_mobile/neal_auth/screens/login.dart';
import 'package:arena_invicta_mobile/neal_auth/screens/profile_page.dart';
import 'package:arena_invicta_mobile/neal_auth/screens/register.dart';
// IMPORT HALAMAN NEWS LIST DI SINI
import 'package:arena_invicta_mobile/rafa_news/screens/news_entry_list.dart'; 
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class ArenaInvictaDrawer extends StatelessWidget {
  ArenaInvictaDrawer({
    super.key,
    required this.userProvider,
    required this.roleText,
  });
  
  final UserProvider userProvider;
  final String roleText;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: ArenaColor.darkAmethyst,

      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            margin: EdgeInsets.zero,
            decoration: ArenaColor.mainBackgroundGradient,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  backgroundImage: (userProvider.isLoggedIn && userProvider.avatarUrl != null && userProvider.avatarUrl!.isNotEmpty) ? NetworkImage(userProvider.avatarUrl!) : null,
                  child: (userProvider.isLoggedIn && (userProvider.avatarUrl == null || userProvider.avatarUrl!.isEmpty))
                      ? Text (
                          userProvider.username.isNotEmpty ? userProvider.username[0].toUpperCase() : '?',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: ArenaColor.darkAmethyst),
                        )
                      : (!userProvider.isLoggedIn ? const Text('V') : null),
                ),

                const SizedBox(height: 12),

                Text(
                  (userProvider.isLoggedIn && userProvider.username.isNotEmpty) ?
                  'Hi! ${userProvider.username}' : 'Hi! Visitor',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                Row(
                  children: [
                    const Icon(Icons.verified_user, size: 14, color: Colors.white70),
                    const SizedBox(width: 4),
                    Text(
                      roleText,
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                )
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home, color: Colors.white,),
            title: const Text('Home', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pushReplacementNamed(context, MyApp.routeName);
            },
          ),

          // --- TAMBAHKAN MENU NEWS DI SINI ---
          ListTile(
            leading: const Icon(Icons.newspaper_rounded, color: ArenaColor.dragonFruit),
            title: const Text('Latest News', style: TextStyle(color: Colors.white)),
            onTap: () {
              // Tutup drawer dulu
              Navigator.pop(context);
              // Navigasi ke halaman News List
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NewsEntryListPage()),
              );
            },
          ),
          // -----------------------------------

          if (userProvider.isLoggedIn) ... [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Divider(color: Colors.white.withOpacity(0.1)),
            ),

            if (userProvider.role == UserRole.admin) 
              ListTile(
                leading: const Icon(Icons.admin_panel_settings_rounded, color: ArenaColor.purpleX11), 
                title: const Text('Admin Dashboard', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AdminDashboardPage()),
                  );
                },
              ),
              
            ListTile(
              leading: const Icon(Icons.account_circle, color: ArenaColor.purpleX11),
              title: const Text('My Profile', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context); 
                Navigator.pushNamed(context, ProfilePage.routeName);
              },
            ),

            ListTile(
              leading: const Icon(Icons.logout_rounded, color: Colors.redAccent,),
              title: const Text('Logout', style: TextStyle(color: Colors.redAccent),),
              onTap: () async {
                final request = context.read<CookieRequest>();

                  final response = await request.logout("$baseUrl/accounts/api/logout/");
                  if (context.mounted) {
                      context.read<UserProvider>().logout();
                      
                      String message = response['message'] ?? "Berhasil Logout!";
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(message), backgroundColor: Colors.greenAccent,),
                      );
                      
                      Navigator.pushReplacementNamed(context, MyApp.routeName);
                  }
              },
            )
          ] else ... [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Divider(color: Colors.white.withOpacity(0.1)),
            ),

            ListTile(
              leading: const Icon(Icons.login, color: ArenaColor.dragonFruit),
              title: const Text("Login", style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, LoginPage.routeName);
              }
            ),

            ListTile(
              leading: const Icon(Icons.person_add, color: ArenaColor.purpleX11),
              title: const Text("Register", style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, RegisterPage.routeName);
              }
            ),
          ]
        ],
      ),
    );
  }
}