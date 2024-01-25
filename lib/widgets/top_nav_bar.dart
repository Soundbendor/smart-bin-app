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

  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  static const List<Widget> _widgetOptions = <Widget>[
    Text(
      'Index 0: Home',
      style: optionStyle,
    ),
    Text(
      'Index 1: Profile',
      style: optionStyle,
    ),
    Text(
      'Index 2: Help',
      style: optionStyle,
    ),
  ];

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
        // Important: Remove any padding from the ListView.
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
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
              // Then close the drawer.
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.person_2_outlined),
            title: const Text('Profile'),
            selected: _selectedIndex == 1,
            onTap: () {
              _onItemTapped(1);
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
