import 'package:arena_invicta_mobile/global/widgets/app_colors.dart';
import 'package:arena_invicta_mobile/main.dart';
import 'package:arena_invicta_mobile/neal_auth/screens/login.dart';
import 'package:arena_invicta_mobile/neal_auth/screens/register.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ArenaInvictaDrawer extends StatelessWidget {
  ArenaInvictaDrawer({
    super.key,
    required this.userProvider,
    required this.roleText,
  });
  
  final UserProvider userProvider;
  final String roleText;

  // modul/
  // setiap ini ada models, widgets, screens,
  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: ArenaColor.darkAmethyst,

      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            
            decoration: ArenaColor.mainBackgroundGradient,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  child: Text (
                    (userProvider.isLoggedIn && userProvider.username.isNotEmpty) ? userProvider.username[0].toUpperCase() : 'V',
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  (userProvider.isLoggedIn && userProvider.username.isNotEmpty) ?
                  'Hi! ${userProvider.username[0].toUpperCase()}${userProvider.username.substring(1)}' : 'Hi! Visitor',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                Row(
                  children: [
                    Icon(Icons.verified_user, size: 14, color: Colors.white70),
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

          if (userProvider.isLoggedIn) ... [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Divider(color: Colors.white.withOpacity(0.1)),
            ),

            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                // Aksi ketika menu Settings ditekan
              },
            ),

            ListTile(
              leading: const Icon(Icons.logout_rounded, color: Colors.redAccent,),
              title: const Text('Logout', style: TextStyle(color: Colors.redAccent),),
              onTap: () {
                context.read<UserProvider>().logout();

                Navigator.pop(context); // Tutup drawer setelah logout
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Berhasil Logout!")),
                );
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
