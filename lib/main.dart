import 'package:arena_invicta_mobile/screens/neal_auth/login.dart';
import 'package:arena_invicta_mobile/screens/neal_auth/register.dart';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';


// Simple enum & session helper
enum UserRole {
  visitor, registered, staff, admin
}

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
        Provider<CookieRequest>(create: (_) => CookieRequest(),),

        ChangeNotifierProvider<UserProvider>(create: (_) => UserProvider())
      ],
      child: MaterialApp(
        title: 'Arena Invicta',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
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
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final roleText = userProvider.roleLabel;

    return Scaffold(
      // App Bar
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
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

                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text("Berhasil Logout!"),
                  ),
                );

              }, 
            ),
          ],
          
        ],
      ),

      // Drawer App
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: ThemeData.dark().primaryColorDark,
              ),
              child: Column(
                children: [
                  Text(
                    'Hi! ${userProvider.username[0].toUpperCase()}${userProvider.username.substring(1)}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold
                    ),
                  ),

                  const SizedBox(height: 8,),
                  Text(
                    'Status: ${userProvider.isLoggedIn ? "Online" : "Offline"}',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),

                  Text(
                    'Role: $roleText',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
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
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Role aktif: $roleText'),
            const SizedBox(height: 12,),
            if (!userProvider.isLoggedIn) ...[
              const Text(
                'Anda belum login. Silakan login untuk mengakses fitur lebih lengkap.',
                style: TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ] else ...[
              const Text('You have pushed the button this many times:'),
              Text(
                '$_counter',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ]
            
          ],
        ),
      ),
      floatingActionButton: userProvider.isLoggedIn ? FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ) : null,
    );
  }
}
