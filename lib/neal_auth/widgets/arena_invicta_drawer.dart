import 'package:arena_invicta_mobile/main.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ArenaInvictaDrawer extends StatelessWidget {
  ArenaInvictaDrawer({
    super.key,
    required this.userProvider,
    required this.roleText,
  });
  UserProvider userProvider;
  String roleText;

  // modul/
  // setiap ini ada models, widgets, screens,
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(color: ThemeData.dark().primaryColorDark),
            child: Column(
              children: [
                Text(
                  (userProvider.isLoggedIn && userProvider.username.isNotEmpty) ?
                  'Hi! ${userProvider.username[0].toUpperCase()}${userProvider.username.substring(1)}' : 'Hi! Visitor',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),
                Text(
                  'Status: ${userProvider.isLoggedIn ? "Online" : "Offline"}',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),

                Text(
                  'Role: $roleText',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              Navigator.pushNamed(context, MyApp.routeName);
            },
          ),

          if (userProvider.isLoggedIn)
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                // Aksi ketika menu Settings ditekan
              },
            ),
        ],
      ),
    );
  }
}
