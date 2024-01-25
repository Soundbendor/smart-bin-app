import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Top navigation bar widget burger menu with slide out drawer functionality.
class TopNavBar extends StatelessWidget {
  const TopNavBar({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      topNavigationBar: TopNavigationBar(
        items: const [
          TopNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          TopNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Detections',
          ),
          TopNavigationBarItem(
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
    return 0;
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
