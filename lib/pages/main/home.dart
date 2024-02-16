import 'package:flutter/material.dart';

/// Displays the home page.
// TODO: Add content to the home page
// Should show some recent scans, stats, and other information.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Text(
        "My Dashboard",
        style: Theme.of(context).textTheme.bodyLarge,
      ),
    );
  }
}
