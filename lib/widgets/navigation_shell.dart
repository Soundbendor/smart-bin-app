import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:binsight_ai/util/print.dart';
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
        title:
            Text('binsight.ai', style: Theme.of(context).textTheme.titleLarge),
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
        ],
        currentIndex: _calculateSelectedIndex(context),
        onTap: (int idx) => _onItemTapped(idx, context),
      ),
    );
  }

  // Calculate the index of the bottom navigation bar based on the current route
  static int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();
    debug(location);
    if (location == '/main') {
      return 0;
    }
    if (location.startsWith('/main/detection')) {
      return 1;
    }
    // Default to home page
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
    }
  }
}
