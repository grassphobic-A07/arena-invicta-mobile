import 'package:arena_invicta_mobile/global/widgets/app_colors.dart';
import 'package:arena_invicta_mobile/hannan_quiz/screens/private_quiz_list.dart';
import 'package:arena_invicta_mobile/hannan_quiz/screens/public_quiz_list.dart';
import 'package:arena_invicta_mobile/main.dart'; //
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class QuizMainPage extends StatefulWidget {
  const QuizMainPage({super.key});

  @override
  State<QuizMainPage> createState() => _QuizMainPageState();
}

class _QuizMainPageState extends State<QuizMainPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>(); //
    final isVisitor = !userProvider.isLoggedIn;

    return Scaffold(
      backgroundColor: Colors.transparent, // Inherits gradient from parent
      appBar: AppBar(
        title: const Text("Quiz Arena"),
        backgroundColor: Colors.transparent,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: ArenaColor.dragonFruit, //
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white54,
          tabs: [
            const Tab(icon: Icon(Icons.public), text: "Public Arena"),
            if (!isVisitor)
              const Tab(icon: Icon(Icons.lock_outline), text: "My Vault")
            else
              const Tab(icon: Icon(Icons.lock), text: "Login Required"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          const PublicQuizList(),
          if (!isVisitor) 
            const PrivateQuizList()
          else 
            _buildLoginPlaceholder(context),
        ],
      ),
    );
  }

  Widget _buildLoginPlaceholder(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.lock_person, size: 80, color: Colors.white24),
          const SizedBox(height: 16),
          const Text(
            "Access Denied",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text("Login to manage your private quizzes."),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: ArenaColor.purpleX11, //
              foregroundColor: Colors.white,
            ),
            onPressed: () {
               // Navigate to login using routeName defined in main.dart
               Navigator.pushNamed(context, '/login');
            },
            child: const Text("Login Now"),
          )
        ],
      ),
    );
  }
}