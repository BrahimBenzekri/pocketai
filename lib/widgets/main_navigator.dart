import 'package:flutter/material.dart';
import 'package:pocketai/screens/home_screen.dart';
import 'package:pocketai/screens/chatbot_screen.dart';
import 'package:pocketai/widgets/custom_bottom_nav_bar.dart';
import 'package:pocketai/widgets/expandable_fab.dart';

class MainNavigator extends StatefulWidget {
  const MainNavigator({super.key});

  @override
  State<MainNavigator> createState() => _MainNavigatorState();
}

class _MainNavigatorState extends State<MainNavigator> {
  int _currentIndex = 0;

  void _onNavigate(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          HomeScreen(onNavigate: _onNavigate),
          const ChatbotScreen(),
          const Placeholder(), // Stats screen
          const Placeholder(), // Profile screen
        ],
      ),
      floatingActionButton: const ExpandableFab(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _currentIndex == 0
          ? null
          : Padding(
              padding: const EdgeInsets.all(16),
              child: CustomBottomNavBar(
                currentIndex: _currentIndex,
                onTap: _onNavigate,
              ),
            ),
    );
  }
}
