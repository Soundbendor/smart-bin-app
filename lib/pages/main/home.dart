import 'package:flutter/material.dart';

/// Displays the home page.
// TODO: Add content to the home page
// Should show some recent scans, stats, and other information.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          "Home Page Content",
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }
}
