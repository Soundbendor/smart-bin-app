import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:binsight_ai/widgets/top_nav_bar.dart';

/// Bottom navigation bar widget with an app bar and tab icons.
class NavigationShell extends StatelessWidget {
  const NavigationShell({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('binsight.ai'),
        centerTitle: true,
      ),
      body: child,
      drawer: const TopNavBar(),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Detections',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.show_chart),
            label: 'Stats',
          ),
        ],
        currentIndex: _calculateSelectedIndex(context),
        onTap: (int idx) => _onItemTapped(idx, context),
      ),
    );
  }

  // Calculate the index of the bottom navigation bar based on the current route
  static int _calculateSelectedIndex(BuildContext context) {
    try {
      final String location = GoRouterState.of(context).uri.toString();
      if (location == '/main') {
        return 0;
      }
      if (location == '/main/detections') {
        return 1;
      }
      if (location == '/main/stats') {
        return 2;
      }
      // Default to home page
      return 0;
    } catch (e) {
      return 0;
    }
  }

  // Function to handle navigation when an item is tapped
  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        GoRouter.of(context).go('/main');
        break;
      case 1:
        GoRouter.of(context).go('/main/detections');
        break;
      case 2:
        GoRouter.of(context).go('/main/stats');
    }
  }
}