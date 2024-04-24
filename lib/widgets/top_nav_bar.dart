// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';

// Project imports:
import 'package:binsight_ai/util/styles.dart';

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
      child: Container(
        color: mainTheme.colorScheme.background,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/bird_branch.png'),
                  fit: BoxFit.cover,
                ),
                color: Color(0xFFeef8f4),
              ),
              child: Text(
                'Binsight.ai',
                style: mainTheme.textTheme.displayLarge?.copyWith(
                  color: const Color(0xFF333333),
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
              leading: const Icon(Icons.list),
              title: const Text('FAQ'),
              selected: _selectedIndex == 1,
              onTap: () {
                _onItemTapped(1);
                GoRouter.of(context).goNamed('faq');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.book_outlined),
              title: const Text('User Guide'),
              selected: _selectedIndex == 2,
              onTap: () {
                _onItemTapped(2);
                GoRouter.of(context).goNamed('user_guide');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.question_mark_outlined),
              title: const Text('Help'),
              selected: _selectedIndex == 3,
              onTap: () {
                _onItemTapped(3);
                GoRouter.of(context).goNamed('help');
                Navigator.pop(context);
              },
            ),
            // Current version number
            // TODO: create a version number that is updated automatically
            ListTile(
              title: VersionText(),
            ),
          ],
        ),
      ),
    );
  }
}

class VersionText extends StatelessWidget {
  VersionText({
    super.key,
  });

  final Future<PackageInfo> packageInfo = PackageInfo.fromPlatform();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: packageInfo,
        builder: (context, snapshot) {
          return Text(
            "Version ${snapshot.connectionState == ConnectionState.done ? snapshot.data!.version : '1.0.0'}",
            style: const TextStyle(fontSize: 10, color: Colors.grey),
          );
        });
  }
}
