import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Top navigation bar widget burger menu with slide out drawer functionality.
class TopNavBar extends StatefulWidget {
  const TopNavBar({
    super.key,
  });

  @override
  State<TopNavBar> createState() => _TopNavBarState();
}

/// State class for the top navigation bar widget.
class _TopNavBarState extends State<TopNavBar> {
  // Set default selection in the navigation bar to the home page.
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // When user opens the drawer, it is added to the navigation stack.
    return Drawer(
      // Add a ListView to the drawer. This ensures the user can scroll
      // through the options in the drawer if there isn't enough vertical
      // space to fit everything.
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 25, 192, 147),
            ),
            child: Text(
              'Binsight.ai',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            selected: _selectedIndex == 0,
            onTap: () {
              // Update the state of the app.
              _onItemTapped(0);
              GoRouter.of(context).goNamed('main');
              // Then close the drawer.
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.question_mark_outlined),
            title: const Text('Help'),
            selected: _selectedIndex == 2,
            onTap: () {
              _onItemTapped(2);
              GoRouter.of(context).goNamed('help');
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
